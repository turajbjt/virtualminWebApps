# apps/navidrome/navidrome.pl
# Virtualmin Web App installer for Navidrome Music Server
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

sub script_navidrome_desc
{
    return "Navidrome - Music Streaming Server";
}

sub script_navidrome_uses
{
    return ( ); # Self-contained Go binary daemon
}

sub script_navidrome_category
{
    return "Media";
}

sub script_navidrome_author
{
    return "Navidrome Authors";
}

sub script_navidrome_site
{
    return "https://www.navidrome.org";
}

sub script_navidrome_versions
{
    return ( "0.64.2" );
}

sub script_navidrome_release
{
    return 3;
}

sub script_navidrome_passmode
{
    return 2; # Web interface manages initial admin setup
}

sub script_navidrome_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(4533, 4999) || 4533;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"navidrome_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Port for Navidrome daemon, automatically reverse-proxied)</td> </tr>";

    $html .= "<tr> <td><b>Music Library Directory</b></td> <td>";
    $html .= "<input name=\"navidrome_music_dir\" size=\"40\" value=\"$d->{'home'}/music\"> ";
    $html .= "(Directory where your audio files and albums are stored)</td> </tr>";

    return $html;
}

sub script_navidrome_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'navidrome_port'} || 4533;
    my ($port_ok, $port_err) = VirtualminWebApps::Common::validate_port($port, 1024, 65535);
    return $port_err if !$port_ok;

    my $raw_music = $in->{'navidrome_music_dir'} || "$d->{'home'}/music";
    if ($raw_music =~ m{(^|/)\.\.(/|$)} || $raw_music =~ /[\0;`$|]/) {
        return "Path traversal or invalid characters detected in music directory: $raw_music";
    }

    return {
        'port'      => $port,
        'music_dir' => $raw_music,
    };
}

sub script_navidrome_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    if (!VirtualminWebApps::Common::has_command('systemctl')) {
        return "Navidrome runs as a systemd background service. Systemd was not detected on this server.";
    }

    return undef;
}

sub script_navidrome_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = `uname -m 2>/dev/null` || "x86_64";
    chomp($arch);
    my $bin_arch = ($arch eq "aarch64" || $arch eq "arm64") ? "arm64" : "amd64";

    my $filename = "navidrome_${ver}_linux_${bin_arch}.tar.gz";
    my $url = "https://github.com/navidrome/navidrome/releases/download/v${ver}/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_navidrome_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $home = $d->{'home'};
    my $port = $opts->{'port'};
    my $music_dir = $opts->{'music_dir'};
    my $service_name = "navidrome-$dom";

    my $app_dir = "$home/navidrome";
    my $data_dir = "$app_dir/data";
    make_path($app_dir, $data_dir, $music_dir);

    # Determine binary archive URL
    my $arch = `uname -m 2>/dev/null` || "x86_64";
    chomp($arch);
    my $bin_arch = ($arch eq "aarch64" || $arch eq "arm64") ? "arm64" : "amd64";
    my $filename = "navidrome_${ver}_linux_${bin_arch}.tar.gz";
    my $url = "https://github.com/navidrome/navidrome/releases/download/v${ver}/$filename";
    my $tmp_file = "/tmp/navidrome-$dom-$filename";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($url, $tmp_file, 300);
    return (0, "Download failed: $err") if !$ok;

    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $app_dir);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    chmod(0755, "$app_dir/navidrome");

    # Write navidrome.toml configuration
    my $config_path = "$app_dir/navidrome.toml";
    if (open(my $cfh, ">", $config_path)) {
        print $cfh <<"EOF";
# Navidrome configuration for $dom
MusicFolder = "$music_dir"
DataFolder = "$data_dir"
Address = "127.0.0.1"
Port = $port
BaseUrl = ""
ScanSchedule = "\@every 15m"
LogLevel = "info"
EOF
        close($cfh);
    }

    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);
    VirtualminWebApps::Common::set_ownership_recursive($music_dir, $user, $group);

    # Generate systemd unit
    my $unit_content = <<"EOF";
[Unit]
Description=Navidrome Music Streaming Server for $dom
After=network.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$app_dir
ExecStart=$app_dir/navidrome --configfile $config_path
Restart=always
RestartSec=5s
Environment=ND_SCANINTERVAL=15m
Environment=ND_LOGLEVEL=info
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::install_service_unit($service_name, $unit_content);
    return (0, "Systemd setup failed: $serr") if !$sok;

    # Configure Reverse Proxy
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
    return (0, "Failed to start Navidrome service: $start_err") if !$start_ok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom/";

    return (
        1,
        $full_url,
        "Installed Navidrome music server to $full_url. Access the dashboard to configure your administrator user."
    );
}

sub script_navidrome_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $home = $d->{'home'};
    my $service_name = "navidrome-$dom";
    my $app_dir = "$home/navidrome";

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
