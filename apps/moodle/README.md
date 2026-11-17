# Moodle Virtualmin Installer

**Moodle** is the world's most popular open-source Learning Management System (LMS), empowering educators and trainers across academic and enterprise sectors.

## Architecture
- **Language**: PHP 8.1+ / 8.2+
- **Database**: MariaDB / MySQL / PostgreSQL
- **Data Directory**: Placed automatically outside public_html (`$HOME/moodledata`) for security.
- **Web Server**: Apache or Nginx

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Moodle** or using the CLI:
```bash
./setup.sh install
```
