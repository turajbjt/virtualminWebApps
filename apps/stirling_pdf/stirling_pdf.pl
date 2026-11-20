# apps/stirling_pdf/stirling_pdf.pl
# Virtualmin Web App installer for Stirling-PDF Web-Based PDF Tools
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

sub script_stirling_pdf_desc
{
    return "Stirling-PDF - Web-Based PDF Tools Suite";
}

sub script_stirling_pdf_uses
{
    return ( );
}

sub script_stirling_pdf_category
{
    return "Utilities";
}

sub script_stirling_pdf_author
{
    return "Stirling-Tools Community";
}

sub script_stirling_pdf_site
{
    return "https://github.com/Stirling-Tools/Stirling-PDF";
}

sub script_stirling_pdf_versions
{
    return ( "0.44.0" );
}

sub script_stirling_pdf_release
{
    return 1;
}

sub script_stirling_pdf_passmode
{
    return 2;
}

sub script_stirling_pdf_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8080, 8999) || 8080;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"stirling_pdf_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied)</td> </tr>";

    return $html;
}

sub script_stirling_pdf_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'stirling_pdf_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_stirling_pdf_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_container = VirtualminWebApps::Common::has_command('podman') ||
                        VirtualminWebApps::Common::has_command('docker');
    if (!$has_container) {
        return "Stirling-PDF requires a container runtime (podman or docker) installed on the system.";
    }

    return undef;
}

sub script_stirling_pdf_files
{
    my ($d, $ver, $opts) = @_;
    return ();
}

sub script_stirling_pdf_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "stirling-pdf-$dom";

    my $app_dir = "$d->{'home'}/stirling-pdf";
    my $training_dir = "$app_dir/trainingData";
    my $configs_dir = "$app_dir/extraConfigs";
    my $logs_dir = "$app_dir/logs";
    my $custom_dir = "$app_dir/customFiles";

    make_path($app_dir, $training_dir, $configs_dir, $logs_dir, $custom_dir);
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:8080 " .
                     "-v $training_dir:/usr/share/tessdata:Z " .
                     "-v $configs_dir:/configs:Z " .
                     "-v $logs_dir:/logs:Z " .
                     "-v $custom_dir:/customFiles:Z " .
                     "-e SECURITY_ENABLELOGIN=false " .
                     "docker.io/frooodle/s-pdf:latest";

    my $service_content = <<"EOF";
[Unit]
Description=Stirling-PDF Tools Server for $dom
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
        "stirling_pdf",
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
        "Installed and started Stirling-PDF service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_stirling_pdf_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "stirling-pdf-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "stirling_pdf");

    my $app_dir = "$d->{'home'}/stirling-pdf";
    remove_tree($app_dir) if -d $app_dir;

    return 1;
}

1;
