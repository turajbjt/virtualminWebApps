# PocketBase Realtime Backend & Database for Virtualmin

**PocketBase** is an open-source, single-binary Go backend consisting of an embedded database (SQLite) with real-time subscriptions, built-in user authentication and file management, a convenient admin dashboard UI, and a simple REST-ish API.

---

## Features

- **Embedded SQLite Database**: Zero-configuration, ACID-compliant database with full-text search and JSON support.
- **Real-Time Subscriptions**: Instant data sync across connected clients via Server-Sent Events (SSE) and WebSockets.
- **Authentication & OAuth2**: Built-in email/password, magic link, and OAuth2 identity providers (Google, GitHub, GitLab, Microsoft).
- **Admin Dashboard**: Web management console accessible at `/_/` for managing collections, records, logs, and settings.
- **High Performance & Low Resource Footprint**: Single standalone binary requiring minimal memory (<30MB RAM).

---

## Virtualmin Integration

- **Script Name**: `pocketbase.pl`
- **Category**: Development
- **Runtime**: Native Standalone Go Binary
- **Database**: Embedded SQLite (`pb_data/data.db`)
- **Deployment**: Managed `systemd` service (`pocketbase-<domain>.service`) listening on a dynamic TCP port, reverse-proxied by Apache/Nginx with WebSocket and SSE support.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **PocketBase** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access the web dashboard at `https://yourdomain.com/_/` to create your initial superuser credentials.
