# System & DNS Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Network-wide DNS sinkholes, monitoring dashboards, notifications, and web file managers.

This classification includes **6 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **AdGuard Home** | `0.107.80` | `3` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](../../apps/adguard_home/README.md) |
| **File Browser** | `2.30.0` | `3` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](../../apps/filebrowser/README.md) |
| **Gotify** | `3.1.1` | `3` | Real-Time Push Notification Server (Go Binary + WebSockets) | [App Readme](../../apps/gotify/README.md) |
| **Netdata** | `latest` | `3` | Real-Time Metrics & Observability Daemon + Reverse Proxy | [App Readme](../../apps/netdata/README.md) |
| **Pi-hole** | `latest` | `3` | Containerized Daemon + Systemd + Web Reverse Proxy | [App Readme](../../apps/pihole/README.md) |
| **Uptime Kuma** | `latest` | `3` | Node.js Daemon + Systemd + WebSocket Reverse Proxy | [App Readme](../../apps/uptime_kuma/README.md) |

---

## Technical Details

### AdGuard Home

* **Category**: System / DNS
* **Version**: `0.107.80` | **Build**: `3`
* **Upstream**: [https://adguard.com/en/adguard-home.html](https://adguard.com/en/adguard-home.html)
* **Architecture**: Standalone pre-compiled Go binary (amd64, arm64, armv7) managed by systemd (`adguard-home-<domain>.service`).
* **Ports**:
  * Web Dashboard: `127.0.0.1:3000` (automatically reverse-proxied to domain root).
  * DNS Port: `53` (TCP/UDP, configurable if local BIND or resolver uses 53).
* **Configuration**: `/home/<domain>/adguard-home/AdGuardHome.yaml`


### File Browser

* **Category**: System
* **Version**: `2.30.0` | **Build**: `3`
* **Upstream**: [https://filebrowser.org](https://filebrowser.org)
* **Architecture**: Single static Go binary (~15MB RAM) running as a systemd service under the domain user.
* **Default Port**: `127.0.0.1:8085` (reverse-proxied to domain root).
* **Root Directory**: Bound to `/home/<domain>` for full home directory management.
* **Default Credentials**: `admin` / `admin`.


### Gotify

* **Category**: System
* **Version**: `3.1.1` | **Build**: `3`
* **Upstream**: [https://gotify.net](https://gotify.net)
* **Architecture**: Real-time push notification and messaging server in Go, featuring continuous WebSockets, REST API message dispatch, and native Android app synchronization.
* **Database**: Embedded SQLite.


### Netdata

* **Category**: System
* **Version**: `latest` | **Build**: `3`
* **Upstream**: [https://www.netdata.cloud](https://www.netdata.cloud)
* **Architecture**: Real-time infrastructure observability and metrics dashboard running as a containerized system daemon (`netdata-<dom>.service`), reverse-proxied to internal port 19999 with WebSocket support.


### Pi-hole

* **Category**: System / DNS
* **Version**: `latest` | **Build**: `3`
* **Upstream**: [https://pi-hole.net](https://pi-hole.net)
* **Architecture**: Isolated container daemon (Podman or Docker) preventing conflicts with host web and DNS services.
* **Ports**:
  * Web Admin: `127.0.0.1:8080` (reverse-proxied to `https://<domain>/admin/`).
  * DNS Port: `53` (TCP/UDP).
* **Data Storage**: `/home/<domain>/pihole-data/etc-pihole` and `/etc-dnsmasq.d`.


### Uptime Kuma

* **Category**: System
* **Version**: `latest` | **Build**: `3`
* **Upstream**: [https://uptime.kuma.pet](https://uptime.kuma.pet)
* **Architecture**: High-performance Node.js service running via container and systemd.
* **Ports**: `127.0.0.1:3001` (reverse-proxied with full WebSocket / Socket.io forwarding).
* **Data Storage**: `/home/<domain>/uptime-kuma-data/`.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
