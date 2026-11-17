# Grav CMS Virtualmin Installer

**Grav** is a modern open-source flat-file Content Management System (CMS) designed for speed, simplicity, and flexibility. It requires no database and features Markdown page authoring, Twig templating, and an intuitive Admin Panel.

## Architecture
- **Language**: PHP 8.0+ / 8.1+ / 8.2+
- **Database**: Flat-file Markdown/YAML (zero SQL required)
- **Web Server**: Apache or Nginx (with `.htaccess` rewriting)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Grav** or using the CLI:
```bash
./setup.sh install
```
Admin setup URL: `https://<domain>/admin`.
