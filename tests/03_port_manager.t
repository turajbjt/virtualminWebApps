#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;

my $base_dir = dirname(__FILE__) . "/..";
unshift @INC, "$base_dir/lib";
require "PortManager.pl";

plan tests => 8;

# 1. Invalid port inputs to is_port_in_use
ok(VirtualminWebApps::PortManager::is_port_in_use("invalid_port") == 1, "is_port_in_use rejects non-numeric port");
ok(VirtualminWebApps::PortManager::is_port_in_use(-10) == 1, "is_port_in_use rejects negative port");
ok(VirtualminWebApps::PortManager::is_port_in_use(999999) == 1, "is_port_in_use rejects port > 65535");
ok(VirtualminWebApps::PortManager::is_port_in_use(undef) == 1, "is_port_in_use handles undef port safely");

# 2. find_free_port behavior
my $port = VirtualminWebApps::PortManager::find_free_port(18000, 18100);
ok(defined($port), "find_free_port found an available port in range");
ok($port >= 18000 && $port <= 18100, "find_free_port returned port within requested bounds ($port)");

# 3. Boundary handling
my $safe_port = VirtualminWebApps::PortManager::find_free_port("not_a_number", "invalid");
ok(defined($safe_port), "find_free_port safely falls back on invalid port bounds");
ok($safe_port >= 1024 && $safe_port <= 65535, "find_free_port fallback is within valid port range");
