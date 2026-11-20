# Media Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Photo management galleries, media streaming engines, audiobook servers, eBook readers, and digital asset management.

This classification includes **7 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Audiobookshelf** | `2.19.5` | `1` | Audiobook & Podcast Streaming Server (Container Daemon) | [App Readme](../../apps/audiobookshelf/README.md) |
| **Calibre-Web** | `0.6.24` | `1` | eBook Library & In-Browser Reader (Container Daemon) | [App Readme](../../apps/calibre_web/README.md) |
| **Jellyfin** | `10.9.11` | `1` | Home Media Streaming Server (Container Daemon) | [App Readme](../../apps/jellyfin/README.md) |
| **Lychee** | `7.13.0` | `3` | Self-Hosted Photo Management & Gallery Platform | [App Readme](../../apps/lychee/README.md) |
| **Navidrome** | `0.64.2` | `3` | Subsonic Modern Music Streaming Server (Go Binary + Systemd) | [App Readme](../../apps/navidrome/README.md) |
| **PhotoPrism** | `240915` | `1` | AI-Powered Photo Management & Gallery (Container Daemon) | [App Readme](../../apps/photoprism/README.md) |
| **Piwigo** | `16.5.0` | `3` | PHP / MariaDB Photo Gallery & Digital Asset Management | [App Readme](../../apps/piwigo/README.md) |

---

## Technical Details

### Audiobookshelf

* **Category**: Media
* **Version**: `2.19.5` | **Build**: `1`
* **Upstream**: [https://www.audiobookshelf.org](https://www.audiobookshelf.org)
* **Architecture**: Self-hosted audiobook and podcast server with streaming, progress sync, multi-user accounts, and mobile companion app support. Runs as an isolated container daemon supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


### Calibre-Web

* **Category**: Media
* **Version**: `0.6.24` | **Build**: `1`
* **Upstream**: [https://github.com/janeczku/calibre-web](https://github.com/janeczku/calibre-web)
* **Architecture**: Clean web interface for browsing, reading eBooks in-browser (ePub, PDF, CBR), and syncing to e-readers using a Calibre database. Supervised by systemd and reverse-proxied.
* **Database**: Embedded SQLite (`metadata.db`).


### Jellyfin

* **Category**: Media
* **Version**: `10.9.11` | **Build**: `1`
* **Upstream**: [https://jellyfin.org](https://jellyfin.org)
* **Architecture**: Volunteer-built media streaming server putting you in complete control of movies, shows, music, and live TV. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: None.


### Lychee

* **Category**: Media
* **Version**: `7.13.0` | **Build**: `3`
* **Upstream**: [https://lycheeorg.github.io](https://lycheeorg.github.io)
* **Architecture**: Self-hosted photo management system and album gallery with full EXIF inspection, public/private sharing, and responsive layouts.
* **Database**: MariaDB / MySQL.


### Navidrome

* **Category**: Media
* **Version**: `0.64.2` | **Build**: `3`
* **Upstream**: [https://www.navidrome.org](https://www.navidrome.org)
* **Architecture**: Modern, lightweight music streaming server and Subsonic-compatible API backend written in Go. Operates as an isolated daemon managed by systemd and reverse-proxied by Apache or Nginx.
* **Database**: Embedded SQLite.


### PhotoPrism

* **Category**: Media
* **Version**: `240915` | **Build**: `1`
* **Upstream**: [https://www.photoprism.app](https://www.photoprism.app)
* **Architecture**: AI-powered personal photo library and visual asset manager with automatic categorization, facial recognition, and geolocation tagging. Supervised by systemd and reverse-proxied.
* **Database**: Embedded SQLite.


### Piwigo

* **Category**: Media
* **Version**: `16.5.0` | **Build**: `3`
* **Upstream**: [https://piwigo.org](https://piwigo.org)
* **Architecture**: Mature photo gallery and digital asset management software featuring batch processing, EXIF/IPTC metadata extraction, and multi-tier privacy control.
* **Database**: MariaDB / MySQL.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
