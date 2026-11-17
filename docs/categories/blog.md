# Blog Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Modern publishing platforms and lightweight flat-file blogging engines.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **FlatPress** | `1.5.1` | `3` | Lightweight Flat-File Blogging Engine (Zero SQL Database) | [App Readme](../../apps/flatpress/README.md) |
| **Ghost** | `5-alpine` | `3` | Node.js Publishing Platform + Systemd (Pro Equivalent) | [App Readme](../../apps/ghost/README.md) |

---

## Technical Details

### FlatPress

* **Category**: Blog
* **Version**: `1.5.1` | **Build**: `3`
* **Upstream**: [https://www.flatpress.org](https://www.flatpress.org)
* **Architecture**: Lightweight, standards-compliant blogging engine that stores posts, comments, and settings completely in flat text files with zero SQL database requirements.
* **Database**: None (Flat Files).


### Ghost

* **Category**: Blog / Publishing
* **Version**: `5-alpine` | **Build**: `3`
* **Upstream**: [https://ghost.org](https://ghost.org)
* **Architecture**: Node.js container daemon managed by systemd (`ghost-<domain>.service`) with Apache/Nginx reverse proxying to `127.0.0.1:2368`.
* **Data Storage**: `/home/<domain>/ghost-content`.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
