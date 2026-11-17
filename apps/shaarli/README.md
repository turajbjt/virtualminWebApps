# Shaarli Virtualmin Installer

**Shaarli** is a minimalist, super-fast, database-free bookmarking and link-sharing service. It lets you collect, tag, search, and share your links, notes, and code snippets with complete privacy.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Database**: Flat-file JSON/datastore (zero SQL configuration needed)
- **Web Server**: Apache or Nginx

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Shaarli** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/links` or document root.
