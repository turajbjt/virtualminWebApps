# Directus

[Directus](https://directus.io) is an instant open-source backend and data studio. It wraps any SQL database with real-time REST and GraphQL APIs, dynamic role-based access control, webhooks, and an intuitive admin app for non-technical users.

## Technical Specifications
- **Category**: CMS
- **Runtime**: Podman / Docker Container
- **Default Port**: `8055`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/directus/data`, `~/directus/uploads`, `~/directus/extensions`

## Virtualmin Integration
- Isolated rootless container execution under domain owner user
- Auto-generated admin credentials and API secret
- Systemd daemon management via `directus-<domain>.service`
