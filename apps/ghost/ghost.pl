# apps/ghost/ghost.pl
# Virtualmin Web App installer for Ghost Modern Publishing Platform
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

sub script_ghost_desc
{
    return "Ghost - Modern Publishing & Newsletters";
}

sub script_ghost_uses
{
    return ( "mysql" );
}

sub script_ghost_category
{
    return "Blog";
}

sub script_ghost_author
{
    return "Ghost Foundation";
}

sub script_ghost_site
{
    return "https://ghost.org";
}

sub script_ghost_versions
{
    return ( "5-alpine", "latest" );
}

sub script_ghost_release
{
    return 3;
}

sub script_ghost_passmode
{
    return 2; # Web app handles account setup at /ghost
}

sub script_ghost_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(2368, 2999) || 2368;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"ghost_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Ghost Node.js daemon)</td> </tr>";

    return $html;
}

sub script_ghost_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'ghost_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_ghost_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Ghost runs in an isolated container environment to ensure Node.js runtime isolation. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io').";
    }

    if (!$d->{'mysql'}) {
        return "Ghost requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_ghost_files
{
    return ();
}

sub script_ghost_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "ghost-$dom";

    my $data_dir = "$d->{'home'}/ghost-content";
    make_path($data_dir) if !-d $data_dir;
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_ghost");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1";

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom/";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:2368 " .
                     "-e url=" . quotemeta($full_url) . " " .
                     "-e database__client=mysql " .
                     "-e database__connection__host=" . quotemeta($dbhost) . " " .
                     "-e database__connection__user=" . quotemeta($dbuser) . " " .
                     "-e database__connection__password=" . quotemeta($dbpass) . " " .
                     "-e database__connection__database=" . quotemeta($dbname) . " " .
                     "-v $data_dir:/var/lib/ghost/content:Z " .
                     "docker.io/ghost:$ver";

    my $service_content = <<"EOF";
[Unit]
Description=Ghost Publishing Service for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$data_dir
ExecStart=$exec_start
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
        "ghost",
        $port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    return (
        1,
        $full_url,
        "Installed Ghost listening on port $port and reverse-proxied to $full_url. Set up admin profile at $full_url" . "ghost/"
    );
}

sub script_ghost_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "ghost-$dom";

    system("podman stop $service_name 2>/dev/null || docker stop $service_name 2>/dev/null || true");
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "ghost");

    return 1;
}

1;
