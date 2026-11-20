# Audiobookshelf Server for Virtualmin

**Audiobookshelf** is a self-hosted audiobook and podcast server. It provides continuous playback syncing across devices, multi-user permissions, chapter support, progress tracking, and companion native apps for iOS and Android.

---

## Features

- **Audiobook & Podcast Streaming**: Stream or download audiobooks and podcasts with chapter markers and variable speed playback.
- **Cross-Device Sync**: Synchronize playback positions across browsers, tablets, and native mobile apps.
- **Multi-User & Permission Controls**: Granular user accounts with custom library visibility and playback histories.
- **Automatic Metadata & Covers**: Fetch author info, book series, narrator details, and high-resolution cover art automatically.
- **CarPlay & Android Auto**: Official mobile clients support in-car dashboard playback.

---

## Virtualmin Integration

- **Script Name**: `audiobookshelf.pl`
- **Category**: Media
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Database**: Embedded SQLite
- **Deployment**: Managed `systemd` service (`audiobookshelf-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.
- **Storage**: Audiobooks stored in `~/audiobooks/`, podcasts in `~/podcasts/`, application state in `~/audiobookshelf/`.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Audiobookshelf** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to complete the initial setup and create your admin account.
