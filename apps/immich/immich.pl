# apps/immich/immich.pl
# Virtualmin Web App installer for Immich Photo & Video Management
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

sub script_immich_desc
{
    return "Immich - High-Performance Photo & Video Management";
}

sub script_immich_uses
{
    return ( );
}

sub script_immich_category
{
    return "Media";
}

sub script_immich_author
{
    return "Immich Team";
}

sub script_immich_site
{
    return "https://immich.app";
}

sub script_immich_versions
{
    return ( "1.121.0" );
}

sub script_immich_release
{
    return 1;
}

sub script_immich_passmode
{
    return 2;
}

sub script_immich_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(2283, 2350) || 2283;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"immich_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Immich server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_immich_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'immich_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_immich_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Immich requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_immich_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 2283;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/immich";
    my $library_dir = "$app_dir/library";
    my $upload_dir = "$app_dir/upload";

    make_path($library_dir, $upload_dir, { mode => 0750 });

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'        => $user,
        'APP_DIR'     => $app_dir,
        'LIBRARY_DIR' => $library_dir,
        'UPLOAD_DIR'  => $upload_dir,
        'PORT'        => $port,
        'VERSION'     => "v$version",
        'URL'         => "https://$dom",
        'ENGINE'      => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/immich.service";
    my $service_name = "immich-$dom";

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

    return (1, "Immich v$version successfully installed and reverse proxied on port $port.");
}

1;
