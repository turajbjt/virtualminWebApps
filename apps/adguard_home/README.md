# AdGuard Home for Virtualmin

[AdGuard Home](https://adguard.com/en/adguard-home.html) is a network-wide software for blocking ads, tracking, and telemetry across all devices on your network. It operates as a local DNS server that re-routes tracking domains to a "black hole".

## Features in this Virtualmin Module
* **Zero Runtime Dependencies**: Uses the official standalone pre-compiled Go binary (automatically matching amd64, arm64, or armv7 architectures).
* **Systemd Service Integration**: Runs as a monitored system service (`adguard-home-<domain>.service`) with `CAP_NET_BIND_SERVICE` enabled.
* **Automatic Web Reverse Proxy**: Proxies the web dashboard to the Virtualmin domain so users can access the administrative UI securely over HTTP/HTTPS without opening additional firewall ports for web traffic.
* **Configurable Ports**: Allows custom DNS ports (if BIND or local resolver already uses port 53) and custom internal web admin ports.

## Architecture & Storage
* **Installation Directory**: `/home/<domain>/adguard-home`
* **Configuration File**: `/home/<domain>/adguard-home/AdGuardHome.yaml`
* **Default Internal Web Port**: 3000 (reverse proxied to domain root)
* **Default DNS Port**: 53
