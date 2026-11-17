# apps/gotify/gotify.pl
# Virtualmin Web App installer for Gotify Push Notification Server
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path remove_tree);

# Include shared libraries
BEGIN {
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";
require "PortManager.pl";
require "SystemdHelper.pl";
require "ProxyHelper.pl";

sub script_gotify_desc
{
    return "Gotify Real-Time Push Notification Server";
}

sub script_gotify_uses
{
    return ( );
}

sub script_gotify_category
{
    return "System";
}

sub script_gotify_author
{
    return "Gotify Team";
}

sub script_gotify_site
{
    return "https://gotify.net";
}

sub script_gotify_versions
{
    return ( "3.1.1" );
}

sub script_gotify_release
{
    return 1;
}

sub script_gotify_passmode
{
    return 2;
}

sub script_gotify_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8088, 8999) || 8088;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"gotify_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_gotify_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'gotify_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_gotify_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Gotify requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_gotify_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "gotify-linux-$arch.zip";
    my $url = "https://github.com/gotify/server/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_gotify_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "gotify-$dom";

    my $install_dir = "$d->{'home'}/gotify";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "gotify-linux-$arch.zip";
    my $download_url = "https://github.com/gotify/server/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/gotify-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 120);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Find the binary
    my $bin_path = "$install_dir/gotify-linux-$arch";
    if (!-f $bin_path) {
        my @bins = glob("$install_dir/gotify*");
        for my $b (@bins) {
            if (-f $b && !($b =~ /\.zip$/ || $b =~ /\.yml$/)) {
                $bin_path = $b;
                last;
            }
        }
    }
    chmod(0755, $bin_path);

    # Create config.yml
    my $config_path = "$install_dir/config.yml";
    my $data_dir = "$install_dir/data";
    make_path($data_dir) if !-d $data_dir;

    my $conf_content = <<"EOF";
server:
  port: $port
database:
  dialect: sqlite3
  connection: data/gotify.db
defaultuser:
  name: admin
  pass: admin
passstrength: 10
uploadedimagesdir: data/images
pluginsdir: data/plugins
registration: false
EOF

    if (open(my $cfh, ">", $config_path)) {
        print $cfh $conf_content;
        close($cfh);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=Gotify Push Notification Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
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

    # Configure Reverse Proxy with WebSockets
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "gotify",
        $port,
        1,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    return (
        1,
        $public_url,
        "Installed and started Gotify service ($service_name) on port $port reverse-proxied to $public_url (Initial login: admin / admin; change immediately)."
    );
}

sub script_gotify_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "gotify-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "gotify");

    my $install_dir = "$d->{'home'}/gotify";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
