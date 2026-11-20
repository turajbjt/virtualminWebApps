# Mumble (Murmur Server)

[Mumble](https://www.mumble.info) is an open-source, low-latency, high-quality voice chat software primarily intended for use while gaming, conferences, and private team voice communications.

## Technical Specifications
- **Category**: Chat
- **Runtime**: Native Murmur Binary or Container Daemon
- **Default Port**: `64738` (TCP & UDP)
- **State Directory**: `~/mumble/data`

## Virtualmin Integration
- Isolated rootless container or standalone service under virtual server user account
- Auto-generated SuperUser administrator password
- Systemd daemon management via `mumble-<domain>.service`
