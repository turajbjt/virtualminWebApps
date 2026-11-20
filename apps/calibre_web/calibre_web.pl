# apps/calibre_web/calibre_web.pl
# Virtualmin Web App installer for Calibre-Web eBook Reader & Library
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

sub script_calibre_web_desc
{
    return "Calibre-Web - eBook Library & Web Reader";
}

sub script_calibre_web_uses
{
    return ( );
}

sub script_calibre_web_category
{
    return "Media";
}

sub script_calibre_web_author
{
    return "Ozzie Isaacs / Calibre-Web Community";
}

sub script_calibre_web_site
{
    return "https://github.com/janeczku/calibre-web";
}

sub script_calibre_web_versions
{
    return ( "0.6.24" );
}

sub script_calibre_web_release
{
    return 1;
}

sub script_calibre_web_passmode
{
    return 2;
}

sub script_calibre_web_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8083, 8999) || 8083;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"calibre_web_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_calibre_web_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'calibre_web_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_calibre_web_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Calibre-Web requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_calibre_web_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_calibre_web_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "calibre-web-$dom";

    my $app_dir = "$d->{'home'}/calibre-web";
    my $config_dir = "$app_dir/config";
    my $books_dir = "$app_dir/books";

    make_path($app_dir, $config_dir, $books_dir);
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:8083 " .
                     "-v $config_dir:/config:Z " .
                     "-v $books_dir:/books:Z " .
                     "-e DOCKER_MODS=linuxserver/mods:universal-calibre " .
                     "docker.io/linuxserver/calibre-web:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Calibre-Web Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$app_dir
ExecStart=$exec_start
ExecStop=/usr/bin/$runtime stop -t 10 $service_name
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
        "calibre_web",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    return (
        1,
        $public_url,
        "Installed and started Calibre-Web service ($service_name) on port $port reverse-proxied to $public_url (Default login: admin / admin123)."
    );
}

sub script_calibre_web_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "calibre-web-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "calibre_web");

    my $app_dir = "$d->{'home'}/calibre-web";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
