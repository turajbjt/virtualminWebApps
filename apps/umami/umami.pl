# apps/umami/umami.pl
# Virtualmin Web App installer for Umami Privacy Analytics
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

# Include shared libraries
BEGIN {
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";
require "PortManager.pl";
require "SystemdHelper.pl";
require "ProxyHelper.pl";

sub script_umami_desc
{
    return "Umami Lightweight Privacy Analytics";
}

sub script_umami_uses
{
    return ( "mysql" );
}

sub script_umami_category
{
    return "Analytics";
}

sub script_umami_author
{
    return "Umami Software";
}

sub script_umami_site
{
    return "https://umami.is";
}

sub script_umami_versions
{
    return ( "latest" );
}

sub script_umami_release
{
    return 2;
}

sub script_umami_passmode
{
    return 2;
}

sub script_umami_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3002, 3999) || 3002;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"umami_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Umami daemon)</td> </tr>";

    return $html;
}

sub script_umami_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'umami_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_umami_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Umami runs in an isolated container environment. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io').";
    }

    if (!$d->{'mysql'}) {
        return "Umami requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_umami_files
{
    return ();
}

sub script_umami_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "umami-$dom";

    my $data_dir = "$d->{'home'}/umami-data";
    make_path($data_dir) if !-d $data_dir;
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_umami");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1";

    my $db_url = "mysql://$dbuser:$dbpass\@$dbhost:3306/$dbname";
    my $app_secret = join('', map { ('a'..'z','0'..'9')[rand 36] } 1..32);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:3000 " .
                     "-e DATABASE_URL=" . quotemeta($db_url) . " " .
                     "-e APP_SECRET=" . quotemeta($app_secret) . " " .
                     "docker.io/ghcr.io/umami-software/umami:mysql-latest";

    my $service_content = <<"EOF";
[Unit]
Description=Umami Analytics Service for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$data_dir
ExecStart=$exec_start
Restart=always
RestartSec=5s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::create_service_unit($service_name, $service_content);
    return (0, "Failed to create systemd unit: $serr") if !$sok;

    VirtualminWebApps::SystemdHelper::enable_service($service_name);
    VirtualminWebApps::SystemdHelper::start_service($service_name);

    # Configure Reverse Proxy
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "umami",
        $port,
        0,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (
        1,
        "$proto://$dom/",
        "Installed Umami listening on port $port and reverse-proxied to $proto://$dom/. Default login: admin / umami"
    );
}

sub script_umami_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "umami-$dom";

    system("podman stop $service_name 2>/dev/null || docker stop $service_name 2>/dev/null || true");
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "umami");

    return 1;
}

1;
