# apps/gotosocial/gotosocial.pl
# Virtualmin Web App installer for GoToSocial ActivityPub Server
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

sub script_gotosocial_desc
{
    return "GoToSocial - ActivityPub Social Server";
}

sub script_gotosocial_uses
{
    return ( "ssl" ); # Mandatory: ActivityPub federation requires TLS/HTTPS
}

sub script_gotosocial_category
{
    return "Community";
}

sub script_gotosocial_author
{
    return "GoToSocial Authors";
}

sub script_gotosocial_site
{
    return "https://gotosocial.org";
}

sub script_gotosocial_versions
{
    return ( "0.17.4" );
}

sub script_gotosocial_release
{
    return 1;
}

sub script_gotosocial_passmode
{
    return 2;
}

sub script_gotosocial_params
{
    my ($d) = @_;
    my $default_port = VirtualminWebApps::PortManager::find_free_port(8085, 8999) || 8085;

    my $html = "";
    $html .= "<tr> <td><b>Internal Port</b></td> <td>";
    $html .= "<input name=\"gotosocial_port\" size=\"6\" value=\"$default_port\"> ";
    $html .= "(Free local TCP port for the daemon, reverse-proxied with WebSockets)</td> </tr>";

    return $html;
}

sub script_gotosocial_parse
{
    my ($d, $in) = @_;
    my $port = $in->{'gotosocial_port'};
    if ($port !~ /^\d+$/ || $port < 1024 || $port > 65535) {
        return "Internal port must be a valid number between 1024 and 65535";
    }

    return { 'port' => $port };
}

sub script_gotosocial_check
{
    my ($d, $ver, $textdb, $dir) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();

    if ($arch ne 'amd64' && $arch ne 'arm64') {
        return "GoToSocial requires amd64 or arm64 architecture (detected: $arch).";
    }
    if (!$d->{'ssl'}) {
        return "GoToSocial requires SSL/HTTPS to be enabled on $d->{'dom'} for ActivityPub federation.";
    }

    return undef;
}

sub script_gotosocial_files
{
    my ($d, $ver, $opts) = @_;
    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "gotosocial_${ver}_linux_${arch}.tar.gz";
    my $url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v$ver/$filename";

    return (
        {
            'name' => $filename,
            'url'  => $url,
        }
    );
}

sub script_gotosocial_install
{
    my ($d, $ver, $opts, $defs, $setup) = @_;
    my $dom = $d->{'dom'};
    my $user = $d->{'user'};
    my $group = $d->{'group'} || $user;
    my $port = $opts->{'port'};
    my $service_name = "gotosocial-$dom";

    my $install_dir = "$d->{'home'}/gotosocial";
    make_path($install_dir) if !-d $install_dir;

    my $arch = VirtualminWebApps::Common::get_arch();
    my $filename = "gotosocial_${ver}_linux_${arch}.tar.gz";
    my $download_url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v$ver/$filename";
    my $tmp_file = "/tmp/gotosocial-$dom-$filename";
    my $tmp_unpack = "/tmp/gotosocial-$dom-unpack";

    my ($ok, $err) = VirtualminWebApps::Common::download_url($download_url, $tmp_file, 180);
    return (0, "Download failed: $err") if !$ok;

    make_path($tmp_unpack) if !-d $tmp_unpack;
    my ($eok, $eerr) = VirtualminWebApps::Common::extract_archive($tmp_file, $tmp_unpack);
    unlink($tmp_file);
    return (0, "Extraction failed: $eerr") if !$eok;

    # Locate binary
    my $bin_source = "";
    my @candidates = glob("$tmp_unpack/gotosocial*/gotosocial");
    if (@candidates && -f $candidates[0]) {
        $bin_source = $candidates[0];
    } elsif (-f "$tmp_unpack/gotosocial") {
        $bin_source = "$tmp_unpack/gotosocial";
    }

    my $bin_path = "$install_dir/gotosocial";
    if ($bin_source && -f $bin_source) {
        system("cp $bin_source $bin_path");
    }
    remove_tree($tmp_unpack);

    chmod(0755, $bin_path);

    my $storage_dir = "$install_dir/storage";
    make_path($storage_dir) if !-d $storage_dir;

    # Write config.yaml
    my $config_file = "$install_dir/config.yaml";
    my $conf_content = <<"EOF";
host: $dom
bind-address: 127.0.0.1
port: $port
db-type: sqlite
db-address: sqlite.db
storage-backend: local
storage-local-base-path: ./storage
accounts-registration-open: false
log-level: info
EOF

    if (open(my $cfh, ">", $config_file)) {
        print $cfh $conf_content;
        close($cfh);
        VirtualminWebApps::Common::secure_file_permissions($config_file, 0600);
    }

    VirtualminWebApps::Common::set_ownership_recursive($install_dir, $user, $group);

    # Create systemd service unit
    my $service_content = <<"EOF";
[Unit]
Description=GoToSocial ActivityPub Server for $dom
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$user
Group=$group
WorkingDirectory=$install_dir
ExecStart=$bin_path --config-path $config_file server start
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

    # Configure Reverse Proxy with WebSockets
    my ($pok, $perr) = VirtualminWebApps::ProxyHelper::setup_reverse_proxy(
        $d,
        "gotosocial",
        $port,
        1,
        '/'
    );
    return (0, "Failed to configure reverse proxy: $perr") if !$pok;

    my $public_url = "https://$dom/";

    return (
        1,
        $public_url,
        "Installed and started GoToSocial service ($service_name) on port $port reverse-proxied to $public_url."
    );
}

sub script_gotosocial_uninstall
{
    my ($d, $ver, $opts) = @_;
    my $dom = $d->{'dom'};
    my $service_name = "gotosocial-$dom";

    VirtualminWebApps::SystemdHelper::stop_service($service_name);
    VirtualminWebApps::SystemdHelper::disable_service($service_name);
    VirtualminWebApps::SystemdHelper::remove_service_unit($service_name);

    VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, "gotosocial");

    my $install_dir = "$d->{'home'}/gotosocial";
    remove_tree($install_dir) if -d $install_dir;

    return 1;
}

1;
