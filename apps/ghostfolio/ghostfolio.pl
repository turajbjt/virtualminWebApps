# apps/ghostfolio/ghostfolio.pl
# Virtualmin Web App installer for Ghostfolio Wealth Management Dashboard
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

sub script_ghostfolio_desc
{
    return "Ghostfolio - Open-Source Wealth Management Dashboard";
}

sub script_ghostfolio_uses
{
    return ( );
}

sub script_ghostfolio_category
{
    return "Finance";
}

sub script_ghostfolio_author
{
    return "Ghostfolio Community";
}

sub script_ghostfolio_site
{
    return "https://ghostfol.io";
}

sub script_ghostfolio_versions
{
    return ( "2.133.0" );
}

sub script_ghostfolio_release
{
    return 1;
}

sub script_ghostfolio_passmode
{
    return 2;
}

sub script_ghostfolio_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3333, 3400) || 3333;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"ghostfolio_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Ghostfolio server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_ghostfolio_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'ghostfolio_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_ghostfolio_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Ghostfolio requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_ghostfolio_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 3333;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/ghostfolio";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate secrets
    my $jwt_secret = VirtualminWebApps::Common::random_password(32);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'       => $user,
        'APP_DIR'    => $app_dir,
        'DATA_DIR'   => $data_dir,
        'PORT'       => $port,
        'JWT_SECRET' => $jwt_secret,
        'VERSION'    => $version,
        'URL'        => "https://$dom",
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/ghostfolio.service";
    my $service_name = "ghostfolio-$dom";

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

    return (1, "Ghostfolio v$version successfully installed and reverse proxied on port $port.");
}

1;
