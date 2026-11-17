# Cloud Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Private cloud storage, file synchronization, document collaboration, and user portals.

This classification includes **2 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Nextcloud** | `30.0.6` | `3` | PHP 8.1+ / MariaDB + `occ` CLI Automated Installer | [App Readme](../../apps/nextcloud/README.md) |
| **ownCloud** | `10.13.4` | `3` | PHP / MariaDB + `occ` CLI Automated Installer | [App Readme](../../apps/owncloud/README.md) |

---

## Technical Details

### Nextcloud

* **Category**: Cloud
* **Version**: `30.0.6` | **Build**: `3`
* **Upstream**: [https://nextcloud.com](https://nextcloud.com)
* **Architecture**: Standard PHP 8.1+ with MariaDB/MySQL.
* **Installation**: Automated via Nextcloud's `occ maintenance:install` CLI.
* **Data Directory**: `/home/<domain>/nextcloud-data` (secured outside `public_html`).
* **Cron Execution**: `*/5 * * * * php -f /path/to/cron.php` registered in domain crontab.


### ownCloud

* **Category**: Cloud
* **Version**: `10.13.4` | **Build**: `3`
* **Upstream**: [https://owncloud.com](https://owncloud.com)
* **Architecture**: PHP with MariaDB/MySQL.
* **Data Directory**: `/home/<domain>/owncloud-data` outside `public_html`.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
