# PrivateBin Virtualmin Installer

**PrivateBin** is a minimalist, open-source online pastebin where the server has zero knowledge of pasted data. Data is encrypted and decrypted in the browser using 256-bit AES in GCM mode.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Database**: Filesystem storage (`data/`) or optional MariaDB backend
- **Encryption**: Client-side AES-256-GCM via Web Crypto API
- **Web Server**: Apache or Nginx (HTTPS strongly recommended)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> PrivateBin** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/paste` or document root.
