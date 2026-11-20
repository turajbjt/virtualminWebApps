# Utilities Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Specialized developer utilities, home pantry ERP, PDF manipulation tools, privacy metasearch engines, encrypted pastebins, link hubs, and URL shorteners.

This classification includes **13 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Changedetection.io** | `0.47.06` | `1` | Web Page Change & Price Monitor (Container Daemon) | [App Readme](../../apps/changedetection/README.md) |
| **CyberChef** | `11.5.0` | `3` | Client-Side Cyber Security Swiss Army Knife | [App Readme](../../apps/cyberchef/README.md) |
| **Grocy** | `4.4.2` | `1` | Home Pantry & Asset Management ERP (PHP / SQLite) | [App Readme](../../apps/grocy/README.md) |
| **Linkding** | `1.38.1` | `1` | Minimalist Self-Hosted Bookmark Manager (Container Daemon) | [App Readme](../../apps/linkding/README.md) |
| **LinkStack** | `4.8.8` | `3` | Open-Source Linktree Alternative & Bio Link Hub (PHP) | [App Readme](../../apps/linkstack/README.md) |
| **Meilisearch** | `1.12.0` | `1` | Fast Open-Source Search Engine (Rust Binary + Systemd) | [App Readme](../../apps/meilisearch/README.md) |
| **Microbin** | `2.1.0` | `3` | Lightweight Encrypted Pastebin & File Sharing (Rust Binary) | [App Readme](../../apps/microbin/README.md) |
| **SearXNG** | `2024.11.20` | `1` | Privacy-Respecting Metasearch Engine (Container Daemon) | [App Readme](../../apps/searxng/README.md) |
| **Shaarli** | `0.16.10` | `3` | Personal Minimalist Bookmarking & Link Sharing | [App Readme](../../apps/shaarli/README.md) |
| **Shlink** | `4.2.1` | `1` | Self-Hosted URL Shortener with Analytics (PHP / MariaDB) | [App Readme](../../apps/shlink/README.md) |
| **Stirling-PDF** | `0.44.0` | `1` | Web-Based PDF Tools Suite (Container Daemon) | [App Readme](../../apps/stirling_pdf/README.md) |
| **Wallabag** | `2.6.17` | `3` | Self-Hosted Read-It-Later & Article Archiver (PHP / MariaDB) | [App Readme](../../apps/wallabag/README.md) |
| **YOURLS** | `1.10.6` | `3` | Your Own URL Shortener with Click Analytics & API | [App Readme](../../apps/yourls/README.md) |

---

## Technical Details

### Changedetection.io

* **Category**: Utilities
* **Version**: `0.47.06` | **Build**: `1`
* **Upstream**: [https://changedetection.io](https://changedetection.io)
* **Architecture**: Automated website change detection, price alert, and restock tracking service with multi-channel notifications. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: None.


### CyberChef

* **Category**: Utilities
* **Version**: `11.5.0` | **Build**: `3`
* **Upstream**: [https://gchq.github.io/CyberChef/](https://gchq.github.io/CyberChef/)
* **Architecture**: GCHQ's "Cyber Swiss Army Knife" — 100% client-side HTML5 & WebAssembly web app. Zero server-side runtime or database requirement.


### Grocy

* **Category**: Utilities
* **Version**: `4.4.2` | **Build**: `1`
* **Upstream**: [https://grocy.info](https://grocy.info)
* **Architecture**: Web-based ERP for home and household management (groceries, pantry inventory, recipes, tasks, and battery tracking). Pure PHP application with embedded SQLite database.
* **Database**: Embedded SQLite.


### Linkding

* **Category**: Utilities
* **Version**: `1.38.1` | **Build**: `1`
* **Upstream**: [https://github.com/sissbruecker/linkding](https://github.com/sissbruecker/linkding)
* **Architecture**: Minimalist, fast, tag-based self-hosted bookmark manager with archive snapshotting and browser extensions. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


### LinkStack

* **Category**: Utilities
* **Version**: `4.8.8` | **Build**: `3`
* **Upstream**: [https://linkstack.org](https://linkstack.org)
* **Architecture**: Privacy-respecting open-source link-in-bio platform and Linktree alternative featuring customizable themes, vCard downloads, and multi-user support.
* **Database**: SQLite / MariaDB.


### Meilisearch

* **Category**: Utilities
* **Version**: `1.12.0` | **Build**: `1`
* **Upstream**: [https://www.meilisearch.com](https://www.meilisearch.com)
* **Architecture**: Lightning-fast, typo-tolerant open-source search engine in Rust with instant search-as-you-type (<50ms). Supervised by systemd and reverse-proxied.
* **Database**: Embedded LMDB.


### Microbin

* **Category**: Utilities
* **Version**: `2.1.0` | **Build**: `3`
* **Upstream**: [https://microbin.eu](https://microbin.eu)
* **Architecture**: Ultra-fast, zero-dependency encrypted pastebin and file sharing service written in Rust, featuring client-side encryption, burn-after-reading expiration, and QR code sharing.
* **Database**: Filesystem / Embedded.


### SearXNG

* **Category**: Utilities
* **Version**: `2024.11.20` | **Build**: `1`
* **Upstream**: [https://github.com/searxng/searxng](https://github.com/searxng/searxng)
* **Architecture**: Privacy-respecting metasearch engine aggregating results from over 70 search services with zero query profiling or IP logging. Supervised by systemd and reverse-proxied.
* **Database**: None.


### Shaarli

* **Category**: Utilities
* **Version**: `0.16.10` | **Build**: `3`
* **Upstream**: [https://shaarli.readthedocs.io](https://shaarli.readthedocs.io)
* **Architecture**: Personal, minimalist, zero-SQL link sharing and bookmarking service with built-in tagging, full privacy, and flat-file storage.
* **Database**: Flat-file JSON/datastore.


### Shlink

* **Category**: Utilities
* **Version**: `4.2.1` | **Build**: `1`
* **Upstream**: [https://shlink.io](https://shlink.io)
* **Architecture**: Open-source self-hosted URL shortener with REST API, detailed geolocated analytics, QR codes, and multi-domain support.
* **Database**: MariaDB / MySQL.


### Stirling-PDF

* **Category**: Utilities
* **Version**: `0.44.0` | **Build**: `1`
* **Upstream**: [https://github.com/Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
* **Architecture**: Locally hosted, browser-based PDF manipulation tools (merging, splitting, OCR, conversions, signing). Operates as an isolated container supervised by systemd and reverse-proxied.
* **Database**: None (stateless file processor).


### Wallabag

* **Category**: Utilities
* **Version**: `2.6.17` | **Build**: `3`
* **Upstream**: [https://wallabag.org](https://wallabag.org)
* **Architecture**: Self-hosted read-it-later article archiver and Pocket alternative providing distraction-free reading, offline e-reader export (EPUB, PDF, MOBI), and browser extensions.
* **Database**: MariaDB / MySQL.


### YOURLS

* **Category**: Utilities
* **Version**: `1.10.6` | **Build**: `3`
* **Upstream**: [https://yourls.org](https://yourls.org)
* **Architecture**: Robust self-hosted URL shortening service providing detailed click metrics, referrer analytics, developer REST API, and custom short links.
* **Database**: MariaDB / MySQL.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
