# apps/rustdesk/rustdesk.pl
# Virtualmin Web App installer for RustDesk Remote Desktop Server
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

sub script_rustdesk_desc
{
    return "RustDesk Server - Self-Hosted Remote Desktop Relay";
}

sub script_rustdesk_uses
{
    return ( );
}

sub script_rustdesk_category
{
    return "System";
}

sub script_rustdesk_author
{
    return "RustDesk Community";
}

sub script_rustdesk_site
{
    return "https://rustdesk.com";
}

sub script_rustdesk_versions
{
    return ( "1.1.12" );
}

sub script_rustdesk_release
{
    return 1;
}

sub script_rustdesk_passmode
{
    return 2;
}

sub script_rustdesk_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(21116, 21999) || 21116;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"rustdesk_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the rendezvous daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_rustdesk_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'rustdesk_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_rustdesk_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "RustDesk Server requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_rustdesk_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $zip_arch = ($arch eq 'arm64') ? 'arm64v8' : 'x86_64';
    my $filename = "rustdesk-server-linux-$zip_arch.zip";
    my $url = "https://github.com/rustdesk/rustdesk-server/releases/download/$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_rustdesk_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "rustdesk-$dom";

    my $install_dir = "$d->{'home'}/rustdesk";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $zip_arch = ($arch eq 'arm64') ? 'arm64v8' : 'x86_64';
    my $filename = "rustdesk-server-linux-$zip_arch.zip";
    my $download_url = "https://github.com/rustdesk/rustdesk-server/releases/download/$ver/$filename";
    my $tmp_file = "/tmp/rustdesk-$dom-$filename";
    my $tmp_unpack = "/tmp/rustdesk-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 180);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy binaries hbbs and hbbr
    my @hbbs = glob("$tmp_unpack/**/hbbs $tmp_unpack/hbbs");
    my @hbbr = glob("$tmp_unpack/**/hbbr $tmp_unpack/hbbr");

    if (@hbbs && -f $hbbs[0]) {
        system("cp $hbbs[0] $install_dir/hbbs");
        chmod(0755, "$install_dir/hbbs");
    }
    if (@hbbr && -f $hbbr[0]) {
        system("cp $hbbr[0] $install_dir/hbbr");
        chmod(0755, "$install_dir/hbbr");
    }
    remove_tree($tmp_unpack);

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    my $bin_path = "$install_dir/hbbs";

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=RustDesk Server Relay for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path -p $port -r $dom:21117
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
        "rustdesk",
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
        "Installed and started RustDesk Server service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_rustdesk_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "rustdesk-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "rustdesk");

    my $install_dir = "$d->{'home'}/rustdesk";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
