# FreshRSS Virtualmin Installer

**FreshRSS** is a self-hosted RSS and Atom feed aggregator. It is fast, lightweight, responsive, and supports multi-user accounts, full-text search, Google Reader API, and Fever API for third-party mobile readers.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Database**: MariaDB / MySQL or SQLite
- **Web Server**: Apache or Nginx (Web root points to `/p/` or uses shipped `.htaccess`)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> FreshRSS** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/freshrss` or document root.
