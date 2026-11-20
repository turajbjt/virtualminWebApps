# Homepage Application Dashboard for Virtualmin

**Homepage** is a modern, secure, and highly customizable application dashboard. It organizes your self-hosted web applications into logical service groups, queries server hardware metrics (CPU, RAM, disk, network), and displays live status widgets from services like Uptime Kuma, Nextcloud, and Netdata.

---

## Features

- **Service Tiles & Categorization**: Group your self-hosted Virtualmin apps into categorized visual tiles.
- **Service API Integrations**: Live widgets integrating with Uptime Kuma, Pi-hole, AdGuard Home, Nextcloud, and media servers.
- **Server Metrics**: Real-time CPU usage, memory stats, and disk storage inspection.
- **Fast & Modern**: Lightweight Node.js application styled with Tailwind CSS.

---

## Virtualmin Integration

- **Script Name**: `homepage.pl`
- **Category**: System
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Deployment**: Managed `systemd` service (`homepage-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.
- **Configuration**: YAML files (`services.yaml`, `widgets.yaml`, `settings.yaml`) stored in `~/homepage/config/`.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Homepage** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to customize your dashboard layout.
