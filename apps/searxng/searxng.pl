# apps/searxng/searxng.pl
# Virtualmin Web App installer for SearXNG Privacy Metasearch Engine
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

sub script_searxng_desc
{
    return "SearXNG - Privacy-Respecting Metasearch Engine";
}

sub script_searxng_uses
{
    return ( );
}

sub script_searxng_category
{
    return "Utilities";
}

sub script_searxng_author
{
    return "SearXNG Community";
}

sub script_searxng_site
{
    return "https://github.com/searxng/searxng";
}

sub script_searxng_versions
{
    return ( "2024.11.20" );
}

sub script_searxng_release
{
    return 1;
}

sub script_searxng_passmode
{
    return 2;
}

sub script_searxng_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8080, 8999) || 8080;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"searxng_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_searxng_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'searxng_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_searxng_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "SearXNG requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_searxng_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_searxng_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "searxng-$dom";

    my $app_dir = "$d->{'home'}/searxng";
    make_path($app_dir) if !-d $app_dir;

    my $secret_key = VirtualminWebApps::Common::generate_random_key(32);
    my $settings_file = "$app_dir/settings.yml";

    my $settings_content = <<"EOF";
use_default_settings: true
server:
  port: 8080
  bind_address: "0.0.0.0"
  secret_key: "$secret_key"
  limiter: false
  image_proxy: true
ui:
  static_use_hash: true
search:
  safe_search: 0
  autocomplete: "duckduckgo"
EOF

    if (open(my $sfh, ">", $settings_file)) {
        print $sfh $settings_content;
        close($sfh);
        VirtualminWebApps::Common::secure_file_permissions($settings_file, 0600);
    }

    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:8080 " .
                     "-v $app_dir:/etc/searxng:Z " .
                     "docker.io/searxng/searxng:latest";

    my $service_content = <<"EOF";
[Unit]
Description=SearXNG Metasearch Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$app_dir
ExecStart=$exec_start
ExecStop=/usr/bin/$runtime stop -t 10 $service_name
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
        "searxng",
        $port,
        0,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $public_url = "$proto://$dom/";

    return (
        1,
        $public_url,
        "Installed and started SearXNG service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_searxng_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "searxng-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "searxng");

    my $app_dir = "$d->{'home'}/searxng";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
