# lib/PortManager.pl
# Dynamic TCP port detection and allocation for Virtualmin reverse-proxied services
# Hardened with input validation against out-of-range port requests
package VirtualminWebApps::PortManager;

use strict;
use warnings;
use IO::Socket::INET;

# is_port_in_use($port, [$ip])
sub is_port_in_use
{
    my ($port, $ip) = @_;
    $ip ||= '127.0.0.1';

    return 1 if !defined($port) || $port !~ /^\d+$/ || $port < 1 || $port > 65535;

    # 1. Attempt connection
    my $sock = IO::Socket::INET->new(
        PeerAddr => $ip,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 1,
    );

    if ($sock) {
        close($sock);
        return 1; # Port is listening and responded
    }

    # 2. Attempt to bind to it locally to check if we can listen
    my $bind_sock = IO::Socket::INET->new(
        LocalAddr => $ip,
        LocalPort => $port,
        Proto     => 'tcp',
        Listen    => 1,
        ReuseAddr => 1,
    );

    if ($bind_sock) {
        close($bind_sock);
        return 0; # Successfully bound, port is free
    }

    return 1; # Failed to bind, likely in use or restricted
}

# find_free_port($start_port, [$max_port], [$ip])
# Searches incrementally for the next free TCP port
sub find_free_port
{
    my ($start_port, $max_port, $ip) = @_;
    $start_port = 8000 if !defined($start_port) || $start_port !~ /^\d+$/ || $start_port < 1024 || $start_port > 65535;
    $max_port   = $start_port + 1000 if !defined($max_port) || $max_port !~ /^\d+$/ || $max_port < $start_port || $max_port > 65535;
    $ip         ||= '127.0.0.1';

    for (my $p = $start_port; $p <= $max_port; $p++) {
        if (!&is_port_in_use($p, $ip)) {
            return $p;
        }
    }

    return undef;
}

1;
