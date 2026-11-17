#!/usr/bin/env perl
# tests/08_secret_leak_prevention.t
# PCI DSS & Zero-Secret-Leakage Test Suite
# Ensures no credentials, API keys, private keys, database dumps, or environment files are tracked

use strict;
use warnings;
use Test::More;
use File::Basename;
use Cwd qw(abs_path);

my $base_dir = abs_path(dirname(__FILE__) . "/..");
chdir($base_dir) or die "Cannot chdir to $base_dir: $!";

plan tests => 6;

# 1. Verify .gitignore existence and critical pattern coverage
{
    ok(-f "$base_dir/.gitignore", ".gitignore exists in repository root");

    open(my $gfh, "<", "$base_dir/.gitignore") or die "Cannot read .gitignore: $!";
    my $gi_content = do { local $/; <$gfh> };
    close($gfh);

    my @required_patterns = (
        '*.env',
        '*.key',
        '*.pem',
        '*.sql',
        '*.db',
        '*.sqlite',
        'id_rsa*',
        'id_ed25519*',
        '*.swp',
        '.DS_Store'
    );

    my $all_present = 1;
    for my $pat (@required_patterns) {
        if ($gi_content !~ /\Q$pat\E/) {
            $all_present = 0;
            diag("Missing critical pattern in .gitignore: $pat");
        }
    }
    ok($all_present, ".gitignore covers all critical secret, key, database, and temporary patterns");
}

# 2. Check all git-tracked files for forbidden file extensions
{
    my @tracked_files = `git ls-files`;
    chomp(@tracked_files);

    my @forbidden_extensions = (
        qr/\.env(\.|$)/i,
        qr/\.(key|pem|pkcs12|pfx|p12|csr|der|kdbx)$/i,
        qr/\.(sql|dump|rdb|sqlite|sqlite3|db)$/i,
        qr/(id_rsa|id_ed25519|id_ecdsa|id_dsa)/i,
        qr/\.(swp|swo|bak|orig)$/i,
        qr/credentials\.json$/i,
        qr/auth\.json$/i,
    );

    my @violations;
    for my $f (@tracked_files) {
        for my $rx (@forbidden_extensions) {
            if ($f =~ $rx) {
                push @violations, "$f matches forbidden pattern $rx";
            }
        }
    }

    is(scalar(@violations), 0, "No tracked files match forbidden secret/database/key patterns");
    diag("Violations found: " . join(", ", @violations)) if @violations;
}

# 3. Check for private key markers in tracked file contents
{
    my $pk_cmd = "git grep -iE -e '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----' -- 2>&1";
    my $pk_out = `$pk_cmd`;
    my $pk_rc = $? >> 8;

    is($pk_rc, 1, "Zero private cryptographic keys found in repository content");
    diag("Private key leakage detected: $pk_out") if $pk_rc == 0;
}

# 4. Check for known API key & secret patterns in tracked file contents
{
    # Known cloud provider and platform token prefixes
    my @secret_regexes = (
        qr/AKIA[0-9A-Z]{16}/,                     # AWS Access Key ID
        qr/ghp_[0-9a-zA-Z]{36}/,                  # GitHub Personal Access Token
        qr/gho_[0-9a-zA-Z]{36}/,                  # GitHub OAuth Access Token
        qr/glpat-[0-9a-zA-Z\-_]{20}/,             # GitLab Personal Access Token
        qr/AIza[0-9A-Za-z\-_]{35}/,               # Google API Key
        qr/sk_live_[0-9a-zA-Z]{24}/,              # Stripe Live Secret Key
        qr/xox[baprs]-[0-9a-zA-Z]{10,48}/,        # Slack Token
    );

    my @tracked_files = `git ls-files`;
    chomp(@tracked_files);

    my @token_violations;
    for my $f (@tracked_files) {
        next if !-f $f || -l $f; # Skip symlinks
        open(my $fh, "<", $f) or next;
        my $content = do { local $/; <$fh> };
        close($fh);

        for my $rx (@secret_regexes) {
            if ($content =~ $rx) {
                push @token_violations, "$f matches API token signature $rx";
            }
        }
    }

    is(scalar(@token_violations), 0, "Zero known cloud API keys or platform tokens found in repository content");
    diag("Token violations: " . join(", ", @token_violations)) if @token_violations;
}

# 5. Check git commit history for sensitive filenames
{
    my $hist_cmd = "git log --all --full-history --name-only --format='' | grep -iE '(\\.env|\\.key|\\.pem|\\.sql|\\.db|id_rsa)' | sort -u";
    my $hist_out = `$hist_cmd`;
    chomp($hist_out);

    # Allow documentation files like ECOMMERCE_GUIDE.md or APPLICATIONS.md if mentioned
    my @suspicious = grep { $_ !~ /\.(md|pl|service|t|sh|yml)$/ && $_ =~ /\.(env|key|pem|sql|db|sqlite)/i } split /\n/, $hist_out;

    is(scalar(@suspicious), 0, "Zero sensitive files committed in historical git tree");
    diag("Historical leaks: " . join(", ", @suspicious)) if @suspicious;
}
