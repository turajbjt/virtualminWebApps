# Changedetection.io

[Changedetection.io](https://changedetection.io) is an open-source web page monitoring tool designed to track website content changes, restock alerts, price changes, PDF changes, and API updates with instant notifications via Discord, Telegram, Email, Slack, and webhooks.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: Podman / Docker Container
- **Default Port**: `5000`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/changedetection/datastore`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user
- Persistent local datastore directory
- Dedicated systemd unit template `changedetection-<domain>.service`
