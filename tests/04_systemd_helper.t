#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;

my $base_dir = dirname(__FILE__) . "/..";
unshift @INC, "$base_dir/lib";
require "SystemdHelper.pl";

plan tests => 10;

# 1. validate_service_name
ok(VirtualminWebApps::SystemdHelper::validate_service_name("navidrome-example.com"), "validate_service_name accepts standard name");
ok(VirtualminWebApps::SystemdHelper::validate_service_name("mattermost_test.service"), "validate_service_name accepts name with .service suffix");
ok(!VirtualminWebApps::SystemdHelper::validate_service_name("../../evil.service"), "validate_service_name rejects path traversal");
ok(!VirtualminWebApps::SystemdHelper::validate_service_name("test; rm -rf /"), "validate_service_name rejects shell metacharacters");
ok(!VirtualminWebApps::SystemdHelper::validate_service_name("service|bash"), "validate_service_name rejects pipe character");
ok(!VirtualminWebApps::SystemdHelper::validate_service_name(""), "validate_service_name rejects empty name");
ok(!VirtualminWebApps::SystemdHelper::validate_service_name(undef), "validate_service_name handles undef safely");

# 2. create_service_unit security check
my ($ok, $err) = VirtualminWebApps::SystemdHelper::create_service_unit("../../etc/cron.d/pwn", "dummy");
ok(!$ok && $err =~ /Invalid or insecure/, "create_service_unit rejects path traversal in service name");

# 3. install_service_unit alias
($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_unit("; evil_cmd", "dummy");
ok(!$ok && $err =~ /Invalid or insecure/, "install_service_unit alias rejects shell injection in service name");

# 4. Service action security check
my ($sok, $serr) = VirtualminWebApps::SystemdHelper::start_service("; reboot");
ok(!$sok && $serr =~ /Invalid service name/, "start_service rejects command injection in service name");
