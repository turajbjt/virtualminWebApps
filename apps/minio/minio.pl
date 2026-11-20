# apps/minio/minio.pl
# Virtualmin Web App installer for MinIO S3 Object Storage
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

sub script_minio_desc
{
    return "MinIO - High-Performance S3 Compatible Object Storage";
}

sub script_minio_uses
{
    return ( );
}

sub script_minio_category
{
    return "Cloud";
}

sub script_minio_author
{
    return "MinIO Inc.";
}

sub script_minio_site
{
    return "https://min.io";
}

sub script_minio_versions
{
    return ( "2024.11.07" );
}

sub script_minio_release
{
    return 1;
}

sub script_minio_passmode
{
    return 2;
}

sub script_minio_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(9000, 9050) || 9000;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"minio_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the MinIO API and Web Console, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_minio_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'minio_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_minio_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_binary = VirtualminWebApps::Common::has_command('minio');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_binary && !$has_container && !VirtualminWebApps::Common::has_command('curl')) {
        return "MinIO requires curl to download the binary, or a container runtime (podman/docker).";
    }

    return undef;
}

sub script_minio_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 9000;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/minio";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate root credentials
    my $root_user = "admin_" . substr(VirtualminWebApps::Common::random_password(8), 0, 6);
    my $root_pass = VirtualminWebApps::Common::random_password(24);

    my $bin_path = "$app_dir/minio";
    if (!-x $bin_path && VirtualminWebApps::Common::has_command('curl')) {
        my $arch = `uname -m` =~ /aarch64|arm64/ ? "arm64" : "amd64";
        my $url = "https://dl.min.io/server/minio/release/linux-$arch/minio";
        system("curl -sSL -o $bin_path $url && chmod 0755 $bin_path");
    }

    my $console_port = $port + 1;
    my %subs = (
        'USER'         => $user,
        'APP_DIR'      => $app_dir,
        'DATA_DIR'     => $data_dir,
        'BIN_PATH'     => $bin_path,
        'PORT'         => $port,
        'CONSOLE_PORT' => $console_port,
        'ROOT_USER'    => $root_user,
        'ROOT_PASS'    => $root_pass,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/minio.service";
    my $service_name = "minio-$dom";

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

    return (1, "MinIO Object Storage successfully installed and reverse proxied on port $port. Root user: $root_user.");
}

1;
