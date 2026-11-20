# Development Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Self-hosted Git repositories, continuous integration, workflow automation, developer tools, and backend utilities.

This classification includes **5 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Forgejo** | `17.0.1` | `3` | Standalone Go Binary + Systemd + Git Reverse Proxy | [App Readme](../../apps/forgejo/README.md) |
| **IT-Tools** | `2024.10.22` | `3` | Standalone Web Developer & Sysadmin Utilities | [App Readme](../../apps/it_tools/README.md) |
| **n8n** | `1.70.0` | `1` | Workflow Automation & Integration Platform (Container Daemon) | [App Readme](../../apps/n8n/README.md) |
| **PocketBase** | `0.25.9` | `1` | Realtime Backend & Embedded SQLite (Go Binary) | [App Readme](../../apps/pocketbase/README.md) |
| **Woodpecker CI** | `3.0.0` | `1` | Lightweight Pipeline CI Server (Go Binary + Systemd) | [App Readme](../../apps/woodpecker/README.md) |

---

## Technical Details

### Forgejo

* **Category**: Development
* **Version**: `17.0.1` | **Build**: `3`
* **Upstream**: [https://forgejo.org](https://forgejo.org)
* **Architecture**: Standalone static Go binary with MariaDB database backend and systemd unit (`forgejo-<domain>.service`).
* **Ports**:
  * HTTP Web: `127.0.0.1:3000` (reverse-proxied).
  * SSH Port: `2222` (configurable for Git over SSH).
* **Configuration**: `/home/<domain>/forgejo/custom/conf/app.ini`.
* **Repositories**: Stored in `/home/<domain>/forgejo/data/forgejo-repositories`.


### IT-Tools

* **Category**: Development / Utilities
* **Version**: `2024.10.22` | **Build**: `3`
* **Upstream**: [https://it-tools.tech](https://it-tools.tech)
* **Architecture**: Client-side collection of developer utilities (token generators, regex testers, converters, formatters) served as static pre-built assets. Zero server-side compute.


### n8n

* **Category**: Development
* **Version**: `1.70.0` | **Build**: `1`
* **Upstream**: [https://n8n.io](https://n8n.io)
* **Architecture**: Fair-code workflow automation platform (Zapier alternative) connecting webhooks, APIs, and AI agents via a visual editor. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


### PocketBase

* **Category**: Development
* **Version**: `0.25.9` | **Build**: `1`
* **Upstream**: [https://pocketbase.io](https://pocketbase.io)
* **Architecture**: Single standalone Go binary providing an embedded SQLite database with real-time SSE/WebSocket subscriptions, built-in auth, file storage, and web admin dashboard. Managed via systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


### Woodpecker CI

* **Category**: Development
* **Version**: `3.0.0` | **Build**: `1`
* **Upstream**: [https://woodpecker-ci.org](https://woodpecker-ci.org)
* **Architecture**: Community-driven, lightweight continuous integration engine in Go. Uses pipeline-as-code configuration and pairs natively with Forgejo and Gitea.
* **Database**: Embedded SQLite.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
