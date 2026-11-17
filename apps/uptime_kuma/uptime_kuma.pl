# apps/uptime_kuma/uptime_kuma.pl
# Virtualmin Web App installer for Uptime Kuma Monitoring Dashboard
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);

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

sub script_uptime_kuma_desc
{
    return "Uptime Kuma Monitoring & Status Pages";
}

sub script_uptime_kuma_uses
{
    return ( );
}

sub script_uptime_kuma_category
{
    return "System";
}

sub script_uptime_kuma_author
{
    return "Louis Lam / Uptime Kuma Community";
}

sub script_uptime_kuma_site
{
    return "https://uptime.kuma.pet";
}

sub script_uptime_kuma_versions
{
    return ( "latest" );
}

sub script_uptime_kuma_release
{
    return 1;
}

sub script_uptime_kuma_passmode
{
    return 2; # Web app handles account creation internally
}

sub script_uptime_kuma_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3001, 3999) || 3001;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"kuma_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the backend daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_uptime_kuma_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'kuma_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return {
        'port' => $port,
    };
}

sub script_uptime_kuma_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Uptime Kuma runs as an isolated daemon via container runtime. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io').";
    }

    return undef;
}

sub script_uptime_kuma_files
{
    return ();
}

sub script_uptime_kuma_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "uptime-kuma-$dom";

    my $data_dir = "$d->{'home'}/uptime-kuma-data";
    make_path($data_dir) if !-d $data_dir;
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:3001 " .
                     "-v $data_dir:/app/data:Z " .
                     "docker.io/louislam/uptime-kuma:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Uptime Kuma Monitoring Service for $dom
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

    # Configure Reverse Proxy with WebSocket support (required for socket.io)
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "uptime_kuma",
        $port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (1, "$proto://$dom/", "Installed Uptime Kuma listening on internal port $port and reverse-proxied to $proto://$dom/");
}

sub script_uptime_kuma_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "uptime-kuma-$dom";

    system("podman stop $service_name 2>/dev/null || docker stop $service_name 2>/dev/null || true");
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "uptime_kuma");

    return 1;
}

1;
