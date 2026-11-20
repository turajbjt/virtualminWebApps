# apps/jellyfin/jellyfin.pl
# Virtualmin Web App installer for Jellyfin Media Server
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

sub script_jellyfin_desc
{
    return "Jellyfin Media Server";
}

sub script_jellyfin_uses
{
    return ( );
}

sub script_jellyfin_category
{
    return "Media";
}

sub script_jellyfin_author
{
    return "Jellyfin Project";
}

sub script_jellyfin_site
{
    return "https://jellyfin.org";
}

sub script_jellyfin_versions
{
    return ( "10.9.11" );
}

sub script_jellyfin_release
{
    return 1;
}

sub script_jellyfin_passmode
{
    return 2;
}

sub script_jellyfin_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8096, 8196) || 8096;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"jellyfin_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the media daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_jellyfin_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'jellyfin_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_jellyfin_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    my $has_jellyfin = VirtualminWebApps::Common::has_command('jellyfin');

    if (!$has_container && !$has_jellyfin) {
        return "Jellyfin requires a container engine (podman/docker) or native jellyfin binary installed.";
    }

    return undef;
}

sub script_jellyfin_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8096;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/jellyfin";
    my $config_dir = "$app_dir/config";
    my $cache_dir = "$app_dir/cache";
    my $media_dir = "$app_dir/media";

    make_path($config_dir, $cache_dir, $media_dir, { mode => 0750 });

    # Generate systemd service
    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'       => $user,
        'APP_DIR'    => $app_dir,
        'CONFIG_DIR' => $config_dir,
        'CACHE_DIR'  => $cache_dir,
        'MEDIA_DIR'  => $media_dir,
        'PORT'       => $port,
        'VERSION'    => $version,
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/jellyfin.service";
    my $service_name = "jellyfin-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 3600,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Jellyfin Media Server v$version successfully installed and reverse proxied on port $port.");
}

1;
