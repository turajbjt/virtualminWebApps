# Wiki Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Collaborative knowledge bases, technical documentation hubs, and team wikis.

This classification includes **4 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **BookStack** | `24.05.4` | `3` | Laravel / PHP / MariaDB + Automated Migrations | [App Readme](../../apps/bookstack/README.md) |
| **DokuWiki** | `2026-07-14c` | `3` | Standards-Compliant Flat-File Wiki (Zero Database) | [App Readme](../../apps/dokuwiki/README.md) |
| **MediaWiki** | `1.42.3` | `3` | PHP / MariaDB + Automated CLI Installer (Pro Equivalent) | [App Readme](../../apps/mediawiki/README.md) |
| **Wiki.js** | `2.5.303` | `1` | Modern Documentation & Wiki Platform (Container Daemon) | [App Readme](../../apps/wikijs/README.md) |

---

## Technical Details

### BookStack

* **Category**: Wiki
* **Version**: `24.05.4` | **Build**: `3`
* **Upstream**: [https://www.bookstackapp.com](https://www.bookstackapp.com)
* **Architecture**: Laravel PHP with MariaDB.
* **Installation**: Automated `.env` configuration, `artisan key:generate`, and database migration execution.
* **Default Credentials**: `admin@admin.com` / `password`.


### DokuWiki

* **Category**: Wiki
* **Version**: `2026-07-14c` | **Build**: `3`
* **Upstream**: [https://www.dokuwiki.org](https://www.dokuwiki.org)
* **Architecture**: Highly versatile, standards-compliant open-source wiki operating without any SQL database; stores documents in plain text with full ACLs and revision control.
* **Database**: Filesystem / Plain Text.


### MediaWiki

* **Category**: Wiki
* **Version**: `1.42.3` | **Build**: `3`
* **Upstream**: [https://www.mediawiki.org](https://www.mediawiki.org)
* **Architecture**: PHP with MariaDB/MySQL.
* **Installation**: Automated CLI installation using MediaWiki's `maintenance/run.php install` (generates `LocalSettings.php`, tables, and admin account).


### Wiki.js

* **Category**: Wiki
* **Version**: `2.5.303` | **Build**: `1`
* **Upstream**: [https://js.wiki](https://js.wiki)
* **Architecture**: Modern, extensible documentation wiki engine with Markdown, Visual WYSIWYG, AsciiDoc, full-text search, and automated two-way Git synchronization. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
