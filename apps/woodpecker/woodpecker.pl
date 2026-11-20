# apps/woodpecker/woodpecker.pl
# Virtualmin Web App installer for Woodpecker Continuous Integration Server
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

sub script_woodpecker_desc
{
    return "Woodpecker CI - Lightweight Continuous Integration Server";
}

sub script_woodpecker_uses
{
    return ( );
}

sub script_woodpecker_category
{
    return "Development";
}

sub script_woodpecker_author
{
    return "Woodpecker Authors";
}

sub script_woodpecker_site
{
    return "https://woodpecker-ci.org";
}

sub script_woodpecker_versions
{
    return ( "3.0.0" );
}

sub script_woodpecker_release
{
    return 1;
}

sub script_woodpecker_passmode
{
    return 2;
}

sub script_woodpecker_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8000, 8999) || 8000;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"woodpecker_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_woodpecker_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'woodpecker_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_woodpecker_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Woodpecker CI requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_woodpecker_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "woodpecker-server_linux_${arch}.tar.gz";
    my $url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_woodpecker_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "woodpecker-$dom";

    my $install_dir = "$d->{'home'}/woodpecker";
    my $data_dir = "$install_dir/data";
    make_path($install_dir, $data_dir);

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "woodpecker-server_linux_${arch}.tar.gz";
    my $download_url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/woodpecker-$dom-$filename";
    my $tmp_unpack = "/tmp/woodpecker-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 180);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    my $bin_source = "";
    my @candidates = glob("$tmp_unpack/woodpecker-server*");
    for my $c (@candidates) {
        if (-f $c && -x $c) {
            $bin_source = $c;
            last;
        }
    }
    $bin_source ||= "$tmp_unpack/woodpecker-server";

    my $bin_path = "$install_dir/woodpecker-server";
    if (-f $bin_source) {
        system("cp $bin_source $bin_path");
    }
    remove_tree($tmp_unpack);

    chmod(0755, $bin_path);
    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=Woodpecker CI Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
Environment=WOODPECKER_SERVER_ADDR=127.0.0.1:$port
Environment=WOODPECKER_DATA_DIR=$data_dir
Environment=WOODPECKER_HOST=$public_url
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
        "woodpecker",
        $port,
        1,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    return (
        1,
        $public_url,
        "Installed and started Woodpecker CI service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_woodpecker_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "woodpecker-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "woodpecker");

    my $install_dir = "$d->{'home'}/woodpecker";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
