# apps/pihole/pihole.pl
# Virtualmin Web App installer for Pi-hole DNS Ad Blocker
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

sub script_pihole_desc
{
    return "Pi-hole Network-wide Ad Blocker";
}

sub script_pihole_uses
{
    return ( );
}

sub script_pihole_category
{
    return "System";
}

sub script_pihole_author
{
    return "Pi-hole Community";
}

sub script_pihole_site
{
    return "https://pi-hole.net";
}

sub script_pihole_versions
{
    return ( "latest" );
}

sub script_pihole_release
{
    return 1;
}

sub script_pihole_passmode
{
    return 0; # Web admin password
}

sub script_pihole_params
{
    my ($d) = @_;
    my $default_web_port = VirtualminWebApps::PortManager::find_free_port(8080, 8999) || 8080;

    my $html = "";
    $html .= "<tr> <td><b>Web Admin Port</b></td> <td>";
    $html .= "<input name=\"pihole_web_port\" size=\"6\" value=\"$default_web_port\"> ";
    $html .= "(Internal port for Pi-hole web interface, automatically reverse-proxied)</td> </tr>";

    $html .= "<tr> <td><b>DNS Port</b></td> <td>";
    $html .= "<input name=\"pihole_dns_port\" size=\"6\" value=\"53\"> ";
    $html .= "(Default: 53. If BIND runs on 53, select alternate port)</td> </tr>";

    $html .= "<tr> <td><b>Web Admin Password</b></td> <td>";
    $html .= "<input name=\"pihole_web_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Password for Pi-hole admin console. Leave empty to auto-generate)</td> </tr>";

    return $html;
}

sub script_pihole_parse
{
    my ($d, $in) = @_;
    my $web_port = $in->{'pihole_web_port'};
    my $dns_port = $in->{'pihole_dns_port'} || 53;

    if ($web_port !~ /^\d+$/ || $web_port < 1024 || $web_port > 65535) {
        return "Web admin port must be a valid number between 1024 and 65535";
    }

    my $pass = $in->{'pihole_web_pass'};
    if (!$pass) {
        my @chars = ('A'..'Z', 'a'..'z', '0'..'9', '!', '@', '#', '%');
        $pass = join '', map { $chars[rand @chars] } 1..16;
    }

    return {
        'web_port' => $web_port,
        'dns_port' => $dns_port,
        'pass'     => $pass,
    };
}

sub script_pihole_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Pi-hole on Virtualmin runs inside an isolated container to protect system web and DNS services. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io').";
    }

    return undef;
}

sub script_pihole_files
{
    return ();
}

sub script_pihole_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $web_port = $opts->{'web_port'};
    my $dns_port = $opts->{'dns_port'};
    my $web_pass = $opts->{'pass'};
    my $service_name = "pihole-$dom";

    my $data_dir = "$d->{'home'}/pihole-data";
    my $etc_pihole = "$data_dir/etc-pihole";
    my $etc_dnsmasq = "$data_dir/etc-dnsmasq.d";
    make_path($etc_pihole, $etc_dnsmasq);
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$web_port:80 " .
                     "-p $dns_port:53/tcp -p $dns_port:53/udp " .
                     "-e WEBPASSWORD=" . quotemeta($web_pass) . " " .
                     "-e VIRTUAL_HOST=" . quotemeta($dom) . " " .
                     "-v $etc_pihole:/etc/pihole:Z " .
                     "-v $etc_dnsmasq:/etc/dnsmasq.d:Z " .
                     "docker.io/pihole/pihole:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Pi-hole DNS Ad Blocker for $dom
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
        "pihole",
        $web_port,
        0,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (1, "$proto://$dom/admin/", "Installed Pi-hole service listening on web port $web_port (DNS port $dns_port). Admin URL: $proto://$dom/admin/ (Password: $web_pass)");
}

sub script_pihole_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "pihole-$dom";

    system("podman stop $service_name 2>/dev/null || docker stop $service_name 2>/dev/null || true");
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "pihole");

    return 1;
}

1;
