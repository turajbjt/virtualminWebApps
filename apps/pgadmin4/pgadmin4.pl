# apps/pgadmin4/pgadmin4.pl
# Virtualmin Web App installer for pgAdmin 4 PostgreSQL Management
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

sub script_pgadmin4_desc
{
    return "pgAdmin 4 - PostgreSQL Administration & Management Web UI";
}

sub script_pgadmin4_uses
{
    return ( "postgres" );
}

sub script_pgadmin4_category
{
    return "Database";
}

sub script_pgadmin4_author
{
    return "pgAdmin Development Team";
}

sub script_pgadmin4_site
{
    return "https://www.pgadmin.org";
}

sub script_pgadmin4_versions
{
    return ( "8.14" );
}

sub script_pgadmin4_release
{
    return 1;
}

sub script_pgadmin4_passmode
{
    return 2;
}

sub script_pgadmin4_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(5050, 5999) || 5050;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"pgadmin4_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_pgadmin4_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'pgadmin4_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_pgadmin4_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "pgAdmin 4 requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_pgadmin4_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_pgadmin4_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "pgadmin4-$dom";

    my $app_dir = "$d->{'home'}/pgadmin4-data";
    make_path($app_dir) if !-d $app_dir;
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $admin_email = "admin\@$dom";
    my $admin_pass = VirtualminWebApps::Common::generate_random_key(16);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:80 " .
                     "-v $app_dir:/var/lib/pgadmin:Z " .
                     "-e PGADMIN_DEFAULT_EMAIL=$admin_email " .
                     "-e PGADMIN_DEFAULT_PASSWORD=$admin_pass " .
                     "docker.io/dpage/pgadmin4:latest";

    my $service_content = <<"EOF";
[Unit]
Description=pgAdmin 4 PostgreSQL Manager for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$app_dir
ExecStart=$exec_start
ExecStop=/usr/bin/$runtime stop -t 15 $service_name
Restart=always
RestartSec=5s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::create_service_unit($service_name, $service_content);
    return (0, "Failed to create systemd unit: $serr") if !$sok;

    VirtualminWebApps::SystemdHelper::enable_service($service_name);
    VirtualminWebApps::SystemdHelper::start_service($service_name);

    # Configure Reverse Proxy
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "pgadmin4",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    return (
        1,
        $public_url,
        "Installed and started pgAdmin 4 service ($service_name) on port $port reverse-proxied to $public_url (Initial login: $admin_email / $admin_pass)."
    );
}

sub script_pgadmin4_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "pgadmin4-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "pgadmin4");

    my $app_dir = "$d->{'home'}/pgadmin4-data";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
