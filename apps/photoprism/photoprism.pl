# apps/photoprism/photoprism.pl
# Virtualmin Web App installer for PhotoPrism AI Photo Gallery
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

sub script_photoprism_desc
{
    return "PhotoPrism - AI-Powered Photos App & Gallery";
}

sub script_photoprism_uses
{
    return ( );
}

sub script_photoprism_category
{
    return "Media";
}

sub script_photoprism_author
{
    return "PhotoPrism UG";
}

sub script_photoprism_site
{
    return "https://www.photoprism.app";
}

sub script_photoprism_versions
{
    return ( "240915" );
}

sub script_photoprism_release
{
    return 1;
}

sub script_photoprism_passmode
{
    return 2;
}

sub script_photoprism_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(2342, 2400) || 2342;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"photoprism_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the PhotoPrism daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_photoprism_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'photoprism_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_photoprism_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "PhotoPrism requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_photoprism_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 2342;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/photoprism";
    my $storage_dir = "$app_dir/storage";
    my $originals_dir = "$app_dir/originals";
    my $import_dir = "$app_dir/import";

    make_path($storage_dir, $originals_dir, $import_dir, { mode => 0750 });

    # Generate admin password
    my $admin_pass = VirtualminWebApps::Common::random_password(16);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'          => $user,
        'APP_DIR'       => $app_dir,
        'STORAGE_DIR'   => $storage_dir,
        'ORIGINALS_DIR' => $originals_dir,
        'IMPORT_DIR'    => $import_dir,
        'PORT'          => $port,
        'ADMIN_PASS'    => $admin_pass,
        'VERSION'       => $version,
        'URL'           => "https://$dom",
        'ENGINE'        => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/photoprism.service";
    my $service_name = "photoprism-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 600,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "PhotoPrism successfully installed and reverse proxied on port $port. Admin password generated.");
}

1;
