# apps/borgmatic/borgmatic.pl
# Virtualmin Web App installer for Borgmatic Backup Management
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

sub script_borgmatic_desc
{
    return "Borgmatic - Simple Encrypted Backup Management";
}

sub script_borgmatic_uses
{
    return ( );
}

sub script_borgmatic_category
{
    return "System";
}

sub script_borgmatic_author
{
    return "Dan Helfman & Borgmatic Contributors";
}

sub script_borgmatic_site
{
    return "https://torsion.org/borgmatic";
}

sub script_borgmatic_versions
{
    return ( "1.9.0" );
}

sub script_borgmatic_release
{
    return 1;
}

sub script_borgmatic_passmode
{
    return 2;
}

sub script_borgmatic_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8092, 8190) || 8092;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"borgmatic_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Borgmatic dashboard daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_borgmatic_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'borgmatic_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_borgmatic_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Borgmatic requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_borgmatic_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 8092;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/borgmatic";
    my $config_dir = "$app_dir/config";
    my $data_dir = "$app_dir/data";

    make_path($config_dir, $data_dir, { mode => 0750 });

    # Generate initial config
    my $config_file = "$config_dir/config.yaml";
    my $yaml = <<"EOF";
source_directories:
  - $home/public_html
repositories:
  - path: $data_dir/repo
keep_daily: 7
keep_weekly: 4
keep_monthly: 6
EOF
    VirtualminWebApps::Common::write_file_contents($config_file, $yaml);
    chmod 0600, $config_file;

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'       => $user,
        'APP_DIR'    => $app_dir,
        'CONFIG_DIR' => $config_dir,
        'DATA_DIR'   => $data_dir,
        'PORT'       => $port,
        'VERSION'    => $version,
        'URL'        => "https://$dom",
        'ENGINE'     => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/borgmatic.service";
    my $service_name = "borgmatic-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'websocket' => 1,
        'timeout'   => 300,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Borgmatic v$version successfully installed and reverse proxied on port $port.");
}

1;
