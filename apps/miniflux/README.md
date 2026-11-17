# Miniflux Feed Reader for Virtualmin

**Miniflux** is a minimalist and opinionated feed reader written in Go. Engineered for speed, efficiency, and zero bloat, Miniflux is designed for reading without distractions.

---

## Features

- **Lightweight & High-Performance**: Written in Go with minimal resource usage and instantaneous article loading.
- **Distraction-Free Reading**: Strips advertisements, tracking pixels, and clutter from incoming RSS/Atom feeds.
- **Keyboard-Driven**: Comprehensive keyboard shortcuts for lightning-fast reading and navigation.
- **Fever & Google Reader API**: Compatible with popular desktop and mobile feed reading apps (Reeder, NetNewsWire, Unread).
- **Automated Scraping**: Built-in content scraper extracts full article text when feeds only provide partial summaries.

---

## Virtualmin Integration

- **Script Name**: `miniflux.pl`
- **Category**: News
- **Runtime**: Native Standalone Go Binary
- **Database**: PostgreSQL (automatically provisioned by Virtualmin)
- **Deployment**: Managed `systemd` service (`miniflux-<domain>.service`) reverse-proxied by Apache/Nginx.

---

## Installation & Configuration

1. In Virtualmin, ensure the **PostgreSQL database** feature is enabled for the virtual server.
2. Navigate to **Server Configuration** -> **Manage Web Apps**.
3. Select **Miniflux** from the catalog.
4. Virtualmin provisions the PostgreSQL database, registers the service unit, and configures the reverse proxy.
5. Log into `https://yourdomain.com/` using the generated credentials displayed at the completion of setup.
