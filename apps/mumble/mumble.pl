# apps/mumble/mumble.pl
# Virtualmin Web App installer for Mumble Voice Chat Server
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

sub script_mumble_desc
{
    return "Mumble - Low-Latency Voice Chat Server (Murmur)";
}

sub script_mumble_uses
{
    return ( );
}

sub script_mumble_category
{
    return "Chat";
}

sub script_mumble_author
{
    return "Mumble Community";
}

sub script_mumble_site
{
    return "https://www.mumble.info";
}

sub script_mumble_versions
{
    return ( "1.5.634" );
}

sub script_mumble_release
{
    return 1;
}

sub script_mumble_passmode
{
    return 2;
}

sub script_mumble_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(64738, 64800) || 64738;

    my $html = "";
    $html .= "<tr> <td><b>Voice Server Port</b></td> <td>";
    $html .= "<input name=\"mumble_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(TCP/UDP port for the Mumble/Murmur voice server daemon)</td> </tr>";

    return $html;
}

sub script_mumble_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'mumble_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Voice server port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_mumble_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_murmur = VirtualminWebApps::Common::has_command('murmurd') ||
                     VirtualminWebApps::Common::has_command('mumble-server');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_murmur && !$has_container) {
        return "Mumble requires murmurd/mumble-server or a container runtime (podman/docker).";
    }

    return undef;
}

sub script_mumble_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 64738;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/mumble";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate superuser password
    my $super_pass = VirtualminWebApps::Common::random_password(16);

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'       => $user,
        'APP_DIR'    => $app_dir,
        'DATA_DIR'   => $data_dir,
        'PORT'       => $port,
        'SUPER_PASS' => $super_pass,
        'VERSION'    => "v$version",
        'URL'        => "https://$dom",
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/mumble.service";
    my $service_name = "mumble-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    return (1, "Mumble Voice Server (Murmur) v$version successfully installed on port $port. SuperUser password generated.");
}

1;
