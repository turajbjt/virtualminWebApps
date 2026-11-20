# apps/actual_budget/actual_budget.pl
# Virtualmin Web App installer for Actual Budget Personal Finance
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

sub script_actual_budget_desc
{
    return "Actual Budget - Privacy-First Personal Finance System";
}

sub script_actual_budget_uses
{
    return ( );
}

sub script_actual_budget_category
{
    return "Finance";
}

sub script_actual_budget_author
{
    return "Actual Budget Community";
}

sub script_actual_budget_site
{
    return "https://actualbudget.org";
}

sub script_actual_budget_versions
{
    return ( "24.11.0" );
}

sub script_actual_budget_release
{
    return 1;
}

sub script_actual_budget_passmode
{
    return 2;
}

sub script_actual_budget_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(5006, 5090) || 5006;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"actual_budget_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Actual Budget server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_actual_budget_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'actual_budget_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_actual_budget_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Actual Budget requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_actual_budget_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 5006;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/actual-budget";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'     => $user,
        'APP_DIR'  => $app_dir,
        'DATA_DIR' => $data_dir,
        'PORT'     => $port,
        'VERSION'  => $version,
        'ENGINE'   => $engine,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/actual_budget.service";
    my $service_name = "actual-budget-$dom";

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

    return (1, "Actual Budget v$version successfully installed and reverse proxied on port $port.");
}

1;
