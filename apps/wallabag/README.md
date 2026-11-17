# Wallabag Read-It-Later Application for Virtualmin

**Wallabag** is a self-hostable read-it-later application. Unlike proprietary bookmarking and pocket services, Wallabag saves the full text, images, and structure of web articles to your private server, stripping away intrusive tracking scripts and advertisements.

---

## Features

- **Distraction-Free Reading**: Strips ads, widgets, and popups, rendering pure articles in comfortable typography.
- **Cross-Platform Sync**: Native browser extensions (Chrome, Firefox) and mobile apps (iOS, Android) for instant 1-click archiving.
- **Export & E-Readers**: Export saved articles to EPUB, PDF, MOBI, JSON, or CSV for offline reading on Kindle or Kobo devices.
- **Tagging & Filtering**: Organize content with custom tags, reading statuses, and advanced full-text search.
- **Multi-User Support**: Allow family members, team researchers, or colleagues to maintain private reading queues.

---

## Virtualmin Integration

- **Script Name**: `wallabag.pl`
- **Category**: Utilities
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB (or SQLite)
- **Document Root**: Web root points to `web/` subdirectory or accessed via `/wallabag/web/`

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Wallabag** from the catalog.
3. Choose the target subdirectory (default `/wallabag`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Access Wallabag at `https://yourdomain.com/wallabag/web/`.
