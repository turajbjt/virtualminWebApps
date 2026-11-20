# apps/romm/romm.pl
# Virtualmin Web App installer for RomM Retro Video Game Library Manager
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

sub script_romm_desc
{
    return "RomM - Retro Video Game ROM Library Manager";
}

sub script_romm_uses
{
    return ( );
}

sub script_romm_category
{
    return "Media";
}

sub script_romm_author
{
    return "RomM Team";
}

sub script_romm_site
{
    return "https://github.com/rommapp/romm";
}

sub script_romm_versions
{
    return ( "3.7.2" );
}

sub script_romm_release
{
    return 1;
}

sub script_romm_passmode
{
    return 2;
}

sub script_romm_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8070, 8150) || 8070;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"romm_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the RomM server daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_romm_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'romm_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_romm_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "RomM requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_romm_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8070;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/romm";
    my $roms_dir = "$app_dir/library/roms";
    my $resources_dir = "$app_dir/resources";
    my $config_dir = "$app_dir/config";

    make_path($roms_dir, $resources_dir, $config_dir, { mode => 0750 });

    # Generate secret key
    my $romm_auth_secret = VirtualminWebApps::Common::random_password(32);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'          => $user,
        'APP_DIR'       => $app_dir,
        'ROMS_DIR'      => $roms_dir,
        'RESOURCES_DIR' => $resources_dir,
        'CONFIG_DIR'    => $config_dir,
        'PORT'          => $port,
        'AUTH_SECRET'   => $romm_auth_secret,
        'VERSION'       => $version,
        'URL'           => "https://$dom",
        'ENGINE'        => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/romm.service";
    my $service_name = "romm-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 300,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "RomM v$version successfully installed and reverse proxied on port $port.");
}

1;
