# apps/microbin/microbin.pl
# Virtualmin Web App installer for Microbin Pastebin & File Sharing
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

sub script_microbin_desc
{
    return "Microbin Lightweight Encrypted Pastebin & File Sharing";
}

sub script_microbin_uses
{
    return ( );
}

sub script_microbin_category
{
    return "Utilities";
}

sub script_microbin_author
{
    return "Daniel Szabo";
}

sub script_microbin_site
{
    return "https://microbin.eu";
}

sub script_microbin_versions
{
    return ( "2.1.0" );
}

sub script_microbin_release
{
    return 2;
}

sub script_microbin_passmode
{
    return 2;
}

sub script_microbin_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8087, 8999) || 8087;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"microbin_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_microbin_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'microbin_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_microbin_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Microbin requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_microbin_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $target_triple = ($arch eq 'arm64') ? 'aarch64-unknown-linux-musl' : 'x86_64-unknown-linux-musl';
    my $filename = "microbin-v$ver-$target_triple.tar.gz";
    my $url = "https://github.com/szabodanika/microbin/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_microbin_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "microbin-$dom";

    my $install_dir = "$d->{'home'}/microbin";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $target_triple = ($arch eq 'arm64') ? 'aarch64-unknown-linux-musl' : 'x86_64-unknown-linux-musl';
    my $filename = "microbin-v$ver-$target_triple.tar.gz";
    my $download_url = "https://github.com/szabodanika/microbin/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/mb-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 120);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $bin_path = "$install_dir/microbin";
    chmod(0755, $bin_path);

    my $data_dir = "$install_dir/data";
    make_path($data_dir) if !-d $data_dir;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=Microbin Pastebin for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path --port $port --bind 127.0.0.1 --data-dir $data_dir --public-path $public_url --enable-burn-after-reading --qr --editable
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
        "microbin",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    return (
        1,
        $public_url,
        "Installed and started Microbin service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_microbin_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "microbin-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "microbin");

    my $install_dir = "$d->{'home'}/microbin";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
