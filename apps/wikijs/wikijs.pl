# apps/wikijs/wikijs.pl
# Virtualmin Web App installer for Wiki.js Modern Documentation Platform
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

sub script_wikijs_desc
{
    return "Wiki.js - Modern Documentation & Wiki Platform";
}

sub script_wikijs_uses
{
    return ( );
}

sub script_wikijs_category
{
    return "Wiki";
}

sub script_wikijs_author
{
    return "Requarks.io / Wiki.js Community";
}

sub script_wikijs_site
{
    return "https://js.wiki";
}

sub script_wikijs_versions
{
    return ( "2.5.303" );
}

sub script_wikijs_release
{
    return 1;
}

sub script_wikijs_passmode
{
    return 2;
}

sub script_wikijs_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3000, 3999) || 3000;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"wikijs_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_wikijs_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'wikijs_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_wikijs_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Wiki.js requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_wikijs_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_wikijs_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "wikijs-$dom";

    my $app_dir = "$d->{'home'}/wikijs-data";
    make_path($app_dir) if !-d $app_dir;
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:3000 " .
                     "-v $app_dir:/wiki/data/content:Z " .
                     "-e DB_TYPE=sqlite " .
                     "-e DB_FILEPATH=/wiki/data/content/wiki.sqlite " .
                     "ghcr.io/requarks/wiki:2";

    my $service_content = <<"EOF";
[Unit]
Description=Wiki.js Documentation Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$app_dir
ExecStart=$exec_start
ExecStop=/usr/bin/$runtime stop -t 15 $service_name
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

    # Configure Reverse Proxy with WebSockets
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "wikijs",
        $port,
        1,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    return (
        1,
        $public_url,
        "Installed and started Wiki.js service ($service_name) on port $port reverse-proxied to $public_url (Access in browser to initialize administrator account)."
    );
}

sub script_wikijs_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "wikijs-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "wikijs");

    my $app_dir = "$d->{'home'}/wikijs-data";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
