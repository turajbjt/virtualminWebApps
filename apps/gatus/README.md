# Gatus

[Gatus](https://gatus.io) is an automated service health dashboard that monitors your HTTP, ICMP, TCP, and DNS endpoints. It provides clean status badges, uptime calculations, and multi-channel alerting with zero bloat.

## Technical Specifications
- **Category**: System-DNS
- **Runtime**: Native Go single binary daemon
- **Default Port**: `8085`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/gatus/config`

## Virtualmin Integration
- Lightweight standalone Go binary running directly under domain user account
- Auto-configured health monitoring of the hosting virtual server
- Systemd daemon management via `gatus-<domain>.service`
