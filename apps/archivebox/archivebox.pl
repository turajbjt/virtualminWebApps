# apps/archivebox/archivebox.pl
# Virtualmin Web App installer for ArchiveBox Web Archiver
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

sub script_archivebox_desc
{
    return "ArchiveBox - Open-Source Self-Hosted Web Archiving";
}

sub script_archivebox_uses
{
    return ( );
}

sub script_archivebox_category
{
    return "Utilities";
}

sub script_archivebox_author
{
    return "Nick Sweeting & ArchiveBox Contributors";
}

sub script_archivebox_site
{
    return "https://archivebox.io";
}

sub script_archivebox_versions
{
    return ( "0.7.2" );
}

sub script_archivebox_release
{
    return 1;
}

sub script_archivebox_passmode
{
    return 2;
}

sub script_archivebox_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8020, 8100) || 8020;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"archivebox_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the ArchiveBox daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_archivebox_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'archivebox_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_archivebox_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "ArchiveBox requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_archivebox_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8020;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/archivebox";
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
        'URL'        => "https://$dom",
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/archivebox.service";
    my $service_name = "archivebox-$dom";

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

    return (1, "ArchiveBox v$version successfully installed and reverse proxied on port $port.");
}

1;
