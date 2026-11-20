# Chat Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Real-time team collaboration, messaging, and chat platforms.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Conduit** | `0.8.0` | `1` | Lightweight Matrix Homeserver (Rust Binary + Systemd) | [App Readme](../../apps/conduit/README.md) |
| **Mattermost** | `10.5.1` | `3` | Team Collaboration & Chat Platform (Go Binary + Systemd) | [App Readme](../../apps/mattermost/README.md) |

---

## Technical Details

### Conduit

* **Category**: Chat
* **Version**: `0.8.0` | **Build**: `1`
* **Upstream**: [https://conduit.rs](https://conduit.rs)
* **Architecture**: Ultra-lightweight, high-performance Matrix homeserver in Rust designed for minimal RAM usage and rapid federation. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.

---

### Mattermost

* **Category**: Chat
* **Version**: `10.5.1` | **Build**: `3`
* **Upstream**: [https://mattermost.com](https://mattermost.com)
* **Architecture**: High-performance, open-source team collaboration and messaging service written in Go. Runs as a systemd service, backed by MariaDB, and reverse-proxied with full WebSocket forwarding.
* **Database**: MariaDB / MySQL.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
