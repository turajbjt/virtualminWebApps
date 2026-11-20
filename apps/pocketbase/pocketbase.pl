# apps/pocketbase/pocketbase.pl
# Virtualmin Web App installer for PocketBase Realtime Backend & Database
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

sub script_pocketbase_desc
{
    return "PocketBase - Realtime Backend and Database";
}

sub script_pocketbase_uses
{
    return ( );
}

sub script_pocketbase_category
{
    return "Development";
}

sub script_pocketbase_author
{
    return "PocketBase Team";
}

sub script_pocketbase_site
{
    return "https://pocketbase.io";
}

sub script_pocketbase_versions
{
    return ( "0.25.9" );
}

sub script_pocketbase_release
{
    return 1;
}

sub script_pocketbase_passmode
{
    return 2;
}

sub script_pocketbase_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8090, 8999) || 8090;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"pocketbase_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_pocketbase_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'pocketbase_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_pocketbase_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "PocketBase requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_pocketbase_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "pocketbase_${ver}_linux_${arch}.zip";
    my $url = "https://github.com/pocketbase/pocketbase/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_pocketbase_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "pocketbase-$dom";

    my $install_dir = "$d->{'home'}/pocketbase";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "pocketbase_${ver}_linux_${arch}.zip";
    my $download_url = "https://github.com/pocketbase/pocketbase/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/pocketbase-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 120);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $bin_path = "$install_dir/pocketbase";
    chmod(0755, $bin_path);

    my $data_dir = "$install_dir/pb_data";
    make_path($data_dir) if !-d $data_dir;

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=PocketBase Realtime Backend for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path serve --http=127.0.0.1:$port --dir=$data_dir
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
        "pocketbase",
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
        "Installed and started PocketBase service ($service_name) on port $port reverse-proxied to $public_url (Access admin dashboard at ${public_url}_/)."
    );
}

sub script_pocketbase_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "pocketbase-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "pocketbase");

    my $install_dir = "$d->{'home'}/pocketbase";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
