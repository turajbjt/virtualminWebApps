# Firefly III Virtualmin Installer

**Firefly III** is a free and open-source personal finances manager. It can help you keep track of your expenses and income, so you can spend less and save more.

## Architecture
- **Language**: PHP 8.2+
- **Database**: MariaDB / MySQL
- **Framework**: Laravel
- **Web Server**: Apache or Nginx (document root or `/public/`)

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Firefly III** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/finance` or document root.
