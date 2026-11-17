# apps/vikunja/vikunja.pl
# Virtualmin Web App installer for Vikunja To-Do & Task Management
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

sub script_vikunja_desc
{
    return "Vikunja - Open-Source To-Do & Task Management";
}

sub script_vikunja_uses
{
    return ( );
}

sub script_vikunja_category
{
    return "Project";
}

sub script_vikunja_author
{
    return "Vikunja Community";
}

sub script_vikunja_site
{
    return "https://vikunja.io";
}

sub script_vikunja_versions
{
    return ( "2.8.0" );
}

sub script_vikunja_release
{
    return 3;
}

sub script_vikunja_passmode
{
    return 2;
}

sub script_vikunja_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(3456, 3999) || 3456;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"vikunja_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the backend daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_vikunja_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'vikunja_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_vikunja_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "Vikunja requires amd64 or arm64 architecture (detected: $arch).";
    }

    return undef;
}

sub script_vikunja_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "vikunja-v$ver-linux-$arch-full.zip";
    my $url = "https://github.com/go-vikunja/vikunja/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_vikunja_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "vikunja-$dom";

    my $install_dir = "$d->{'home'}/vikunja";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "vikunja-v$ver-linux-$arch-full.zip";
    my $download_url = "https://github.com/go-vikunja/vikunja/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/vikunja-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Find the binary (e.g. vikunja-v2.8.0-linux-amd64 or vikunja)
    my @bins = glob("$install_dir/vikunja*");
    my $bin_path = "";
    for my $b (@bins) {
        if (-f $b && !($b =~ /\.zip$/ || $b =~ /\.sample$/ || $b =~ /\.sha256$/)) {
            $bin_path = $b;
            last;
        }
    }
    if (!$bin_path) {
        $bin_path = "$install_dir/vikunja";
    }
    chmod(0755, $bin_path);

    # Create config.yml
    my $jwt_secret = VirtualminWebApps::Common::generate_random_key(32);
    my $config_path = "$install_dir/config.yml";
    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    my $conf_content = <<"EOF";
service:
  JWTSecret: "$jwt_secret"
  interface: ":$port"
  publicurl: "$public_url"
database:
  type: "sqlite"
  database: "$install_dir/vikunja.db"
files:
  basepath: "$install_dir/files"
EOF

    if (open(my $cfh, ">", $config_path)) {
        print $cfh $conf_content;
        close($cfh);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=Vikunja Task Manager for $dom
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

    # Configure Reverse Proxy
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "vikunja",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    return (
        1,
        $public_url,
        "Installed and started Vikunja service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_vikunja_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "vikunja-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "vikunja");

    my $install_dir = "$d->{'home'}/vikunja";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
