# Development Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Self-hosted Git repositories, developer tools, code collaboration, and sysadmin utilities.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Forgejo** | `17.0.1` | `3` | Standalone Go Binary + Systemd + Git Reverse Proxy | [App Readme](../../apps/forgejo/README.md) |
| **IT-Tools** | `2024.10.22` | `3` | Standalone Web Developer & Sysadmin Utilities | [App Readme](../../apps/it_tools/README.md) |

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


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
