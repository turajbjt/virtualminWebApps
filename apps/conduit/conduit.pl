# apps/conduit/conduit.pl
# Virtualmin Web App installer for Conduit Matrix Homeserver
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

sub script_conduit_desc
{
    return "Conduit - Lightweight Matrix Homeserver";
}

sub script_conduit_uses
{
    return ( );
}

sub script_conduit_category
{
    return "Chat";
}

sub script_conduit_author
{
    return "Conduit Team";
}

sub script_conduit_site
{
    return "https://conduit.rs";
}

sub script_conduit_versions
{
    return ( "0.8.0" );
}

sub script_conduit_release
{
    return 1;
}

sub script_conduit_passmode
{
    return 2;
}

sub script_conduit_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(6167, 6200) || 6167;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"conduit_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the Conduit Matrix server, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_conduit_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'conduit_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_conduit_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_binary = VirtualminWebApps::Common::has_command('conduit');
    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');

    if (!$has_binary && !$has_container && !VirtualminWebApps::Common::has_command('curl')) {
        return "Conduit requires curl to download the binary, or a container engine (podman/docker).";
    }

    return undef;
}

sub script_conduit_install
{
    my ($d, $version, $opts) = @_;
    my $port = $opts->{'port'} || 6167;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $home = $d->{'home'};

    my $app_dir = "$home/conduit";
    my $data_dir = "$app_dir/data";
    make_path($data_dir, { mode => 0750 });

    # Generate configuration file
    my $config_file = "$app_dir/conduit.toml";
    my $conf_content = <<"EOF";
[global]
server_name = "$dom"
port = $port
address = "127.0.0.1"
database_path = "$data_dir"
max_request_size = 20_000_000
allow_registration = false
allow_federation = true
trusted_servers = ["matrix.org"]
EOF

    VirtualminWebApps::Common::write_file_contents($config_file, $conf_content);
    chmod 0600, $config_file;

    my $bin_path = "$app_dir/conduit";
    if (!-x $bin_path && VirtualminWebApps::Common::has_command('curl')) {
        my $arch = `uname -m` =~ /aarch64|arm64/ ? "aarch64-unknown-linux-musl" : "x86_64-unknown-linux-musl";
        my $url = "https://gitlab.com/famedly/conduit/-/jobs/artifacts/v$version/raw/target/$arch/release/conduit?job=build";
        system("curl -sSL -o $bin_path '$url' && chmod 0755 $bin_path 2>/dev/null || true");
    }

    my $engine = VirtualminWebApps::Common::has_command('podman') ? 'podman' : 'docker';
    my %subs = (
        'USER'        => $user,
        'APP_DIR'     => $app_dir,
        'CONFIG_FILE' => $config_file,
        'DATA_DIR'    => $data_dir,
        'BIN_PATH'    => $bin_path,
        'PORT'        => $port,
        'ENGINE'      => $engine,
        'VERSION'     => $version,
    );

    my $real_file = eval { abs_path(__FILE__) } || __FILE__;
    my $tpl_path = dirname($real_file) . "/conduit.service";
    my $service_name = "conduit-$dom";

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

    return (1, "Conduit Matrix server successfully installed and reverse proxied on port $port.");
}

1;
