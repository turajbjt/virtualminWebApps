# apps/meilisearch/meilisearch.pl
# Virtualmin Web App installer for Meilisearch Search Engine
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

sub script_meilisearch_desc
{
    return "Meilisearch - Fast Open-Source Search Engine";
}

sub script_meilisearch_uses
{
    return ( );
}

sub script_meilisearch_category
{
    return "Utilities";
}

sub script_meilisearch_author
{
    return "Meilisearch Team";
}

sub script_meilisearch_site
{
    return "https://www.meilisearch.com";
}

sub script_meilisearch_versions
{
    return ( "1.12.0" );
}

sub script_meilisearch_release
{
    return 1;
}

sub script_meilisearch_passmode
{
    return 2;
}

sub script_meilisearch_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(7700, 7799) || 7700;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"meilisearch_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Meilisearch server daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_meilisearch_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'meilisearch_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_meilisearch_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_binary = VirtualminWebApps::Common::has_command('meilisearch');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_binary && !$has_container && !VirtualminWebApps::Common::has_command('curl')) {
        return "Meilisearch requires either curl (for downloading the binary) or a container runtime (podman/docker).";
    }

    return undef;
}

sub script_meilisearch_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 7700;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/meilisearch";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate random master key for Meilisearch API
    my $master_key = VirtualminWebApps::Common::random_password(32);

    # If binary exists locally or downloaded
    my $bin_path = "$app_dir/meilisearch";
    if (!-x $bin_path && VirtualminWebApps::Common::has_command('curl')) {
        my $arch = `uname -m` =~ /aarch64|arm64/ ? "linux-aarch64" : "linux-amd64";
        my $url = "https://github.com/meilisearch/meilisearch/releases/download/v$version/meilisearch-$arch";
        system("curl -sSL -o $bin_path $url && chmod 0755 $bin_path");
    }

    my $use_container = (!-x $bin_path && (VirtualminWebApps::Common::has_command('podman') || VirtualminWebApps::Common::has_command('docker'))) ? 1 : 0;
    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';

    my %subs = (
        'USER'          => $user,
        'APP_DIR'       => $app_dir,
        'DATA_DIR'      => $data_dir,
        'BIN_PATH'      => $bin_path,
        'PORT'          => $port,
        'MASTER_KEY'    => $master_key,
        'VERSION'       => $version,
        'ENGINE'        => $engine,
        'USE_CONTAINER' => $use_container,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/meilisearch.service";
    my $service_name = "meilisearch-$dom";

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::install_service_from_template($service_name, $tpl_path, \%subs);
    if (!$ok) {
        return (0, "Failed to create systemd service: $err");
    }

    my ($p_ok, $p_err) = VirtualminWebApps::ProxyHelper::setup_proxy_pass($d, "http://127.0.0.1:$port/", {
        'timeout'   => 120,
    });
    if (!$p_ok) {
        return (0, "Failed to configure reverse proxy: $p_err");
    }

    return (1, "Meilisearch v$version successfully installed and reverse proxied on port $port. Master Key generated.");
}

1;
