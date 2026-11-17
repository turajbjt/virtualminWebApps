#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;

my $base_dir = dirname(__FILE__) . "/..";
unshift @INC, "$base_dir/lib";
require "Common.pl";

plan tests => 38;

# 1. Test URL scheme validation in download_url
{
    my ($ok, $err) = VirtualminWebApps::Common::download_url("file:///etc/passwd", "/tmp/test_download");
    ok(!$ok && $err =~ /Insecure URL scheme/, "download_url rejects file:// scheme");

    ($ok, $err) = VirtualminWebApps::Common::download_url("ftp://example.com/file.tar.gz", "/tmp/test_download");
    ok(!$ok && $err =~ /Insecure URL scheme/, "download_url rejects ftp:// scheme");
}

# 2. Test sanitize_path (PCI DSS Req 6.5.8 - Path Traversal Prevention)
{
    # Valid paths
    my ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog", 1);
    is($clean, "blog", "sanitize_path handles simple relative path");
    is($err, undef, "sanitize_path returns no error on valid path");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("/store/shop/", 1);
    is($clean, "store/shop", "sanitize_path trims leading and trailing slashes");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("", 1);
    is($clean, "", "sanitize_path allows empty path when allow_empty is true");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("", 0);
    ok(!$clean && $err, "sanitize_path rejects empty path when allow_empty is false");

    # Path traversal attempts
    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("../../etc/passwd", 1);
    ok(!$clean && $err =~ /Path traversal/, "sanitize_path rejects leading .. traversal");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("store/../../secret", 1);
    ok(!$clean && $err =~ /Path traversal/, "sanitize_path rejects embedded .. traversal");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("..", 1);
    ok(!$clean && $err =~ /Path traversal/, "sanitize_path rejects bare .. traversal");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog\\..\\evil", 1);
    ok(!$clean && $err =~ /Path traversal/, "sanitize_path rejects backslash traversal");

    # Poison null byte
    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog\0evil", 1);
    ok(!$clean && $err =~ /null byte/, "sanitize_path rejects poison null byte");

    # Command injection characters in path
    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog;rm -rf /", 1);
    ok(!$clean && $err =~ /invalid characters/, "sanitize_path rejects shell metacharacters");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog|cat /etc/shadow", 1);
    ok(!$clean && $err =~ /invalid characters/, "sanitize_path rejects pipe characters");

    ($clean, $err) = VirtualminWebApps::Common::sanitize_path("blog\$(whoami)", 1);
    ok(!$clean && $err =~ /invalid characters/, "sanitize_path rejects command substitution");
}

# 3. Test validate_port
{
    my ($ok, $err) = VirtualminWebApps::Common::validate_port(8080, 1024, 65535);
    ok($ok, "validate_port accepts valid port 8080");

    ($ok, $err) = VirtualminWebApps::Common::validate_port(1024, 1024, 65535);
    ok($ok, "validate_port accepts boundary port 1024");

    ($ok, $err) = VirtualminWebApps::Common::validate_port(65535, 1024, 65535);
    ok($ok, "validate_port accepts boundary port 65535");

    ($ok, $err) = VirtualminWebApps::Common::validate_port(80, 1024, 65535);
    ok(!$ok && $err =~ /out of bounds/, "validate_port rejects port below minimum");

    ($ok, $err) = VirtualminWebApps::Common::validate_port(70000, 1024, 65535);
    ok(!$ok && $err =~ /out of bounds/, "validate_port rejects port above maximum");

    ($ok, $err) = VirtualminWebApps::Common::validate_port("8080; reboot", 1024, 65535);
    ok(!$ok && $err =~ /numeric integer/, "validate_port rejects shell injection in port");

    ($ok, $err) = VirtualminWebApps::Common::validate_port("abc", 1024, 65535);
    ok(!$ok && $err =~ /numeric integer/, "validate_port rejects alphabetic port");

    ($ok, $err) = VirtualminWebApps::Common::validate_port("-1", 1024, 65535);
    ok(!$ok && $err =~ /numeric integer/, "validate_port rejects negative port");
}

# 4. Test validate_domain
{
    my ($ok, $err) = VirtualminWebApps::Common::validate_domain("example.com");
    ok($ok, "validate_domain accepts standard domain");

    ($ok, $err) = VirtualminWebApps::Common::validate_domain("sub.shop-store.co.uk");
    ok($ok, "validate_domain accepts subdomain with hyphen");

    ($ok, $err) = VirtualminWebApps::Common::validate_domain("example.com; rm -rf /");
    ok(!$ok && $err =~ /invalid characters/, "validate_domain rejects command injection");

    ($ok, $err) = VirtualminWebApps::Common::validate_domain("");
    ok(!$ok && $err =~ /must be specified/, "validate_domain rejects empty domain");
}

# 5. Test validate_identifier
{
    my ($ok, $err) = VirtualminWebApps::Common::validate_identifier("valid_db_user_123");
    ok($ok, "validate_identifier accepts alphanumeric and underscore");

    ($ok, $err) = VirtualminWebApps::Common::validate_identifier("user; DROP TABLE users--");
    ok(!$ok && $err =~ /invalid characters/, "validate_identifier rejects SQL injection in identifier");

    ($ok, $err) = VirtualminWebApps::Common::validate_identifier("user name");
    ok(!$ok && $err =~ /invalid characters/, "validate_identifier rejects spaces in identifier");
}

# 6. Test generate_random_key (PCI DSS Req 8.3.6)
{
    my $key1 = VirtualminWebApps::Common::generate_random_key(32);
    is(length($key1), 32, "generate_random_key produces expected 32-char length");

    my $key2 = VirtualminWebApps::Common::generate_random_key(8);
    is(length($key2), 16, "generate_random_key enforces 16-char PCI DSS minimum");

    isnt($key1, $key2, "generate_random_key produces distinct values");
    ok($key1 =~ /[A-Za-z0-9]/, "generate_random_key contains mixed character set");
}

# 7. Test get_arch
{
    my $arch = VirtualminWebApps::Common::get_arch();
    ok($arch && length($arch) > 0, "get_arch returns non-empty architecture ($arch)");
}

# 8. Test has_command
{
    ok(VirtualminWebApps::Common::has_command("perl"), "has_command detects 'perl'");
    ok(!VirtualminWebApps::Common::has_command("nonexistent_command_xyz_123"), "has_command fails on invalid command");
    ok(!VirtualminWebApps::Common::has_command("perl; reboot"), "has_command rejects command injection attempt");
}
