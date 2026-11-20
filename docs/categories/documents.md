# Documents Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Document archiving, indexing, and Optical Character Recognition (OCR) systems.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **HedgeDoc** | `1.9.9` | `1` | Realtime Collaborative Markdown Notes (Node.js Container + Systemd) | [App Readme](../../apps/hedgedoc/README.md) |
| **Paperless-ngx** | `3.5.0` | `3` | Document Archiving, Indexing & OCR (Container + Systemd) | [App Readme](../../apps/paperless_ngx/README.md) |

---

## Technical Details

### HedgeDoc

* **Category**: Documents
* **Version**: `1.9.9` | **Build**: `1`
* **Upstream**: [https://hedgedoc.org](https://hedgedoc.org)
* **Architecture**: Realtime collaborative markdown notes platform with live preview, math rendering, and permission controls. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite / MariaDB.


### Paperless-ngx

* **Category**: Documents
* **Version**: `3.5.0` | **Build**: `3`
* **Upstream**: [https://docs.paperless-ngx.com](https://docs.paperless-ngx.com)
* **Architecture**: Automated document indexing, Optical Character Recognition (OCR), and searchable archiving platform running inside an isolated container with systemd integration and reverse proxying.
* **Database**: SQLite (or PostgreSQL via container).


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
