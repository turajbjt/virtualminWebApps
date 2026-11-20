# Borgmatic

[Borgmatic](https://torsion.org/borgmatic) is a simple, configuration-driven backup software for servers. It wraps BorgBackup with high-level YAML configuration, database dumps, monitoring hooks, end-to-end encryption, deduplication, and automated prune retention schedules.

## Technical Specifications
- **Category**: System
- **Runtime**: Podman / Docker Container or Python Daemon
- **Default Port**: `8092` (mapped to internal `8080`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/borgmatic/config`, `~/borgmatic/data`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user account
- Auto-configured backup retention policies (7 daily, 4 weekly, 6 monthly)
- Systemd daemon management via `borgmatic-<domain>.service`
