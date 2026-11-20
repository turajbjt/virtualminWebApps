# Sync Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

CalDAV, CardDAV, calendar, address book, and peer-to-peer continuous file synchronization services.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Baikal** | `0.13.0` | `3` | Lightweight CalDAV & CardDAV Contacts/Calendar Sync | [App Readme](../../apps/baikal/README.md) |
| **Syncthing** | `1.29.2` | `1` | Continuous Decentralized File Synchronization (Go Binary) | [App Readme](../../apps/syncthing/README.md) |

---

## Technical Details

### Baikal

* **Category**: Sync
* **Version**: `0.13.0` | **Build**: `3`
* **Upstream**: [https://sabre.io/baikal/](https://sabre.io/baikal/)
* **Architecture**: Lightweight CalDAV and CardDAV server for cross-device contacts and calendar synchronization.
* **Database**: SQLite / MariaDB.


### Syncthing

* **Category**: Sync
* **Version**: `1.29.2` | **Build**: `1`
* **Upstream**: [https://syncthing.net](https://syncthing.net)
* **Architecture**: Continuous, decentralized, peer-to-peer file synchronization engine with TLS mutual authentication and web management GUI. Managed via systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite / LevelDB.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
