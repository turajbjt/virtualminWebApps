# apps/pairdrop/pairdrop.pl
# Virtualmin Web App installer for PairDrop Local File Sharing
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

sub script_pairdrop_desc
{
    return "PairDrop - Local File Sharing in Your Browser";
}

sub script_pairdrop_uses
{
    return ( );
}

sub script_pairdrop_category
{
    return "Utilities";
}

sub script_pairdrop_author
{
    return "PairDrop Community";
}

sub script_pairdrop_site
{
    return "https://pairdrop.net";
}

sub script_pairdrop_versions
{
    return ( "1.10.8" );
}

sub script_pairdrop_release
{
    return 1;
}

sub script_pairdrop_passmode
{
    return 2;
}

sub script_pairdrop_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3020, 3100) || 3020;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"pairdrop_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the PairDrop daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_pairdrop_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'pairdrop_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_pairdrop_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "PairDrop requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_pairdrop_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 3020;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/pairdrop";
    make_path($app_dir, { mode => 0750 });

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'    => $user,
        'APP_DIR' => $app_dir,
        'PORT'    => $port,
        'VERSION' => $version,
        'URL'     => "https://$dom",
        'ENGINE'  => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/pairdrop.service";
    my $service_name = "pairdrop-$dom";

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

    return (1, "PairDrop v$version successfully installed and reverse proxied on port $port.");
}

1;
