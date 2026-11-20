# Immich

[Immich](https://immich.app) is a high-performance self-hosted photo and video management solution. It provides automatic backup from mobile apps (iOS & Android), smart search via machine learning, facial recognition, partner sharing, and map views.

## Technical Specifications
- **Category**: Media
- **Runtime**: Podman / Docker Container
- **Default Port**: `2283`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/immich/library`, `~/immich/upload`

## Virtualmin Integration
- Isolated rootless container execution under domain user account
- Dedicated systemd unit template `immich-<domain>.service`
