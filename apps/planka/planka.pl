# apps/planka/planka.pl
# Virtualmin Web App installer for Planka Realtime Kanban Board
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

sub script_planka_desc
{
    return "Planka - Realtime Collaborative Kanban Board";
}

sub script_planka_uses
{
    return ( );
}

sub script_planka_category
{
    return "Project";
}

sub script_planka_author
{
    return "Planka Team";
}

sub script_planka_site
{
    return "https://planka.app";
}

sub script_planka_versions
{
    return ( "1.22.1" );
}

sub script_planka_release
{
    return 1;
}

sub script_planka_passmode
{
    return 2;
}

sub script_planka_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(1337, 1400) || 1337;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"planka_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Planka Kanban server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_planka_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'planka_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_planka_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Planka requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_planka_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 1337;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/planka";
    my $user_avatars = "$app_dir/avatars";
    my $project_bg = "$app_dir/backgrounds";
    my $attachments = "$app_dir/attachments";

    make_path($user_avatars, $project_bg, $attachments, { mode => 0750 });

    # Generate secret key
    my $secret_key = VirtualminWebApps::Common::random_password(32);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'        => $user,
        'APP_DIR'     => $app_dir,
        'AVATARS'     => $user_avatars,
        'BACKGROUNDS' => $project_bg,
        'ATTACHMENTS' => $attachments,
        'PORT'        => $port,
        'SECRET_KEY'  => $secret_key,
        'VERSION'     => $version,
        'URL'         => "https://$dom",
        'ENGINE'      => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/planka.service";
    my $service_name = "planka-$dom";

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

    return (1, "Planka Kanban Board v$version successfully installed and reverse proxied on port $port.");
}

1;
