# Kanboard Virtualmin Installer

**Kanboard** is free and open-source Kanban board software. There is no simpler way to manage your projects: visualize your work, limit your work in progress, and track tasks visually.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Database**: SQLite (built-in zero configuration) or MariaDB/PostgreSQL
- **Web Server**: Apache or Nginx

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Kanboard** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/kanboard` or document root. Default credentials: `admin` / `admin`.
