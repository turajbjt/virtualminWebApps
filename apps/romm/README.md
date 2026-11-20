# RomM (ROM Manager)

[RomM](https://github.com/rommapp/romm) is a modern web-based retro video game ROM library manager and browser. It allows retro gaming enthusiasts to organize, scan, manage game saves and states, download metadata and cover art via IGDB, and play retro games directly in the browser via EmulatorJS.

## Technical Specifications
- **Category**: Media
- **Runtime**: Podman / Docker Container
- **Default Port**: `8070` (mapped to internal `8080`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/romm/library/roms`, `~/romm/resources`, `~/romm/config`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user account
- Auto-generated authentication secrets
- Systemd daemon management via `romm-<domain>.service`
