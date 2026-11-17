# apps/filebrowser/filebrowser.pl
# Virtualmin Web App installer for File Browser Lightweight Web Manager
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

sub script_filebrowser_desc
{
    return "File Browser Lightweight Web Manager";
}

sub script_filebrowser_uses
{
    return ( );
}

sub script_filebrowser_category
{
    return "System";
}

sub script_filebrowser_author
{
    return "File Browser Team";
}

sub script_filebrowser_site
{
    return "https://filebrowser.org";
}

sub script_filebrowser_versions
{
    return ( "2.30.0", "2.29.0" );
}

sub script_filebrowser_release
{
    return 2;
}

sub script_filebrowser_passmode
{
    return 2;
}

sub script_filebrowser_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8085, 8999) || 8085;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"fb_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the service, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_filebrowser_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'fb_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_filebrowser_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64' && $arch ne 'armv7') {
        return "File Browser requires amd64, arm64, or armv7 architecture (detected: $arch).";
    }

    return undef;
}

sub script_filebrowser_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "linux-$arch-filebrowser.tar.gz";
    my $url = "https://github.com/filebrowser/filebrowser/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_filebrowser_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "filebrowser-$dom";

    my $install_dir = "$d->{'home'}/filebrowser";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "linux-$arch-filebrowser.tar.gz";
    my $download_url = "https://github.com/filebrowser/filebrowser/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/fb-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 120);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $bin_path = "$install_dir/filebrowser";
    chmod(0755, $bin_path);

    my $db_path = "$install_dir/filebrowser.db";
    my $root_dir = $d->{'home'};

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=File Browser Web Manager for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path -p $port -a 127.0.0.1 -d $db_path -r $root_dir
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
        "filebrowser",
        $port,
        0,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (
        1,
        "$proto://$dom/",
        "Installed File Browser listening on port $port and reverse-proxied to $proto://$dom/. Default login: admin / admin"
    );
}

sub script_filebrowser_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "filebrowser-$dom";

    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "filebrowser");

    return 1;
}

1;
