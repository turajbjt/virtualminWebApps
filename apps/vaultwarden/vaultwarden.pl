# apps/vaultwarden/vaultwarden.pl
# Virtualmin Web App installer for Vaultwarden Password Manager
#

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);

# Include shared libraries
BEGIN {
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";
require "PortManager.pl";
require "SystemdHelper.pl";
require "ProxyHelper.pl";

sub script_vaultwarden_desc
{
    return "Vaultwarden Password Manager";
}

sub script_vaultwarden_uses
{
    return ( "ssl" ); # Mandatory: Bitwarden Web Crypto APIs require HTTPS
}

sub script_vaultwarden_category
{
    return "Security";
}

sub script_vaultwarden_author
{
    return "Dani Garcia / Vaultwarden Project";
}

sub script_vaultwarden_site
{
    return "https://github.com/dani-garcia/vaultwarden";
}

sub script_vaultwarden_versions
{
    return ( "1.32.7", "latest" );
}

sub script_vaultwarden_release
{
    return 2;
}

sub script_vaultwarden_passmode
{
    return 2; # Web app handles accounts/passwords internally
}

# script_vaultwarden_params(&domain)
# Renders custom parameters form in Virtualmin's Install Script interface
sub script_vaultwarden_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8000, 8999) || 8000;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"vaultwarden_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the backend daemon)</td> </tr>";

    $html .= "<tr> <td><b>Allow Signups</b></td> <td>";
    $html .= "<input type=\"radio\" name=\"vaultwarden_signups\" value=\"true\" checked> Yes &nbsp; ";
    $html .= "<input type=\"radio\" name=\"vaultwarden_signups\" value=\"false\"> No (Invite only)";
    $html .= "</td> </tr>";

    $html .= "<tr> <td><b>Admin Token</b></td> <td>";
    $html .= "<input name=\"vaultwarden_admin_token\" size=\"35\" type=\"password\" placeholder=\"Optional - for /admin console\">";
    $html .= "</td> </tr>";

    $html .= "<tr> <td><b>WebSockets Enabled</b></td> <td>";
    $html .= "<input type=\"checkbox\" name=\"vaultwarden_websocket\" value=\"1\" checked> ";
    $html .= "Enable real-time sync notifications (/notifications/hub)</td> </tr>";

    return $html;
}

# script_vaultwarden_parse(&domain, &in)
# Validates parameters submitted by the user
sub script_vaultwarden_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'vaultwarden_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    my $signups = defined($in->{'vaultwarden_signups'}) && $in->{'vaultwarden_signups'} eq 'false' ? 'false' : 'true';
    return {
        'port'        => $port,
        'signups'     => $signups,
        'admin_token' => $in->{'vaultwarden_admin_token'} || '',
        'websocket'   => $in->{'vaultwarden_websocket'} ? 1 : 0,
    };
}

# script_vaultwarden_check(&domain, $version, $dbtype, $dir)
# Checks requirements before proceeding with installation
sub script_vaultwarden_check
{
    my ($d, $ver, $textdb, $dir) = @_;

    # SSL is strictly required for Web Crypto
    if (!$d->{'ssl'}) {
        return "Vaultwarden requires SSL/TLS to be enabled for $d->{'dom'}, because modern browsers require HTTPS for Bitwarden cryptographic vault operations.";
    }

    # Check for container runtime or native binary
    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $has_binary = VirtualminWebApps::Common::has_command('vaultwarden') || -x "$d->{'home'}/vaultwarden/vaultwarden";

    if (!$has_docker && !$has_podman && !$has_binary) {
        return "Neither Docker, Podman, nor a native 'vaultwarden' binary was found on this system. Please install Podman or Docker (e.g. 'dnf install podman' or 'apt install docker.io') to run Vaultwarden.";
    }

    return undef;
}

# script_vaultwarden_files(&domain, $version, $options)
# Sources to download if applicable
sub script_vaultwarden_files
{
    return ();
}

# script_vaultwarden_install(&domain, $version, $options, $defs, $setup)
# Performs the full installation
sub script_vaultwarden_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "vaultwarden-$dom";

    my $data_dir = "$d->{'home'}/vaultwarden-data";
    make_path($data_dir) if !-d $data_dir;
    VirtualminWebApps::Common::set_ownership_recursive($data_dir, $user, $group);

    # Create environment configuration file
    my $env_file = "$d->{'home'}/vaultwarden.env";
    open(my $efh, '>', $env_file) or return (0, "Cannot write to $env_file: $!");
    print $efh "ROCKET_PORT=$port\n";
    print $efh "ROCKET_ADDRESS=127.0.0.1\n";
    print $efh "DOMAIN=https://$dom\n";
    print $efh "SIGNUPS_ALLOWED=" . ($opts->{'signups'} eq 'false' ? 'false' : 'true') . "\n";
    print $efh "DATA_FOLDER=$data_dir\n";
    print $efh "WEBSOCKET_ENABLED=" . ($opts->{'websocket'} ? 'true' : 'false') . "\n";
    print $efh "WEBSOCKET_PORT=" . ($port + 1000) . "\n" if $opts->{'websocket'};
    if ($opts->{'admin_token'}) {
        print $efh "ADMIN_TOKEN=" . $opts->{'admin_token'} . "\n";
    }
    close($efh);
    chmod(0600, $env_file);
    VirtualminWebApps::Common::set_ownership_recursive($env_file, $user, $group);

    # Determine execution mechanism
    my $has_docker = VirtualminWebApps::Common::has_command('docker');
    my $has_podman = VirtualminWebApps::Common::has_command('podman');
    my $exec_start = "";
    my $run_user = $user;

    if ($has_podman) {
        $exec_start = "/usr/bin/podman run --rm --name $service_name " .
                      "-p 127.0.0.1:$port:80 " .
                      "--env-file $env_file " .
                      "-v $data_dir:/data:Z " .
                      "docker.io/vaultwarden/server:$ver";
        # Podman can run rootless as domain user
    }
    elsif ($has_docker) {
        $exec_start = "/usr/bin/docker run --rm --name $service_name " .
                      "-p 127.0.0.1:$port:80 " .
                      "--env-file $env_file " .
                      "-v $data_dir:/data " .
                      "vaultwarden/server:$ver";
        $run_user = "root"; # Docker daemon requires root control
    }
    else {
        my $bin = -x "$d->{'home'}/vaultwarden/vaultwarden" ? "$d->{'home'}/vaultwarden/vaultwarden" : `which vaultwarden 2>/dev/null`;
        chomp($bin);
        $exec_start = "$bin";
    }

    # Generate and install systemd unit
    my $service_content = <<"EOF";
[Unit]
Description=Vaultwarden Password Manager for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$run_user
Group=$group
WorkingDirectory=$data_dir
EnvironmentFile=-$env_file
ExecStart=$exec_start
Restart=always
RestartSec=5s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    my ($ok, $err) = VirtualminWebApps::SystemdHelper::create_service_unit($service_name, $service_content);
    return (0, "Failed to create systemd unit: $err") if !$ok;

    VirtualminWebApps::SystemdHelper::enable_service($service_name);
    VirtualminWebApps::SystemdHelper::start_service($service_name);

    # Configure Reverse Proxy in Apache or Nginx
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "vaultwarden",
        $port,
        $opts->{'websocket'},
        '/'
    );
    if (!$pok) {
        return (0, "Failed to configure reverse proxy: $perr");
    }

    return (1, "https://$dom/", "Installed Vaultwarden Password Manager service listening on port $port and reverse-proxied to https://$dom/");
}

# script_vaultwarden_uninstall(&domain, $version, $options)
# Clean removal of the service and proxy
sub script_vaultwarden_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "vaultwarden-$dom";

    # Stop container if running under docker/podman
    if (VirtualminWebApps::Common::has_command('podman')) {
        system("podman stop $service_name 2>/dev/null || true");
    }
    if (VirtualminWebApps::Common::has_command('docker')) {
        system("docker stop $service_name 2>/dev/null || true");
    }

    # Remove systemd service
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    # Remove reverse proxy from Apache/Nginx
    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "vaultwarden");

    return 1;
}

# script_vaultwarden_upgrade(&domain, $version, $options)
sub script_vaultwarden_upgrade
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "vaultwarden-$dom";

    # If containerized, pull new image and restart service
    if (VirtualminWebApps::Common::has_command('podman')) {
        system("podman pull docker.io/vaultwarden/server:$ver");
    } elsif (VirtualminWebApps::Common::has_command('docker')) {
        system("docker pull vaultwarden/server:$ver");
    }

    VirtualminWebApps::SystemdHelper::restart_service($service_name);
    return 1;
}

1;
