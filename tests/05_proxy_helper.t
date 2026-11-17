#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;

my $base_dir = dirname(__FILE__) . "/..";
unshift @INC, "$base_dir/lib";
require "Common.pl";
require "ProxyHelper.pl";

plan tests => 9;

# 1. strip_block testing
my $initial_conf = <<"EOF";
<VirtualHost *:80>
ServerName example.com
# BEGIN VIRTUALMIN WEBAPP: testapp
ProxyPass / http://127.0.0.1:8080/
# END VIRTUALMIN WEBAPP: testapp
DocumentRoot /var/www/html
</VirtualHost>
EOF

my $stripped = VirtualminWebApps::ProxyHelper::strip_block($initial_conf, "testapp");
ok($stripped !~ /ProxyPass/, "strip_block successfully removes target app block");
ok($stripped =~ /DocumentRoot/, "strip_block preserves surrounding VirtualHost directives");

# 2. Input validation in setup_reverse_proxy
my ($ok, $err) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
    { 'dom' => 'example.com' }, "testapp", 99999, 0, "/"
);
ok(!$ok && $err =~ /Invalid reverse proxy target port/, "setup_reverse_proxy rejects out-of-bounds port 99999");

($ok, $err) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
    { 'dom' => 'example.com' }, "testapp", "8080; evil", 0, "/"
);
ok(!$ok && $err =~ /Invalid reverse proxy target port/, "setup_reverse_proxy rejects shell injection in port");

# 3. HTTP response splitting / CRLF injection defense in path
($ok, $err) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
    { 'dom' => 'example.com' }, "testapp", 8080, 0, "/app\r\nInjected-Header: evil"
);
ok(!$ok && $err =~ /Insecure path rejected/, "setup_reverse_proxy rejects CRLF injection in path");

# 4. detect_webserver
my $apache_ws = VirtualminWebApps::ProxyHelper::detect_webserver({ 'dom' => 'example.com' });
is($apache_ws, "apache", "detect_webserver defaults to apache");

my $nginx_ws = VirtualminWebApps::ProxyHelper::detect_webserver({ 'dom' => 'example.com', 'nginx' => 1 });
is($nginx_ws, "nginx", "detect_webserver detects nginx when flag is set");

my $mode_nginx = VirtualminWebApps::ProxyHelper::detect_webserver({ 'dom' => 'example.com', 'proxy_pass_mode' => 'nginx' });
is($mode_nginx, "nginx", "detect_webserver detects nginx proxy_pass_mode");

# 5. add_reverse_proxy alias signature verification
($ok, $err) = VirtualminWebApps::ProxyHelper::add_reverse_proxy(
    domain_name => 'example.com',
    local_port  => 99999,
    path        => '/',
);
ok(!$ok && $err =~ /Invalid reverse proxy target port/, "add_reverse_proxy alias parses named arguments correctly");
