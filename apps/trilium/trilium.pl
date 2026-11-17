# apps/trilium/trilium.pl
# Virtualmin Web App installer for Trilium Notes
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

sub script_trilium_desc
{
    return "Trilium Notes - Hierarchical Knowledge Base";
}

sub script_trilium_uses
{
    return ();
}

sub script_trilium_category
{
    return "Knowledge";
}

sub script_trilium_author
{
    return "TriliumNext Community";
}

sub script_trilium_site
{
    return "https://triliumnotes.org";
}

sub script_trilium_versions
{
    return ( "0.95.0" );
}

sub script_trilium_release
{
    return 3;
}

sub script_trilium_passmode
{
    return 0;
}

sub script_trilium_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::allocate_port($d, 8080);
    my $html = "";

    $html .= "<tr> <td><b>Backend Port</b></td> <td>";
    $html .= "<input name=\"trilium_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Internal port for Trilium daemon)</td> </tr>";

    return $html;
}

sub script_trilium_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'trilium_port'} || VirtualminWebApps::PortManager::find_free_port(8080, 8999) || 8080;
    my ($port_ok, $port_err) = VirtualminWebApps::Common::validate_port($port, 1024, 65535);
    return $port_err if !$port_ok;
    return { 'port' => $port };
}

sub script_trilium_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    if ($arch ne 'x86_64' && $arch ne 'arm64' && $arch ne 'aarch64') {
        return "Trilium standalone server is only supported on x86_64 and arm64 architectures.";
    }
    return undef;
}

sub script_trilium_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $tar_arch = ($arch eq 'arm64' || $arch eq 'aarch64') ? 'arm64' : 'x64';
    my $filename = "TriliumNextNotes-Server-v$ver-linux-$tar_arch.tar.xz";
    my $url = "https://github.com/TriliumNext/Notes/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_trilium_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "trilium-$dom";

    my $install_dir = "$d->{'home'}/trilium";
    my $data_dir = "$d->{'home'}/trilium-data";
    make_path($install_dir) if !-d $install_dir;
    make_path($data_dir) if !-d $data_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $tar_arch = ($arch eq 'arm64' || $arch eq 'aarch64') ? 'arm64' : 'x64';
    my $filename = "TriliumNextNotes-Server-v$ver-linux-$tar_arch.tar.xz";
    my $url = "https://github.com/TriliumNext/Notes/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/trilium-$dom-$filename";
    my $tmp_unpack = "/tmp/trilium-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 600);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Copy files from TriliumNextNotes-Server-*
    my @contents = glob("$tmp_unpack/TriliumNextNotes-Server-*");
    if (@contents && -d $contents[0]) {
        system("cp -r $contents[0]/* $install_dir/ 2>/dev/null");
        system("cp -r $contents[0]/.[!.]* $install_dir/ 2>/dev/null");
    } else {
        system("cp -r $tmp_unpack/* $install_dir/ 2>/dev/null");
    }
    remove_tree($tmp_unpack);

    chmod(0755, "$install_dir/node/bin/node") if -f "$install_dir/node/bin/node";

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=Trilium Notes Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
Environment="TRILIUM_DATA_DIR=$data_dir"
Environment="PORT=$port"
Environment="HOST=127.0.0.1"
ExecStart=$install_dir/node/bin/node $install_dir/main.cjs
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

    # Configure Reverse Proxy with WebSocket support
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "trilium",
        $port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (
        1,
        "$proto://$dom/",
        "Installed Trilium Notes listening on internal port $port and reverse-proxied to $proto://$dom/. Complete initial setup in your browser."
    );
}

sub script_trilium_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "trilium-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "trilium");

    return 1;
}

1;
