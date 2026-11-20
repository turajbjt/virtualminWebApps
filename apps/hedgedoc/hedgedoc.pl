# apps/hedgedoc/hedgedoc.pl
# Virtualmin Web App installer for HedgeDoc Collaborative Markdown Notes
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

sub script_hedgedoc_desc
{
    return "HedgeDoc - Realtime Collaborative Markdown Notes";
}

sub script_hedgedoc_uses
{
    return ( );
}

sub script_hedgedoc_category
{
    return "Documents";
}

sub script_hedgedoc_author
{
    return "HedgeDoc Community";
}

sub script_hedgedoc_site
{
    return "https://hedgedoc.org";
}

sub script_hedgedoc_versions
{
    return ( "1.9.9" );
}

sub script_hedgedoc_release
{
    return 1;
}

sub script_hedgedoc_passmode
{
    return 2;
}

sub script_hedgedoc_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3010, 3100) || 3010;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"hedgedoc_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the HedgeDoc daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_hedgedoc_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'hedgedoc_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_hedgedoc_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "HedgeDoc requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_hedgedoc_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 3010;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/hedgedoc";
    my $uploads_dir = "$app_dir/uploads";
    make_path($uploads_dir, { mode => 0750 });

    # Generate session secret
    my $session_secret = VirtualminWebApps::Common::random_password(32);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'           => $user,
        'APP_DIR'        => $app_dir,
        'UPLOADS_DIR'    => $uploads_dir,
        'PORT'           => $port,
        'SESSION_SECRET' => $session_secret,
        'VERSION'        => $version,
        'URL'            => "https://$dom",
        'ENGINE'         => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/hedgedoc.service";
    my $service_name = "hedgedoc-$dom";

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

    return (1, "HedgeDoc v$version successfully installed and reverse proxied on port $port.");
}

1;
