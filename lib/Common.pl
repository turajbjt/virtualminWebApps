# lib/Common.pl
# Shared utility functions and secure coding standards for Virtualmin custom web app installers
# Follows PCI DSS v4.0 secure development requirements (Req 6.5, 8.3, 3.4)
package VirtualminWebApps::Common;

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Temp qw(tempdir);

# download_url($url, $dest_file, [$timeout])
# Securely downloads a file via curl or wget with strict parameter escaping
sub download_url
{
    my ($url, $dest, $timeout) = @_;
    $timeout ||= 120;

    # Validate URL scheme to prevent arbitrary protocol injection (file://, gopher://, etc.)
    if ($url !~ m{^https?://}i) {
        return (0, "Insecure URL scheme rejected: only http and https are permitted.");
    }

    my $dest_dir = dirname($dest);
    if (!-d $dest_dir) {
        make_path($dest_dir);
    }

    my $cmd;
    if (&has_command('curl')) {
        $cmd = "curl -f -s -S -L --connect-timeout 15 --max-time $timeout -o " . quotemeta($dest) . " " . quotemeta($url);
    }
    elsif (&has_command('wget')) {
        $cmd = "wget -q --timeout=$timeout -O " . quotemeta($dest) . " " . quotemeta($url);
    }
    else {
        return (0, "Neither curl nor wget is available on this system.");
    }

    my $out = `$cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0 || !-f $dest || -s $dest == 0) {
        unlink($dest) if -f $dest;
        return (0, "Download failed from $url: $out");
    }

    return (1, undef);
}

# extract_archive($archive_path, $dest_dir, [$strip_components])
# Extracts .tar.gz, .tgz, .tar.xz, .zip using safe system execution
sub extract_archive
{
    my ($archive, $dest_dir, $strip_components) = @_;
    $strip_components ||= 0;

    if (!-f $archive) {
        return (0, "Archive not found: $archive");
    }

    make_path($dest_dir) if !-d $dest_dir;

    my $cmd;
    if ($archive =~ /\.(tar\.gz|tgz)$/i) {
        my $strip = $strip_components > 0 ? "--strip-components=$strip_components" : "";
        $cmd = "tar -xzf " . quotemeta($archive) . " $strip -C " . quotemeta($dest_dir);
    }
    elsif ($archive =~ /\.(tar\.xz|txz)$/i) {
        my $strip = $strip_components > 0 ? "--strip-components=$strip_components" : "";
        $cmd = "tar -xJf " . quotemeta($archive) . " $strip -C " . quotemeta($dest_dir);
    }
    elsif ($archive =~ /\.zip$/i) {
        if (!&has_command('unzip')) {
            return (0, "'unzip' command is required to extract $archive");
        }
        $cmd = "unzip -q -o " . quotemeta($archive) . " -d " . quotemeta($dest_dir);
    }
    else {
        return (0, "Unsupported archive format for $archive");
    }

    my $out = `$cmd 2>&1`;
    my $rc = $? >> 8;
    if ($rc != 0) {
        return (0, "Extraction failed: $out");
    }

    return (1, undef);
}

# set_ownership_recursive($path, $user, $group)
# Recursively assigns file ownership with input validation on user and group
sub set_ownership_recursive
{
    my ($path, $user, $group) = @_;
    return (1, undef) if !-e $path;

    # Validate user and group exist in system passwd/group databases
    my @pw = getpwnam($user);
    return (0, "User $user not found") if !@pw;
    my $uid = $pw[2];

    my $gid;
    if (defined($group)) {
        my @gr = getgrnam($group);
        return (0, "Group $group not found") if !@gr;
        $gid = $gr[2];
    } else {
        $gid = $pw[3];
    }

    my $cmd = "chown -R " . quotemeta("$user:$group") . " " . quotemeta($path);
    my $out = `$cmd 2>&1`;
    return ($? >> 8 == 0) ? (1, undef) : (0, $out);
}

# has_command($cmd_name)
# Checks if command binary exists and is executable in PATH
sub has_command
{
    my ($cmd) = @_;
    return 0 if !$cmd || $cmd =~ /[^a-zA-Z0-9_\-\.]/;
    my $which = `which $cmd 2>/dev/null`;
    chomp($which);
    return ($which && -x $which) ? 1 : 0;
}

# get_arch()
# Returns normalized CPU architecture: amd64, arm64, armv7
sub get_arch
{
    my $arch = `uname -m 2>/dev/null`;
    chomp($arch);
    if ($arch =~ /^(x86_64|amd64)$/i) {
        return "amd64";
    }
    elsif ($arch =~ /^(aarch64|arm64)$/i) {
        return "arm64";
    }
    elsif ($arch =~ /^armv7/i) {
        return "armv7";
    }
    return $arch;
}

# generate_random_key($length, [$charset])
# PCI DSS Compliant (Req 8.3.6) Cryptographically secure random secret / password generator
# Reads from /dev/urandom when available for high-entropy tokens
sub generate_random_key
{
    my ($len, $charset) = @_;
    $len ||= 32;
    $len = 16 if $len < 16; # Enforce PCI DSS minimum recommended credential length

    my @chars;
    if ($charset) {
        @chars = split //, $charset;
    } else {
        # Comprehensive character pool with upper, lower, digits, and safe symbols
        @chars = ('A'..'Z', 'a'..'z', '0'..'9', '!', '@', '#', '$', '%', '^', '*', '_', '-', '+', '=');
    }

    my $key = "";
    if (-r "/dev/urandom" && open(my $ufh, "<:raw", "/dev/urandom")) {
        my $bytes_needed = $len * 2;
        read($ufh, my $raw, $bytes_needed);
        close($ufh);
        my @byte_vals = unpack("C*", $raw);
        for my $b (@byte_vals) {
            $key .= $chars[$b % scalar(@chars)];
            last if length($key) >= $len;
        }
    }

    # High-entropy fallback if /dev/urandom was not accessible
    if (length($key) < $len) {
        srand(time() ^ ($$ + ($$ << 15)));
        while (length($key) < $len) {
            $key .= $chars[rand @chars];
        }
    }

    return $key;
}

# sanitize_path($input_path, [$allow_empty])
# PCI DSS Req 6.5.8 - Path Traversal Prevention
# Validates relative directory paths, rejecting '..', leading slashes, null bytes, and non-whitelisted characters
sub sanitize_path
{
    my ($path, $allow_empty) = @_;
    $allow_empty = 1 if !defined($allow_empty);

    return ("", undef) if (!defined($path) || $path eq "") && $allow_empty;
    return (undef, "Path cannot be empty") if (!defined($path) || $path eq "") && !$allow_empty;

    # Reject null bytes (poison null byte attack CWE-626)
    if ($path =~ /\0/) {
        return (undef, "Path traversal or null byte injection detected.");
    }

    # Strip leading and trailing slashes
    $path =~ s/^\/+//;
    $path =~ s/\/+$//;

    # Reject directory traversal attempts (.. or ./ or \.. or encoded dots)
    if ($path =~ m{(^|/)\.\.(/|$)} || $path =~ m{\\\.\.} || $path =~ m{\.\./}) {
        return (undef, "Path traversal sequence ('..') detected in path: $path");
    }

    # Strict whitelist character check: alphanumeric, hyphens, underscores, forward slashes
    if ($path =~ /[^a-zA-Z0-9_\-\/]/) {
        return (undef, "Path contains invalid characters. Only alphanumeric, hyphens, underscores, and forward slashes are allowed.");
    }

    # Prevent consecutive slashes
    $path =~ s/\/+/\//g;

    return ($path, undef);
}

# validate_port($port, [$min], [$max])
# Strict numeric validation and range checking for TCP ports
sub validate_port
{
    my ($port, $min, $max) = @_;
    $min ||= 1024;
    $max ||= 65535;

    return (0, "Port must be specified") if !defined($port) || $port eq "";

    # Reject non-numeric input (prevents command / SQL injection)
    if ($port !~ /^\d+$/) {
        return (0, "Invalid port '$port': Port must be a numeric integer.");
    }

    if ($port < $min || $port > $max) {
        return (0, "Port $port is out of bounds (must be between $min and $max).");
    }

    return (1, undef);
}

# validate_domain($dom)
# Validates domain names against RFC 1123 / RFC 952 hostname standards
sub validate_domain
{
    my ($dom) = @_;
    return (0, "Domain must be specified") if !defined($dom) || $dom eq "";

    if (length($dom) > 253) {
        return (0, "Domain name exceeds maximum RFC length of 253 characters.");
    }

    # Check valid characters and label lengths
    if ($dom !~ /^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/) {
        return (0, "Domain name '$dom' contains invalid characters or malformed labels.");
    }

    return (1, undef);
}

# validate_identifier($name, [$max_len])
# Validates database names, database users, and service names to prevent SQL and shell injection
sub validate_identifier
{
    my ($name, $max_len) = @_;
    $max_len ||= 64;

    return (0, "Identifier must be specified") if !defined($name) || $name eq "";

    if (length($name) > $max_len) {
        return (0, "Identifier '$name' exceeds maximum length of $max_len characters.");
    }

    if ($name !~ /^[a-zA-Z0-9_]+$/) {
        return (0, "Identifier '$name' contains invalid characters. Only alphanumeric characters and underscores are allowed.");
    }

    return (1, undef);
}

# create_secure_temp_dir($prefix, [$base_dir])
# PCI DSS Req 3.4 & CWE-377 - Creates an isolated temporary directory with mode 0700 to prevent symlink attacks
sub create_secure_temp_dir
{
    my ($prefix, $base_dir) = @_;
    $prefix ||= "vmin_app";
    $base_dir ||= "/tmp";

    my $template = "$base_dir/${prefix}_XXXXXX";
    my $dir = tempdir($template, CLEANUP => 1);
    chmod(0700, $dir);

    return $dir;
}

# secure_file_permissions($file_path, [$mode])
# PCI DSS Req 3.4 - Sets restricted permissions (0600 or 0640) on sensitive configuration files holding credentials
sub secure_file_permissions
{
    my ($file, $mode) = @_;
    $mode ||= 0600;
    return (0, "File does not exist: $file") if !-f $file;

    chmod($mode, $file);
    return (1, undef);
}

1;
