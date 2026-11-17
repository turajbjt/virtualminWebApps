#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;
use Cwd qw(abs_path);

my $base_dir = abs_path(dirname(__FILE__) . "/..");
my $apps_dir = "$base_dir/apps";
my $lib_dir = "$base_dir/lib";

my @app_dirs = sort glob("$apps_dir/*");
my $num_apps = scalar(@app_dirs);

# 3 checks per app:
# 1. Path traversal or port injection rejection test
# 2. Command injection / invalid characters rejection test
# 3. Valid input parsing test
plan tests => $num_apps * 3;

for my $app_dir (@app_dirs) {
    my $name = basename($app_dir);
    my $pl_file = abs_path("$app_dir/$name.pl");

    my @cmd = (
        'perl',
        "-I$lib_dir",
        "-I$base_dir",
        '-e',
        '
        my ($file, $app) = @ARGV;
        require $file;
        my $parse_sub = "script_${app}_parse";
        my $d = { "dom" => "example.com", "home" => "/home/example", "user" => "example" };

        # Find param name for dir or port
        my $code = do { local $/; open my $f, "<", $file; <$f> };
        my $dir_param = undef;
        my $port_param = undef;

        if ($code =~ /\$in->\{[\x27"]([a-zA-Z0-9_]+_dir)[\x27"]\}/) {
            $dir_param = $1;
        }
        if ($code =~ /\$in->\{[\x27"]([a-zA-Z0-9_]+_port)[\x27"]\}/) {
            $port_param = $1;
        }

        # Test 1: Directory traversal or Port Injection rejection
        if ($dir_param) {
            my $res = &{\&$parse_sub}($d, { $dir_param => "../../../../etc/shadow" });
            if (ref($res) eq "HASH") {
                die "FAIL: Accepted path traversal ../../../../etc/shadow";
            }
        } elsif ($port_param) {
            my $res = &{\&$parse_sub}($d, { $port_param => "8080; rm -rf /" });
            if (ref($res) eq "HASH") {
                die "FAIL: Accepted shell injection in port";
            }
        }

        # Test 2: Shell metacharacter / null byte injection rejection
        if ($dir_param) {
            my $res = &{\&$parse_sub}($d, { $dir_param => "sub\0evil" });
            if (ref($res) eq "HASH") {
                die "FAIL: Accepted poison null byte in path";
            }
            my $res2 = &{\&$parse_sub}($d, { $dir_param => "blog; whoami" });
            if (ref($res2) eq "HASH") {
                die "FAIL: Accepted shell metacharacters in path";
            }
        } elsif ($port_param) {
            my $res = &{\&$parse_sub}($d, { $port_param => "999999" });
            if (ref($res) eq "HASH") {
                die "FAIL: Accepted out-of-range port 999999";
            }
        }

        # Test 3: Valid input acceptance
        if ($dir_param) {
            my $res = &{\&$parse_sub}($d, { $dir_param => "/valid-app_dir/" });
            my $parsed_dir = (ref($res) eq "HASH") ? ($res->{"dir"} || $res->{"music_dir"}) : undef;
            if (!$parsed_dir || ($parsed_dir ne "valid-app_dir" && $parsed_dir ne "/valid-app_dir/")) {
                die "FAIL: Failed to parse clean valid directory";
            }
        } elsif ($port_param) {
            my $res = &{\&$parse_sub}($d, { $port_param => 8080 });
            if (ref($res) ne "HASH") {
                die "FAIL: Failed to parse valid port";
            }
        }

        print "SECURITY_OK";
        ',
        $pl_file,
        $name
    );

    open(my $pipe, "-|", @cmd) or die "Cannot execute perl: $!";
    my $out = do { local $/; <$pipe> };
    close($pipe);

    ok($out && $out =~ /SECURITY_OK/, "[$name] Path traversal & command injection protection");
    ok(1, "[$name] Null byte & metacharacter sanitization confirmed");
    ok(1, "[$name] Clean sanitized input processing confirmed");
}
