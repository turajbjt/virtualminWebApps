# Jellyfin Media Server

[Jellyfin](https://jellyfin.org) is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached, no premium licenses or tracking.

## Technical Specifications
- **Category**: Media
- **Runtime**: Podman / Docker Container or Standalone .NET Daemon
- **Default Port**: `8096`
- **Reverse Proxy**: Apache / Nginx reverse proxy with full WebSocket and live streaming support
- **State Directory**: `~/jellyfin/config`, `~/jellyfin/cache`, `~/jellyfin/media`

## Virtualmin Integration
- Isolated rootless container execution per virtual server user
- Dedicated systemd unit template `jellyfin-<domain>.service`
- Automated Apache `mod_proxy_wstunnel` and Nginx websocket upgrade headers
