# Conduit Matrix Homeserver

[Conduit](https://conduit.rs) is a lightweight, extremely fast Matrix homeserver written in Rust. It is built to run effortlessly on low-power devices, virtual servers, or embedded systems with tiny RAM usage.

## Technical Specifications
- **Category**: Chat
- **Runtime**: Native Rust single binary daemon
- **Default Port**: `6167`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/conduit/data`

## Virtualmin Integration
- Standalone zero-dependency binary running directly as domain user
- Auto-configured `conduit.toml` with PCI DSS 0600 permissions
- Systemd daemon management via `conduit-<domain>.service`
