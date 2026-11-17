# Passbolt Virtualmin Installer

**Passbolt** is a security-first, open-source password manager designed specifically for teams. Built on OpenPGP, it provides enterprise-grade collaboration and credential sharing.

## Architecture
- **Language**: PHP 8.1+ / 8.2+
- **Database**: MariaDB / MySQL
- **Crypto**: PHP gnupg extension & OpenPGP
- **Web Server**: Apache or Nginx with HTTPS (SSL strongly recommended)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Passbolt** or using the CLI:
```bash
./setup.sh install
```
