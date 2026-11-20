# apps/linkding/linkding.pl
# Virtualmin Web App installer for Linkding Bookmark Manager
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

sub script_linkding_desc
{
    return "Linkding - Minimal Self-Hosted Bookmark Manager";
}

sub script_linkding_uses
{
    return ( );
}

sub script_linkding_category
{
    return "Utilities";
}

sub script_linkding_author
{
    return "sissbruecker & Contributors";
}

sub script_linkding_site
{
    return "https://github.com/sissbruecker/linkding";
}

sub script_linkding_versions
{
    return ( "1.38.1" );
}

sub script_linkding_release
{
    return 1;
}

sub script_linkding_passmode
{
    return 2;
}

sub script_linkding_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(9090, 9150) || 9090;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"linkding_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Linkding daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_linkding_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'linkding_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_linkding_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Linkding requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_linkding_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 9090;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/linkding";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate admin password
    my $admin_user = "admin";
    my $admin_pass = VirtualminWebApps::Common::random_password(16);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'       => $user,
        'APP_DIR'    => $app_dir,
        'DATA_DIR'   => $data_dir,
        'PORT'       => $port,
        'ADMIN_USER' => $admin_user,
        'ADMIN_PASS' => $admin_pass,
        'VERSION'    => $version,
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/linkding.service";
    my $service_name = "linkding-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 120,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Linkding v$version successfully installed and reverse proxied on port $port. Admin password generated.");
}

1;
