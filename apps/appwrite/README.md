# Appwrite

[Appwrite](https://appwrite.io) is an end-to-end backend platform for Web, Mobile, and Flutter developers. It abstracts complex backend tasks, providing user authentication, databases, file storage, serverless cloud functions, and real-time WebSockets through unified REST and GraphQL APIs.

## Technical Specifications
- **Category**: Development
- **Runtime**: Podman / Docker Container
- **Default Port**: `8095` (mapped to internal `80`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/appwrite/data`

## Virtualmin Integration
- Isolated rootless container execution under domain user account
- Auto-generated system master keys
- Systemd daemon management via `appwrite-<domain>.service`
