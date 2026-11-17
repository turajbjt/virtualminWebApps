# Netdata Virtualmin Installer

**Netdata** is a high-performance, real-time observability platform designed to monitor systems, hardware, containers, and applications with per-second metrics and zero-configuration dashboards.

## Architecture
- **Runtime**: Isolated daemon via container runtime (Podman or Docker)
- **Host Metrics**: Read-only mounts to `/proc`, `/sys`, and `/etc`
- **Process Management**: Systemd unit (`netdata-<dom>.service`)
- **Web Server**: Apache or Nginx reverse proxy with WebSocket support

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Netdata** or using the CLI:
```bash
./setup.sh install
```
Dashboard URL: `https://<domain>/` (reverse-proxied to internal daemon port).
