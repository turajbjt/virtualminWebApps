# Pi-hole for Virtualmin

[Pi-hole](https://pi-hole.net/) is a Linux network-level advertisement and internet tracker blocking application which acts as a DNS sinkhole.

## Features in this Virtualmin Module
* **Protected Host Services**: Runs in an isolated container environment (Podman or Docker) so it does not overwrite host Apache/Nginx web servers, BIND DNS servers, or PHP settings.
* **Automated Web Reverse Proxy**: Access the dashboard directly via `https://<domain>/admin/`.
* **Systemd Unit Management**: Starts, stops, and restarts with `systemctl` (`pihole-<domain>.service`).
* **Configurable Web & DNS Ports**: Customize ports cleanly to avoid conflicts on multi-tenant servers.

## Architecture & Storage
* **Data Storage**: `/home/<domain>/pihole-data/etc-pihole` and `/etc-dnsmasq.d`
* **Default Admin Port**: 8080 (reverse-proxied to `/admin/`)
* **Default DNS Port**: 53
