# apps/forgejo/forgejo.pl
# Virtualmin Web App installer for Forgejo Lightweight Git Service
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

sub script_forgejo_desc
{
    return "Forgejo Self-Hosted Git Service";
}

sub script_forgejo_uses
{
    return ( "mysql" );
}

sub script_forgejo_category
{
    return "Development";
}

sub script_forgejo_author
{
    return "Forgejo Community";
}

sub script_forgejo_site
{
    return "https://forgejo.org";
}

sub script_forgejo_versions
{
    return ( "17.0.1", "9.0.0" );
}

sub script_forgejo_release
{
    return 2;
}

sub script_forgejo_passmode
{
    return 2; # Web app handles account creation on initial setup
}

sub script_forgejo_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3000, 3999) || 3000;
    my $default_ssh = VirtualminWebApps::PortManager::find_free_port(2222, 2999) || 2222;

    my $html = "";
    $html .= "<tr> <td><b>HTTP Port</b></td> <td>";
    $html .= "<input name=\"forgejo_http_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Internal TCP port for web interface, reverse-proxied)</td> </tr>";

    $html .= "<tr> <td><b>SSH Port</b></td> <td>";
    $html .= "<input name=\"forgejo_ssh_port\" size=\"6\" value=\"$default_ssh\"> ";
    $html .= "(Port for Git over SSH)</td> </tr>";

    return $html;
}

sub script_forgejo_parse
{
    my ($d, $in) = @_;
    my $http_port = $in->{'forgejo_http_port'};
    my $ssh_port  = $in->{'forgejo_ssh_port'} || 2222;

    if ($http_port !~ /^\d+$/ || $http_port < 1024 || $http_port > 65535) {
        return "HTTP port must be a valid number between 1024 and 65535";
    }
    if ($ssh_port !~ /^\d+$/ || $ssh_port < 1 || $ssh_port > 65535) {
        return "SSH port must be a valid number between 1 and 65535";
    }

    return {
        'http_port' => $http_port,
        'ssh_port'  => $ssh_port,
    };
}

sub script_forgejo_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Forgejo requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_forgejo_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "forgejo-$ver-linux-$arch";
    my $url = "https://code.forgejo.org/forgejo/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_forgejo_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $http_port = $opts->{'http_port'};
    my $ssh_port  = $opts->{'ssh_port'};
    my $service_name = "forgejo-$dom";

    my $install_dir = "$d->{'home'}/forgejo";
    my $data_dir    = "$install_dir/data";
    my $custom_dir  = "$install_dir/custom/conf";
    make_path($data_dir, $custom_dir);

    my $arch = VirtualminWebApps::Common::get_arch();
    my $bin_name = "forgejo-$ver-linux-$arch";
    my $download_url = "https://code.forgejo.org/forgejo/releases/download/v$ver/$bin_name";
    my $dest_bin = "$install_dir/forgejo";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $dest_bin, 300);
    return (0, "Download failed: $err") if !$ok;

    chmod(0755, $dest_bin);

    # Database parameters
    my $dbname = $defs->{'db'} || ($user . "_forgejo");
    my $dbuser = $defs->{'user'} || $user;
    my $dbpass = $defs->{'pass'} || $d->{'pass'};
    my $dbhost = $defs->{'host'} || "127.0.0.1:3306";
    $dbhost .= ":3306" if $dbhost !~ /:/;

    my $proto = $d->{'ssl'} ? 'https' : 'http';

    # Write initial app.ini
    my $ini_file = "$custom_dir/app.ini";
    if (!-f $ini_file) {
        open(my $fh, '>', $ini_file) or return (0, "Cannot write config $ini_file: $!");
        print $fh <<"EOF";
APP_NAME = $dom Git
RUN_USER = $user
WORK_PATH = $install_dir
RUN_MODE = prod

[server]
PROTOCOL = http
DOMAIN = $dom
HTTP_PORT = $http_port
ROOT_URL = $proto://$dom/
SSH_PORT = $ssh_port
SSH_LISTEN_PORT = $ssh_port
LFS_START_SERVER = true

[database]
DB_TYPE = mysql
HOST = $dbhost
NAME = $dbname
USER = $dbuser
PASSWD = $dbpass
SSL_MODE = disable

[repository]
ROOT = $data_dir/forgejo-repositories

[security]
INSTALL_LOCK = true
SECRET_KEY = @{[ join('', map { ('a'..'z','0'..'9')[rand 36] } 1..32) ]}

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
EOF
        close($fh);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=Forgejo Git Service for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$dest_bin web
Restart=always
RestartSec=5s
Environment=USER=$user HOME=$d->{'home'} FORGEJO_WORK_DIR=$install_dir
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
        "forgejo",
        $http_port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    return (1, "$proto://$dom/", "Installed Forgejo Git service listening on port $http_port and reverse-proxied to $proto://$dom/");
}

sub script_forgejo_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "forgejo-$dom";

    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "forgejo");

    return 1;
}

sub script_forgejo_upgrade
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "forgejo-$dom";
    my $install_dir = "$d->{'home'}/forgejo";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);

    my $arch = VirtualminWebApps::Common::get_arch();
    my $bin_name = "forgejo-$ver-linux-$arch";
    my $download_url = "https://code.forgejo.org/forgejo/releases/download/v$ver/$bin_name";
    my $dest_bin = "$install_dir/forgejo";

    VirtualminWebApps::Common::download_url($download_url, $dest_bin, 300);
    chmod(0755, $dest_bin);

    VirtualminWebApps::SystemdHelper::start_service($service_name);

    return 1;
}

1;
