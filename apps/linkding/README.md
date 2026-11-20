# Linkding

[Linkding](https://github.com/sissbruecker/linkding) is a minimalist, fast, and easy-to-use self-hosted bookmark manager. It offers clean tagging, automatic page title extraction, archive snapshotting via Wayback Machine, and browser extensions for Firefox and Chrome.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: Podman / Docker Container
- **Default Port**: `9090`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/linkding/data`

## Virtualmin Integration
- Isolated rootless container execution under domain owner account
- Auto-generated admin credentials
- Systemd daemon management via `linkding-<domain>.service`
