# Syncthing File Synchronization for Virtualmin

**Syncthing** is a continuous, decentralized file synchronization program. It synchronizes files between two or more computers in real time, safely protected from prying eyes using TLS mutual authentication and cryptographic forward secrecy.

---

## Features

- **Decentralized & Peer-to-Peer**: No central server storing your files; communication happens directly between your authorized devices.
- **End-to-End Encryption**: All communication is secured using TLS; block-level deduplication and transfers are encrypted.
- **Web-Based Management**: Responsive web GUI to monitor sync status, set up folders, connect peer devices, and configure versioning.
- **Comprehensive Platform Support**: Official clients available for Linux, macOS, Windows, Android, and BSD.
- **Automatic NAT Traversal**: Connects across firewalls and NATs using relaying and discovery servers without manual router configuration.

---

## Virtualmin Integration

- **Script Name**: `syncthing.pl`
- **Category**: Sync
- **Runtime**: Native Standalone Go Binary
- **Database**: Embedded SQLite / LevelDB
- **Deployment**: Managed `systemd` service (`syncthing-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Syncthing** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access the web dashboard at `https://yourdomain.com/` to connect devices and share synchronized directories.
