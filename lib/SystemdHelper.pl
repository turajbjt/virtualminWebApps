# lib/SystemdHelper.pl
# Systemd service unit management for daemon-based Virtualmin web applications
package VirtualminWebApps::SystemdHelper;

use strict;
use warnings;
use File::Path qw(make_path);

our $SYSTEMD_SYSTEM_DIR = "/etc/systemd/system";

# create_service_unit($service_name, $unit_content)
# Writes a .service file and executes daemon-reload
sub create_service_unit
{
    my ($service_name, $content) = @_;
    $service_name .= ".service" if $service_name !~ /\.service$/;

    my $file_path = "$SYSTEMD_SYSTEM_DIR/$service_name";
    
    open(my $fh, '>', $file_path) or return (0, "Cannot write to $file_path: $!");
    print $fh $content;
    close($fh);

    chmod(0644, $file_path);
    &systemctl("daemon-reload");

    return (1, $file_path);
}

# remove_service_unit($service_name)
# Stops, disables, removes unit file and reloads systemd
sub remove_service_unit
{
    my ($service_name) = @_;
    $service_name .= ".service" if $service_name !~ /\.service$/;

    &stop_service($service_name);
    &disable_service($service_name);

    my $file_path = "$SYSTEMD_SYSTEM_DIR/$service_name";
    if (-f $file_path) {
        unlink($file_path);
    }

    &systemctl("daemon-reload");
    return 1;
}

# start_service($service_name)
sub start_service
{
    my ($service_name) = @_;
    return &systemctl("start", $service_name);
}

# stop_service($service_name)
sub stop_service
{
    my ($service_name) = @_;
    return &systemctl("stop", $service_name);
}

# restart_service($service_name)
sub restart_service
{
    my ($service_name) = @_;
    return &systemctl("restart", $service_name);
}

# enable_service($service_name)
sub enable_service
{
    my ($service_name) = @_;
    return &systemctl("enable", $service_name);
}

# disable_service($service_name)
sub disable_service
{
    my ($service_name) = @_;
    return &systemctl("disable", $service_name);
}

# is_service_active($service_name)
sub is_service_active
{
    my ($service_name) = @_;
    my ($rc, $out) = &systemctl("is-active", $service_name);
    chomp($out);
    return ($rc == 0 && $out eq "active") ? 1 : 0;
}

# systemctl(@args)
sub systemctl
{
    my (@args) = @_;
    my $cmd = "systemctl " . join(" ", map { quotemeta($_) } @args) . " 2>&1";
    my $out = `$cmd`;
    my $rc = $? >> 8;
    return ($rc, $out);
}

1;
