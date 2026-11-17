# Baikal Virtualmin Installer

**Baikal** is a lightweight CalDAV and CardDAV server offering full contacts and calendar synchronization for macOS, iOS, Android, Thunderbird, and web clients.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Protocols**: CalDAV, CardDAV, WebDAV (powered by `sabre/dav`)
- **Database**: SQLite (built-in) or MariaDB/MySQL
- **Web Server**: Apache or Nginx

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Baikal** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/baikal` or document root.
