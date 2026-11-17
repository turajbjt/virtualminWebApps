# apps/netdata/netdata.pl
# Virtualmin Web App installer for Netdata
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

use Cwd qw(abs_path);

# Include shared libraries
BEGIN {
    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $dir = dirname($real_file);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";
require "PortManager.pl";
require "SystemdHelper.pl";
require "ProxyHelper.pl";

sub script_netdata_desc
{
    return "Netdata - Real-Time Infrastructure Performance Monitor";
}

sub script_netdata_uses
{
    return ();
}

sub script_netdata_category
{
    return "System";
}

sub script_netdata_author
{
    return "Netdata Inc.";
}

sub script_netdata_site
{
    return "https://www.netdata.cloud";
}

sub script_netdata_versions
{
    return ( "latest" );
}

sub script_netdata_release
{
    return 3;
}

sub script_netdata_passmode
{
    return 0;
}

sub script_netdata_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::allocate_port($d, 19999);
    my $html = "";

    $html .= "<tr> <td><b>Backend Port</b></td> <td>";
    $html .= "<input name=\"netdata_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Internal port for Netdata daemon)</td> </tr>";

    return $html;
}

sub script_netdata_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'netdata_port'} || VirtualminWebApps::PortManager::find_free_port(19999, 20999) || 19999;
    my ($port_ok, $port_err) = VirtualminWebApps::Common::validate_port($port, 1024, 65535);
    return $port_err if !$port_ok;
    return { 'port' => $port };
}

sub script_netdata_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Netdata runs as an isolated daemon via container runtime. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io').";
    }

    return undef;
}

sub script_netdata_files
{
    return ();
}

sub script_netdata_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "netdata-$dom";

    my $config_dir = "$d->{'home'}/netdata-config";
    my $lib_dir = "$d->{'home'}/netdata-lib";
    my $cache_dir = "$d->{'home'}/netdata-cache";

    make_path($config_dir) if !-d $config_dir;
    make_path($lib_dir) if !-d $lib_dir;
    make_path($cache_dir) if !-d $cache_dir;

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:19999 " .
                     "-v $config_dir:/etc/netdata:Z " .
                     "-v $lib_dir:/var/lib/netdata:Z " .
                     "-v $cache_dir:/var/cache/netdata:Z " .
                     "-v /etc/passwd:/host/etc/passwd:ro " .
                     "-v /etc/group:/host/etc/group:ro " .
                     "-v /proc:/host/proc:ro " .
                     "-v /sys:/host/sys:ro " .
                     "-v /etc/os-release:/host/etc/os-release:ro " .
                     "--cap-add SYS_PTRACE --security-opt apparmor=unconfined " .
                     "docker.io/netdata/netdata:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Netdata Performance Monitoring Service for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$config_dir
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

    # Configure Reverse Proxy with WebSocket support
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "netdata",
        $port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (1, "$proto://$dom/", "Installed Netdata monitoring dashboard listening on internal port $port and reverse-proxied to $proto://$dom/");
}

sub script_netdata_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "netdata-$dom";

    system("podman stop $service_name 2>/dev/null || docker stop $service_name 2>/dev/null || true");
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "netdata");

    return 1;
}

1;
