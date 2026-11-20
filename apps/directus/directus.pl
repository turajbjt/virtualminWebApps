# apps/directus/directus.pl
# Virtualmin Web App installer for Directus Headless CMS & Backend
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

sub script_directus_desc
{
    return "Directus - Instant REST & GraphQL API and Headless CMS";
}

sub script_directus_uses
{
    return ( );
}

sub script_directus_category
{
    return "CMS";
}

sub script_directus_author
{
    return "Directus Team";
}

sub script_directus_site
{
    return "https://directus.io";
}

sub script_directus_versions
{
    return ( "11.1.1" );
}

sub script_directus_release
{
    return 1;
}

sub script_directus_passmode
{
    return 2;
}

sub script_directus_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8055, 8150) || 8055;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"directus_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Directus daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_directus_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'directus_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_directus_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Directus requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_directus_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8055;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/directus";
    my $data_dir = "$app_dir/data";
    my $uploads_dir = "$app_dir/uploads";
    my $extensions_dir = "$app_dir/extensions";

    make_path($data_dir, $uploads_dir, $extensions_dir, { mode => 0750 });

    # Generate secrets
    my $secret = VirtualminWebApps::Common::random_password(32);
    my $admin_pass = VirtualminWebApps::Common::random_password(16);
    my $admin_email = "admin\@$dom";

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'           => $user,
        'APP_DIR'        => $app_dir,
        'DATA_DIR'       => $data_dir,
        'UPLOADS_DIR'    => $uploads_dir,
        'EXTENSIONS_DIR' => $extensions_dir,
        'PORT'           => $port,
        'SECRET'         => $secret,
        'ADMIN_EMAIL'    => $admin_email,
        'ADMIN_PASS'     => $admin_pass,
        'VERSION'        => $version,
        'URL'            => "https://$dom",
        'ENGINE'         => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/directus.service";
    my $service_name = "directus-$dom";

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

    return (1, "Directus v$version successfully installed and reverse proxied on port $port. Admin: $admin_email.");
}

1;
