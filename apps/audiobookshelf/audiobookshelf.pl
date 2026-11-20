# apps/audiobookshelf/audiobookshelf.pl
# Virtualmin Web App installer for Audiobookshelf Audiobook & Podcast Server
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

sub script_audiobookshelf_desc
{
    return "Audiobookshelf - Audiobook & Podcast Server";
}

sub script_audiobookshelf_uses
{
    return ( );
}

sub script_audiobookshelf_category
{
    return "Media";
}

sub script_audiobookshelf_author
{
    return "Audiobookshelf Team";
}

sub script_audiobookshelf_site
{
    return "https://www.audiobookshelf.org";
}

sub script_audiobookshelf_versions
{
    return ( "2.19.5" );
}

sub script_audiobookshelf_release
{
    return 1;
}

sub script_audiobookshelf_passmode
{
    return 2;
}

sub script_audiobookshelf_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(13378, 13999) || 13378;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"audiobookshelf_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_audiobookshelf_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'audiobookshelf_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_audiobookshelf_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Audiobookshelf requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_audiobookshelf_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_audiobookshelf_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "audiobookshelf-$dom";

    my $app_dir = "$d->{'home'}/audiobookshelf";
    my $config_dir = "$app_dir/config";
    my $metadata_dir = "$app_dir/metadata";
    my $audiobooks_dir = "$d->{'home'}/audiobooks";
    my $podcasts_dir = "$d->{'home'}/podcasts";

    make_path($app_dir, $config_dir, $metadata_dir, $audiobooks_dir, $podcasts_dir);
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);
    VirtualminWebApps::Common::set_ownership_recursive($audiobooks_dir, $user, $group);
    VirtualminWebApps::Common::set_ownership_recursive($podcasts_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:80 " .
                     "-v $audiobooks_dir:/audiobooks:Z " .
                     "-v $podcasts_dir:/podcasts:Z " .
                     "-v $config_dir:/config:Z " .
                     "-v $metadata_dir:/metadata:Z " .
                     "ghcr.io/advplyr/audiobookshelf:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Audiobookshelf Audiobook & Podcast Server for $dom
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

    # Configure Reverse Proxy with WebSockets
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "audiobookshelf",
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
        "Installed and started Audiobookshelf service ($service_name) on port $port reverse-proxied to $public_url (Initial setup wizard accessible in browser)."
    );
}

sub script_audiobookshelf_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "audiobookshelf-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "audiobookshelf");

    my $app_dir = "$d->{'home'}/audiobookshelf";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
