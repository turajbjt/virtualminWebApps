# GoToSocial ActivityPub Social Server for Virtualmin

**GoToSocial** is an ActivityPub social network server written in Go. It provides a lightweight, customizable, privacy-focused entry point into the Fediverse (federating with Mastodon, Pixelfed, Firefish, and Lemmy) while consuming a fraction of the system resources of Ruby or Python-based alternatives.

---

## Features

- **Fediverse & Mastodon Compatible**: Federates with any ActivityPub server and supports the Mastodon client API (compatible with apps like Tusky, Mona, and IceCubes).
- **Extremely Low Footprint**: Operates cleanly on small instances using minimal CPU and under 50MB RAM.
- **Embedded SQLite Database**: No complex database clusters or caching services required.
- **Granular Privacy Controls**: Custom posting visibilities, approval workflows, and locked account support.
- **Rich Media Storage**: Local or object storage support for images, video attachments, and custom emojis.

---

## Virtualmin Integration

- **Script Name**: `gotosocial.pl`
- **Category**: Community
- **Runtime**: Native Standalone Go Binary
- **Database**: Embedded SQLite (`sqlite.db`)
- **Deployment**: Managed `systemd` service (`gotosocial-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding and HTTPS/TLS enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **GoToSocial** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to connect with standard Mastodon-compatible mobile or web clients.
