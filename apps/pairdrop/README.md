# PairDrop

[PairDrop](https://pairdrop.net) is an open-source, web-based local file sharing application (alternative to Apple AirDrop and Snapdrop). It enables secure, encrypted peer-to-peer file sharing directly between devices on the same local network or via temporary pairing codes across the internet.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: Podman / Docker Container
- **Default Port**: `3020` (mapped to internal `3000`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets

## Virtualmin Integration
- Isolated rootless container execution under domain user account
- Dedicated systemd unit template `pairdrop-<domain>.service`
- WebRTC and WebSocket real-time connection support
