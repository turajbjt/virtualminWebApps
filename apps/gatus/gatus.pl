# apps/gatus/gatus.pl
# Virtualmin Web App installer for Gatus Service Health Dashboard
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

sub script_gatus_desc
{
    return "Gatus - Automated Service Health Dashboard";
}

sub script_gatus_uses
{
    return ( );
}

sub script_gatus_category
{
    return "System";
}

sub script_gatus_author
{
    return "Twin Production & Gatus Contributors";
}

sub script_gatus_site
{
    return "https://gatus.io";
}

sub script_gatus_versions
{
    return ( "5.13.1" );
}

sub script_gatus_release
{
    return 1;
}

sub script_gatus_passmode
{
    return 2;
}

sub script_gatus_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8085, 8150) || 8085;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"gatus_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Gatus dashboard daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_gatus_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'gatus_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_gatus_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_binary = VirtualminWebApps::Common::has_command('gatus');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_binary && !$has_container && !VirtualminWebApps::Common::has_command('curl')) {
        return "Gatus requires curl to download the binary, or a container runtime (podman/docker).";
    }

    return undef;
}

sub script_gatus_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8085;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/gatus";
    my $config_dir = "$app_dir/config";
    make_path($config_dir, { mode => 0750 });

    # Generate initial config.yaml
    my $config_file = "$config_dir/config.yaml";
    my $yaml_content = <<"EOF";
web:
  port: $port
  address: "127.0.0.1"

endpoints:
  - name: "$dom Web Server"
    url: "https://$dom"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
EOF

    VirtualminWebApps::Common::write_file_contents($config_file, $yaml_content);
    chmod 0600, $config_file;

    my $bin_path = "$app_dir/gatus";
    if (!-x $bin_path && VirtualminWebApps::Common::has_command('curl')) {
        my $arch = `uname -m` =~ /aarch64|arm64/ ? "linux-arm64" : "linux-amd64";
        my $tar_url = "https://github.com/TwiN/gatus/releases/download/v$version/gatus-$version-$arch.tar.gz";
        system("curl -sSL $tar_url | tar -xz -C $app_dir && chmod 0755 $bin_path 2>/dev/null || true");
    }

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'        => $user,
        'APP_DIR'     => $app_dir,
        'CONFIG_DIR'  => $config_dir,
        'CONFIG_FILE' => $config_file,
        'BIN_PATH'    => $bin_path,
        'PORT'        => $port,
        'VERSION'     => $version,
        'ENGINE'      => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/gatus.service";
    my $service_name = "gatus-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 120,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Gatus Health Dashboard v$version successfully installed and reverse proxied on port $port.");
}

1;
