# Analytics Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Privacy-focused web traffic, user journey, and telemetry analytics platforms.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Matomo** | `5.1.2` | `3` | PHP / MariaDB + Automated Archiving Cron (Pro Equivalent) | [App Readme](../../apps/matomo/README.md) |
| **Umami** | `latest` | `3` | Modern Privacy Analytics + Systemd + Reverse Proxy | [App Readme](../../apps/umami/README.md) |

---

## Technical Details

### Matomo

* **Category**: Analytics
* **Version**: `5.1.2` | **Build**: `3`
* **Upstream**: [https://matomo.org](https://matomo.org)
* **Architecture**: PHP with MariaDB.
* **Configuration**: Automated `config/config.ini.php` database connection and security salt generation.
* **Archiving Cron**: `5 * * * * php console core:archive` registered in crontab for high-performance reporting.


### Umami

* **Category**: Analytics
* **Version**: `latest` | **Build**: `3`
* **Upstream**: [https://umami.is](https://umami.is)
* **Architecture**: Lightweight Node.js privacy analytics daemon managed by systemd (`umami-<domain>.service`), reverse-proxied to `127.0.0.1:3000` with MariaDB backend.
* **Default Credentials**: `admin` / `umami`.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
