# apps/miniflux/miniflux.pl
# Virtualmin Web App installer for Miniflux Feed Reader
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

sub script_miniflux_desc
{
    return "Miniflux Minimalist & Opinionated Feed Reader";
}

sub script_miniflux_uses
{
    return ( "postgres" );
}

sub script_miniflux_category
{
    return "News";
}

sub script_miniflux_author
{
    return "Frédéric Guillot";
}

sub script_miniflux_site
{
    return "https://miniflux.app";
}

sub script_miniflux_versions
{
    return ( "2.3.5" );
}

sub script_miniflux_release
{
    return 2;
}

sub script_miniflux_passmode
{
    return 2;
}

sub script_miniflux_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8089, 8999) || 8089;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"miniflux_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_miniflux_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'miniflux_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_miniflux_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Miniflux requires amd64 or arm64 architecture (detected: $arch).";
    }
    if (!$d->{'postgres'}) {
        return "Miniflux requires PostgreSQL to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_miniflux_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "miniflux-linux-$arch";
    my $url = "https://github.com/miniflux/v2/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_miniflux_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "miniflux-$dom";

    my $install_dir = "$d->{'home'}/miniflux";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $bin_name = "miniflux-linux-$arch";
    my $download_url = "https://github.com/miniflux/v2/releases/download/$ver/$bin_name";
    my $bin_path = "$install_dir/miniflux";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $bin_path, 120);
    return (0, "Download failed: $err") if !$ok;
    chmod(0755, $bin_path);

    my $dbname = $defs->{'db'} || ($user . "_miniflux");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || '';
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";
    my $admin_pass = VirtualminWebApps::Common::generate_random_key(16);

    # Create miniflux.env
    my $env_path = "$install_dir/miniflux.env";
    my $env_content = <<"EOF";
LISTEN_ADDR=127.0.0.1:$port
DATABASE_URL=postgres://$dbuser:$dbpass\@localhost/$dbname?sslmode=disable
BASE_URL=$public_url
RUN_MIGRATIONS=1
CREATE_ADMIN=1
ADMIN_USERNAME=admin
ADMIN_PASSWORD=$admin_pass
EOF

    if (open(my $efh, ">", $env_path)) {
        print $efh $env_content;
        close($efh);
        chmod(0600, $env_path);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=Miniflux Feed Reader for $dom
After=network.target postgresql.service
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
EnvironmentFile=$env_path
ExecStart=$bin_path
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
        "miniflux",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    return (
        1,
        $public_url,
        "Installed and started Miniflux service ($service_name) on port $port reverse-proxied to $public_url (Initial login: admin / $admin_pass)."
    );
}

sub script_miniflux_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "miniflux-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "miniflux");

    my $install_dir = "$d->{'home'}/miniflux";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
