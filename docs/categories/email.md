# Email Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Browser-based webmail interfaces and IMAP/SMTP communication suites.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Roundcube** | `1.6.9` | `2` | Modern Webmail Platform + IMAP/SMTP Integration | [App Readme](../../apps/roundcube/README.md) |
| **SnappyMail** | `3.0.1` | `2` | Fast, Modern Webmail Client (Zero Database / IMAP / SMTP) | [App Readme](../../apps/snappymail/README.md) |

---

## Technical Details

### Roundcube

* **Category**: Email
* **Version**: `1.6.9` | **Build**: `2`
* **Upstream**: [https://roundcube.net](https://roundcube.net)
* **Architecture**: Modern, browser-based multilingual IMAP webmail platform with automated MySQL schema import, random DES key generation, and local Dovecot/Postfix integration.
* **Database**: MariaDB / MySQL.


### SnappyMail

* **Category**: Email
* **Version**: `3.0.1` | **Build**: `2`
* **Upstream**: [https://snappymail.eu](https://snappymail.eu)
* **Architecture**: Ultra-fast, lightweight webmail client (modern RainLoop fork) engineered with minimal footprint, no required SQL database, OpenPGP message encryption, and full mobile optimization.
* **Database**: Filesystem / Flat-file (Zero database overhead; connects directly to Dovecot/Postfix or external IMAP/SMTP).


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
