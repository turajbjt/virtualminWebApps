# apps/mattermost/mattermost.pl
# Virtualmin Web App installer for Mattermost Team Edition
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

sub script_mattermost_desc
{
    return "Mattermost - Team Edition Communication & Chat";
}

sub script_mattermost_uses
{
    return ( "mysql" );
}

sub script_mattermost_category
{
    return "Chat";
}

sub script_mattermost_author
{
    return "Mattermost Inc.";
}

sub script_mattermost_site
{
    return "https://mattermost.com";
}

sub script_mattermost_versions
{
    return ( "10.5.1" );
}

sub script_mattermost_release
{
    return 3;
}

sub script_mattermost_passmode
{
    return 2; # Web interface manages initial admin setup
}

sub script_mattermost_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8065, 8165) || 8065;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"mattermost_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Port for Mattermost daemon, automatically reverse-proxied)</td> </tr>";

    return $html;
}

sub script_mattermost_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'mattermost_port'} || 8065;

    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return {
        'port' => $port,
    };
}

sub script_mattermost_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!VirtualminWebApps::Common::has_command('systemctl')) {
        return "Mattermost runs as a systemd background service. Systemd was not detected on this server.";
    }
    if (!$d->{'mysql'}) {
        return "Mattermost requires MySQL/MariaDB database feature to be enabled for $d->{'dom'}.";
    }

    return undef;
}

sub script_mattermost_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = `uname -m 2>/dev/null` || "x86_64";
    chomp($arch);
    my $bin_arch = ($arch eq "aarch64" || $arch eq "arm64") ? "arm64" : "amd64";

    my $filename = "mattermost-team-${ver}-linux-${bin_arch}.tar.gz";
    my $url = "https://releases.mattermost.com/${ver}/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_mattermost_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $home = $d->{'home'};
    my $port = $opts->{'port'};
    my $service_name = "mattermost-$dom";

    my $app_dir = "$home/mattermost";
    my $data_dir = "$app_dir/data";
    make_path($app_dir, $data_dir);

    # Determine binary archive URL
    my $arch = `uname -m 2>/dev/null` || "x86_64";
    chomp($arch);
    my $bin_arch = ($arch eq "aarch64" || $arch eq "arm64") ? "arm64" : "amd64";
    my $filename = "mattermost-team-${ver}-linux-${bin_arch}.tar.gz";
    my $url = "https://releases.mattermost.com/${ver}/$filename";
    my $tmp_file = "/tmp/mattermost-$dom-$filename";
    my $tmp_unpack = "/tmp/mattermost-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 900);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from extracted mattermost folder
    my @contents = glob("$tmp_unpack/mattermost*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $app_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $app_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $app_dir/ 2>/dev/null");
        system("cp -r $tmp_unpack/.[!.]* $app_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    chmod(0755, "$app_dir/bin/mattermost");

    my $dbname = $defs->{'db'} || ($user . "_mattermost");
    my $dbuser = $defs->{'dbuser'} || $user;
    my $dbpass = $defs->{'dbpass'} || '';

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom/";

    my $datasource = "$dbuser:$dbpass\@tcp(127.0.0.1:3306)/$dbname?charset=utf8mb4,utf8&writeTimeout=30s";

    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    # Generate systemd unit
    my $unit_content = <<"EOF";
[Unit]
Description=Mattermost Team Edition for $dom
After=network.target network-online.target mariadb.service mysql.service
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$app_dir
ExecStart=$app_dir/bin/mattermost
Restart=always
RestartSec=10s
LimitNOFILE=65536
Environment=MM_SERVICESETTINGS_SITEURL=$full_url
Environment=MM_SERVICESETTINGS_LISTENADDRESS=127.0.0.1:$port
Environment=MM_SQLSETTINGS_DRIVERNAME=mysql
Environment=MM_SQLSETTINGS_DATASOURCE=$datasource
Environment=MM_FILESETTINGS_DIRECTORY=$data_dir

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::install_service_unit($service_name, $unit_content);
    return (0, "Systemd setup failed: $serr") if !$sok;

    # Configure Reverse Proxy with WebSocket forwarding
    my $webserver = ($d->{'proxy_pass_mode'} && $d->{'proxy_pass_mode'} eq 'nginx') ? 'nginx' : 'apache';
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::add_reverse_proxy(
        domain_name => $dom,
        local_port  => $port,
        path        => '/',
        webserver   => $webserver,
        websocket   => 1,
    );
    return (0, "Proxy configuration failed: $perr") if !$pok;

    my ($start_ok, $start_err) = VirtualminWebApps::SystemdHelper::start_service($service_name);
    return (0, "Failed to start Mattermost service: $start_err") if !$start_ok;

    return (
        1,
        $full_url,
        "Installed Mattermost Team Edition to $full_url. Access the site to create the system administrator account."
    );
}

sub script_mattermost_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $home = $d->{'home'};
    my $service_name = "mattermost-$dom";
    my $app_dir = "$home/mattermost";

    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    my $webserver = ($d->{'proxy_pass_mode'} && $d->{'proxy_pass_mode'} eq 'nginx') ? 'nginx' : 'apache';
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy(
        domain_name => $dom,
        path        => '/',
        webserver   => $webserver,
    );

    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
