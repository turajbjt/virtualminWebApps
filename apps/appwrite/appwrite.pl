# apps/appwrite/appwrite.pl
# Virtualmin Web App installer for Appwrite Backend-as-a-Service
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

sub script_appwrite_desc
{
    return "Appwrite - Open-Source Backend-as-a-Service Platform";
}

sub script_appwrite_uses
{
    return ( );
}

sub script_appwrite_category
{
    return "Development";
}

sub script_appwrite_author
{
    return "Appwrite Team";
}

sub script_appwrite_site
{
    return "https://appwrite.io";
}

sub script_appwrite_versions
{
    return ( "1.6.0" );
}

sub script_appwrite_release
{
    return 1;
}

sub script_appwrite_passmode
{
    return 2;
}

sub script_appwrite_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8095, 8150) || 8095;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"appwrite_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Appwrite server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_appwrite_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'appwrite_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_appwrite_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Appwrite requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_appwrite_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8095;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/appwrite";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate secrets
    my $app_key = VirtualminWebApps::Common::random_password(32);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'     => $user,
        'APP_DIR'  => $app_dir,
        'DATA_DIR' => $data_dir,
        'PORT'     => $port,
        'APP_KEY'  => $app_key,
        'VERSION'  => $version,
        'URL'      => "https://$dom",
        'ENGINE'   => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/appwrite.service";
    my $service_name = "appwrite-$dom";

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

    return (1, "Appwrite v$version successfully installed and reverse proxied on port $port.");
}

1;
