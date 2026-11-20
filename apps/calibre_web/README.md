# Calibre-Web for Virtualmin

**Calibre-Web** is a clean, modern web interface for browsing, reading, and downloading eBooks using an existing or new Calibre database.

---

## Features

- **In-Browser Reading**: Read eBooks directly in the browser across desktop and mobile devices (ePub, PDF, CBR, CBZ, TXT).
- **OPDS Catalog**: Serve eBooks to mobile e-reader apps (Marvin, KyBook, Moon+ Reader) via the Open Publication Distribution System (OPDS).
- **Direct Send-to-Kindle**: Deliver eBooks directly to Kindle e-readers via SMTP or Amazon email integration.
- **User Management & Metadata Editing**: Granular read/download permissions and inline editing of book metadata.

---

## Virtualmin Integration

- **Script Name**: `calibre_web.pl`
- **Category**: Media
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Database**: Embedded SQLite (`metadata.db`)
- **Deployment**: Managed `systemd` service (`calibre-web-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Calibre-Web** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` and log in with default credentials (`admin` / `admin123`). Update your password immediately under Admin settings.
