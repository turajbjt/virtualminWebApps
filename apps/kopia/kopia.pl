# apps/kopia/kopia.pl
# Virtualmin Web App installer for Kopia Encrypted Backup Web UI
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

sub script_kopia_desc
{
    return "Kopia - Fast & Secure Encrypted Backup Web UI";
}

sub script_kopia_uses
{
    return ( );
}

sub script_kopia_category
{
    return "System";
}

sub script_kopia_author
{
    return "Kopia Project";
}

sub script_kopia_site
{
    return "https://kopia.io";
}

sub script_kopia_versions
{
    return ( "0.18.2" );
}

sub script_kopia_release
{
    return 1;
}

sub script_kopia_passmode
{
    return 2;
}

sub script_kopia_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(51515, 51600) || 51515;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"kopia_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Kopia Web UI daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_kopia_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'kopia_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_kopia_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_binary = VirtualminWebApps::Common::has_command('kopia');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_binary && !$has_container && !VirtualminWebApps::Common::has_command('curl')) {
        return "Kopia requires curl to download the binary, or a container runtime (podman/docker).";
    }

    return undef;
}

sub script_kopia_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 51515;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/kopia";
    my $config_dir = "$app_dir/config";
    my $cache_dir = "$app_dir/cache";

    make_path($config_dir, $cache_dir, { mode => 0750 });

    # Generate server password
    my $server_pass = VirtualminWebApps::Common::random_password(20);

    my $bin_path = "$app_dir/kopia";
    if (!-x $bin_path && VirtualminWebApps::Common::has_command('curl')) {
        my $arch = `uname -m` =~ /aarch64|arm64/ ? "linux-arm64" : "linux-x64";
        my $tar_url = "https://github.com/kopia/kopia/releases/download/v$version/kopia-$version-$arch.tar.gz";
        system("curl -sSL $tar_url | tar -xz --strip-components=1 -C $app_dir 2>/dev/null || true");
        chmod 0755, $bin_path if -f $bin_path;
    }

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'        => $user,
        'APP_DIR'     => $app_dir,
        'CONFIG_DIR'  => $config_dir,
        'CACHE_DIR'   => $cache_dir,
        'BIN_PATH'    => $bin_path,
        'PORT'        => $port,
        'SERVER_PASS' => $server_pass,
        'VERSION'     => $version,
        'ENGINE'      => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/kopia.service";
    my $service_name = "kopia-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 3600,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Kopia Web UI v$version successfully installed and reverse proxied on port $port.");
}

1;
