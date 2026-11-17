# Lychee Virtualmin Installer

**Lychee** is a free photo-management tool, which runs on your server or web-space. Installing is a matter of seconds. Upload, manage, and share photos like from a native application. Lychee comes with everything you need and all your photos are stored securely.

## Architecture
- **Language**: PHP 8.1+ / 8.2+
- **Database**: MariaDB / MySQL
- **Framework**: Laravel
- **Web Server**: Apache or Nginx (public document root or `.htaccess`)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Lychee** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/photos` or document root.
