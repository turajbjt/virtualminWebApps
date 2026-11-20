# apps/syncthing/syncthing.pl
# Virtualmin Web App installer for Syncthing Continuous File Synchronization
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

sub script_syncthing_desc
{
    return "Syncthing - Continuous File Synchronization";
}

sub script_syncthing_uses
{
    return ( );
}

sub script_syncthing_category
{
    return "Sync";
}

sub script_syncthing_author
{
    return "The Syncthing Authors";
}

sub script_syncthing_site
{
    return "https://syncthing.net";
}

sub script_syncthing_versions
{
    return ( "1.29.2" );
}

sub script_syncthing_release
{
    return 1;
}

sub script_syncthing_passmode
{
    return 2;
}

sub script_syncthing_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8384, 8999) || 8384;

    my $html = "";
    $html .= "<tr> <td><b>Web GUI Internal Port</b></td> <td>";
    $html .= "<input name=\"syncthing_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the web GUI daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_syncthing_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'syncthing_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_syncthing_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Syncthing requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_syncthing_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "syncthing-linux-$arch-v$ver.tar.gz";
    my $url = "https://github.com/syncthing/syncthing/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_syncthing_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "syncthing-$dom";

    my $install_dir = "$d->{'home'}/syncthing";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "syncthing-linux-$arch-v$ver.tar.gz";
    my $download_url = "https://github.com/syncthing/syncthing/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/syncthing-$dom-$filename";
    my $tmp_unpack = "/tmp/syncthing-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 180);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Find the binary in unpacked archive
    my $bin_source = "";
    my @candidates = glob("$tmp_unpack/syncthing*/syncthing");
    if (@candidates && -f $candidates[0]) {
        $bin_source = $candidates[0];
    } elsif (-f "$tmp_unpack/syncthing") {
        $bin_source = "$tmp_unpack/syncthing";
    }

    my $bin_path = "$install_dir/syncthing";
    if ($bin_source && -f $bin_source) {
        system("cp $bin_source $bin_path");
    }
    remove_tree($tmp_unpack);

    chmod(0755, $bin_path);

    my $config_dir = "$install_dir/config";
    make_path($config_dir) if !-d $config_dir;

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=Syncthing File Synchronization for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path -gui-address=127.0.0.1:$port -home=$config_dir -no-browser -no-restart
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
        "syncthing",
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
        "Installed and started Syncthing service ($service_name) on port $port reverse-proxied to $public_url (Access web GUI to configure devices and sync folders)."
    );
}

sub script_syncthing_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "syncthing-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "syncthing");

    my $install_dir = "$d->{'home'}/syncthing";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
