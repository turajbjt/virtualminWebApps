# Wiki Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Collaborative knowledge bases, technical documentation hubs, and team wikis.

This classification includes **3 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **BookStack** | `24.05.4` | `2` | Laravel / PHP / MariaDB + Automated Migrations | [App Readme](../../apps/bookstack/README.md) |
| **DokuWiki** | `2026-07-14c` | `2` | Standards-Compliant Flat-File Wiki (Zero Database) | [App Readme](../../apps/dokuwiki/README.md) |
| **MediaWiki** | `1.42.3` | `2` | PHP / MariaDB + Automated CLI Installer (Pro Equivalent) | [App Readme](../../apps/mediawiki/README.md) |

---

## Technical Details

### BookStack

* **Category**: Wiki
* **Version**: `24.05.4` | **Build**: `2`
* **Upstream**: [https://www.bookstackapp.com](https://www.bookstackapp.com)
* **Architecture**: Laravel PHP with MariaDB.
* **Installation**: Automated `.env` configuration, `artisan key:generate`, and database migration execution.
* **Default Credentials**: `admin@admin.com` / `password`.


### DokuWiki

* **Category**: Wiki
* **Version**: `2026-07-14c` | **Build**: `2`
* **Upstream**: [https://www.dokuwiki.org](https://www.dokuwiki.org)
* **Architecture**: Highly versatile, standards-compliant open-source wiki operating without any SQL database; stores documents in plain text with full ACLs and revision control.
* **Database**: Filesystem / Plain Text.


### MediaWiki

* **Category**: Wiki
* **Version**: `1.42.3` | **Build**: `2`
* **Upstream**: [https://www.mediawiki.org](https://www.mediawiki.org)
* **Architecture**: PHP with MariaDB/MySQL.
* **Installation**: Automated CLI installation using MediaWiki's `maintenance/run.php install` (generates `LocalSettings.php`, tables, and admin account).


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
