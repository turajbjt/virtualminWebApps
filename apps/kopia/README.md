# Kopia

[Kopia](https://kopia.io) is a fast and secure open-source backup and restore tool that provides end-to-end encryption, deduplication, compression, and a responsive built-in Web UI.

## Technical Specifications
- **Category**: System-DNS
- **Runtime**: Native Go single binary daemon
- **Default Port**: `51515`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/kopia/config`, `~/kopia/cache`

## Virtualmin Integration
- Standalone zero-dependency binary running directly as domain user
- Auto-generated secure server credentials
- Systemd daemon management via `kopia-<domain>.service`
