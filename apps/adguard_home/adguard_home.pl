# apps/adguard-home/adguard-home.pl
# Virtualmin Web App installer for AdGuard Home DNS & Ad Blocker
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);

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

sub script_adguard_home_desc
{
    return "AdGuard Home DNS & Ad Blocker";
}

sub script_adguard_home_uses
{
    return ( ); # Self-contained Go binary
}

sub script_adguard_home_category
{
    return "System";
}

sub script_adguard_home_author
{
    return "AdguardTeam";
}

sub script_adguard_home_site
{
    return "https://adguard.com/en/adguard-home.html";
}

sub script_adguard_home_versions
{
    return ( "0.107.80", "0.107.65" );
}

sub script_adguard_home_release
{
    return 2;
}

sub script_adguard_home_passmode
{
    return 2; # Web interface manages initial setup admin account
}

# script_adguard_home_params(&domain)
sub script_adguard_home_params
{
    my ($d) = @_;
    my $default_web_port = VirtualminWebApps::PortManager::find_free_port(3000, 3999) || 3000;

    my $html = "";
    $html .= "<tr> <td><b>Web Admin Port</b></td> <td>";
    $html .= "<input name=\"adguard_web_port\" size=\"6\" value=\"$default_web_port\"> ";
    $html .= "(Internal port for the web dashboard, automatically reverse-proxied)</td> </tr>";

    $html .= "<tr> <td><b>DNS Listen Port</b></td> <td>";
    $html .= "<input name=\"adguard_dns_port\" size=\"6\" value=\"53\"> ";
    $html .= "(Default: 53. If BIND or local resolver uses 53, specify alternate port or bind to specific IP)</td> </tr>";

    return $html;
}

# script_adguard_home_parse(&domain, &in)
sub script_adguard_home_parse
{
    my ($d, $in) = @_;
    my $web_port = $in->{'adguard_web_port'};
    my $dns_port = $in->{'adguard_dns_port'} || 53;

    if ($web_port !~ /^\d+$/ || $web_port < 1024 || $web_port > 65535) {
        return "Web admin port must be a valid number between 1024 and 65535";
    }
    if ($dns_port !~ /^\d+$/ || $dns_port < 1 || $dns_port > 65535) {
        return "DNS port must be a valid number between 1 and 65535";
    }

    return {
        'web_port' => $web_port,
        'dns_port' => $dns_port,
    };
}

# script_adguard_home_check(&domain, $version, $dbtype, $dir)
sub script_adguard_home_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64' && $arch ne 'armv7') {
        return "Unsupported CPU architecture ($arch). AdGuard Home requires amd64, arm64, or armv7.";
    }

    return undef;
}

# script_adguard_home_files(&domain, $version, $options)
sub script_adguard_home_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $url = "https://github.com/AdguardTeam/AdGuardHome/releases/download/v$ver/AdGuardHome_linux_$arch.tar.gz";

    return (
        {
            'name' => "AdGuardHome_linux_$arch.tar.gz",
            'url'  => $url,
        }
    );
}

# script_adguard_home_install(&domain, $version, $options, $defs, $setup)
sub script_adguard_home_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $web_port = $opts->{'web_port'};
    my $dns_port = $opts->{'dns_port'};
    my $service_name = "adguard-home-$dom";

    my $install_dir = "$d->{'home'}/adguard-home";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $archive_name = "AdGuardHome_linux_$arch.tar.gz";
    my $download_url = "https://github.com/AdguardTeam/AdGuardHome/releases/download/v$ver/$archive_name";
    my $tmp_file = "/tmp/$archive_name";

    # Download if not already cached
    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file);
    return (0, "Failed to download AdGuard Home: $err") if !$ok;

    # Extract
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir, 1);
    unlink($tmp_file);
    return (0, "Failed to extract AdGuard Home archive: $eerr") if !$eok;

    my $bin_path = "$install_dir/AdGuardHome";
    if (!-x $bin_path) {
        chmod(0755, $bin_path);
    }

    # Initial configuration YAML
    my $yaml_path = "$install_dir/AdGuardHome.yaml";
    if (!-f $yaml_path) {
        open(my $yfh, '>', $yaml_path) or return (0, "Cannot write config $yaml_path: $!");
        print $yfh <<"EOF";
http:
  address: 127.0.0.1:$web_port
dns:
  bind_hosts:
    - 0.0.0.0
  port: $dns_port
schema_version: 29
EOF
        close($yfh);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service
    my $service_content = <<"EOF";
[Unit]
Description=AdGuard Home DNS and Ad Blocker for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$install_dir
ExecStart=$bin_path -c $yaml_path -w $install_dir
Restart=always
RestartSec=5s
LimitNOFILE=65535
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::create_service_unit($service_name, $service_content);
    return (0, "Failed to create systemd unit: $serr") if !$sok;

    VirtualminWebApps::SystemdHelper::enable_service($service_name);
    VirtualminWebApps::SystemdHelper::start_service($service_name);

    # Setup Reverse Proxy
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "adguard_home",
        $web_port,
        1,
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    return (1, "$proto://$dom/", "Installed AdGuard Home service listening on web port $web_port (DNS port $dns_port) and reverse-proxied to $proto://$dom/");
}

# script_adguard_home_uninstall(&domain, $version, $options)
sub script_adguard_home_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "adguard-home-$dom";

    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "adguard_home");

    return 1;
}

# script_adguard_home_upgrade(&domain, $version, $options)
sub script_adguard_home_upgrade
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "adguard-home-$dom";
    my $install_dir = "$d->{'home'}/adguard-home";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);

    my $arch = VirtualminWebApps::Common::get_arch();
    my $archive_name = "AdGuardHome_linux_$arch.tar.gz";
    my $download_url = "https://github.com/AdguardTeam/AdGuardHome/releases/download/v$ver/$archive_name";
    my $tmp_file = "/tmp/$archive_name";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file);
    return (0, "Failed to download update: $err") if !$ok;

    VirtualminWebApps::Common::extract_archive($tmp_file, $install_dir, 1);
    unlink($tmp_file);

    chmod(0755, "$install_dir/AdGuardHome");
    VirtualminWebApps::SystemdHelper::start_service($service_name);

    return 1;
}

1;
