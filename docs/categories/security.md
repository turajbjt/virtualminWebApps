# Security Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Team password managers, encrypted pastebins, and zero-knowledge cryptographic vaults.

This classification includes **3 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Passbolt** | `5.18.0` | `2` | Open-Source Team Password & Secret Manager | [App Readme](../../apps/passbolt/README.md) |
| **PrivateBin** | `2.1.1` | `2` | Zero-Knowledge Encrypted Pastebin (Client-Side AES) | [App Readme](../../apps/privatebin/README.md) |
| **Vaultwarden** | `1.32.7` | `2` | Rust Daemon + Systemd + SSL Reverse Proxy + WebSockets | [App Readme](../../apps/vaultwarden/README.md) |

---

## Technical Details

### Passbolt

* **Category**: Security
* **Version**: `5.18.0` | **Build**: `2`
* **Upstream**: [https://www.passbolt.com](https://www.passbolt.com)
* **Architecture**: Open-source team password and secret manager built on OpenPGP and CakePHP.
* **Database**: MariaDB / MySQL.


### PrivateBin

* **Category**: Security
* **Version**: `2.1.1` | **Build**: `2`
* **Upstream**: [https://privatebin.info](https://privatebin.info)
* **Architecture**: Zero-knowledge encrypted pastebin. Data is encrypted and decrypted exclusively in the client browser using 256-bit AES-GCM.
* **Database**: Filesystem storage (`data/`).


### Vaultwarden

* **Category**: Security
* **Version**: `1.32.7` | **Build**: `2`
* **Upstream**: [https://github.com/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)
* **Architecture**: Standalone daemon or rootless container managed by systemd, listening on `127.0.0.1:8000` and reverse-proxied by Apache/Nginx.
* **Requirements**: SSL/HTTPS enabled on the domain (Bitwarden clients enforce Web Crypto APIs).
* **Key Configuration**:
  * Environment: `/home/<domain>/vaultwarden.env`
  * Data Directory: `/home/<domain>/vaultwarden-data`
  * WebSockets: `/notifications/hub` forwarded to ws backend for instant multi-device vault synchronization.
  * Admin Portal: Accessible at `/admin` if an `ADMIN_TOKEN` is configured during setup.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
