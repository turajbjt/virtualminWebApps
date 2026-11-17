# apps/paperless_ngx/paperless_ngx.pl
# Virtualmin Web App installer for Paperless-ngx
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

sub script_paperless_ngx_desc
{
    return "Paperless-ngx - Document Management & OCR Archive";
}

sub script_paperless_ngx_uses
{
    return ( ); # Self-contained container service
}

sub script_paperless_ngx_category
{
    return "Documents";
}

sub script_paperless_ngx_author
{
    return "Paperless-ngx Community";
}

sub script_paperless_ngx_site
{
    return "https://docs.paperless-ngx.com";
}

sub script_paperless_ngx_versions
{
    return ( "3.5.0" );
}

sub script_paperless_ngx_release
{
    return 3;
}

sub script_paperless_ngx_passmode
{
    return 0; # Admin username and password provided in UI
}

sub script_paperless_ngx_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8000, 8999) || 8000;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"paperless_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Port for Paperless-ngx daemon, automatically reverse-proxied)</td> </tr>";

    $html .= "<tr> <td><b>Admin Username</b></td> <td>";
    $html .= "<input name=\"paperless_user\" size=\"20\" value=\"admin\"> ";
    $html .= "(Initial superuser account name)</td> </tr>";

    $html .= "<tr> <td><b>Admin Password</b></td> <td>";
    $html .= "<input name=\"paperless_pass\" size=\"20\" type=\"password\"> ";
    $html .= "(Password for admin account. Leave empty to auto-generate)</td> </tr>";

    $html .= "<tr> <td><b>OCR Language</b></td> <td>";
    $html .= "<input name=\"paperless_ocr_lang\" size=\"10\" value=\"eng\"> ";
    $html .= "(Default 3-letter OCR language code, e.g. eng, deu, fra, spa)</td> </tr>";

    return $html;
}

sub script_paperless_ngx_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'paperless_port'} || 8000;
    my $user = $in->{'paperless_user'} || 'admin';
    my $ocr_lang = $in->{'paperless_ocr_lang'} || 'eng';

    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    my $pass = $in->{'paperless_pass'};
    if (!$pass) {
        $pass = VirtualminWebApps::Common::generate_random_key(16);
    }

    return {
        'port'      => $port,
        'user'      => $user,
        'pass'      => $pass,
        'ocr_lang'  => $ocr_lang,
    };
}

sub script_paperless_ngx_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');

    if (!$has_docker && !$has_podman) {
        return "Paperless-ngx requires Podman or Docker to execute OCR, Redis, and Python ingestion engines safely in an isolated environment. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install podman').";
    }

    return undef;
}

sub script_paperless_ngx_files
{
    return ( );
}

sub script_paperless_ngx_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $home = $d->{'home'};
    my $port = $opts->{'port'};
    my $admin_user = $opts->{'user'};
    my $admin_pass = $opts->{'pass'};
    my $ocr_lang = $opts->{'ocr_lang'};
    my $service_name = "paperless-$dom";

    my $app_dir = "$home/paperless";
    my $data_dir = "$app_dir/data";
    my $media_dir = "$app_dir/media";
    my $consume_dir = "$app_dir/consume";
    my $export_dir = "$app_dir/export";

    make_path($app_dir, $data_dir, $media_dir, $consume_dir, $export_dir);
    VirtualminWebApps::Common::set_ownership_recursive($app_dir, $user, $group);

    my $secret_key = VirtualminWebApps::Common::generate_random_key(48);

    my $proto = $d->{'ssl'} ? 'https' : 'http';
    my $full_url = "$proto://$dom/";

    my $env_file = "$app_dir/paperless.env";
    if (open(my $efh, ">", $env_file)) {
        print $efh <<"EOF";
PAPERLESS_URL=$full_url
PAPERLESS_SECRET_KEY=$secret_key
PAPERLESS_ADMIN_USER=$admin_user
PAPERLESS_ADMIN_PASSWORD=$admin_pass
PAPERLESS_OCR_LANGUAGE=$ocr_lang
PAPERLESS_TIME_ZONE=UTC
PAPERLESS_TASK_WORKERS=2
PAPERLESS_THREADS_PER_WORKER=2
EOF
        close($efh);
        chmod(0600, $env_file);
    }

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";

    my $exec_start = "/usr/bin/$runtime run --rm --name $service_name " .
                     "-p 127.0.0.1:$port:8000 " .
                     "-v $data_dir:/usr/src/paperless/data:Z " .
                     "-v $media_dir:/usr/src/paperless/media:Z " .
                     "-v $consume_dir:/usr/src/paperless/consume:Z " .
                     "-v $export_dir:/usr/src/paperless/export:Z " .
                     "--env-file $env_file " .
                     "ghcr.io/paperless-ngx/paperless-ngx:latest";

    my $unit_content = <<"EOF";
[Unit]
Description=Paperless-ngx Document Management Service for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$app_dir
ExecStart=$exec_start
ExecStop=/usr/bin/$runtime stop -t 15 $service_name
Restart=always
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    my ($sok, $serr) = VirtualminWebApps::SystemdHelper::install_service_unit($service_name, $unit_content);
    return (0, "Systemd setup failed: $serr") if !$sok;

    # Configure Reverse Proxy with WebSocket forwarding
    my $webserver = ($d->{'proxy_pass_mode'} && $d->{'proxy_pass_mode'} eq 'nginx') ? 'nginx' : 'apache';
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::add_reverse_proxy(
        domain_name => $dom,
        local_port  => $port,
        path        => '/',
        webserver   => $webserver,
        websocket   => 1,
    );
    return (0, "Proxy configuration failed: $perr") if !$pok;

    my ($start_ok, $start_err) = VirtualminWebApps::SystemdHelper::start_service($service_name);
    return (0, "Failed to start Paperless-ngx service: $start_err") if !$start_ok;

    return (
        1,
        $full_url,
        "Installed Paperless-ngx to $full_url. Superuser: $admin_user (password configured during setup)."
    );
}

sub script_paperless_ngx_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $home = $d->{'home'};
    my $service_name = "paperless-$dom";
    my $app_dir = "$home/paperless";

    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $runtime = $has_podman ? "podman" : "docker";
    system("/usr/bin/$runtime stop -t 10 $service_name 2>/dev/null");

    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    my $webserver = ($d->{'proxy_pass_mode'} && $d->{'proxy_pass_mode'} eq 'nginx') ? 'nginx' : 'apache';
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy(
        domain_name => $dom,
        path        => '/',
        webserver   => $webserver,
    );

    return 1;
}

1;
