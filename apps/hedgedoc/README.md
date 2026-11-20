# HedgeDoc

[HedgeDoc](https://hedgedoc.org) is an open-source, web-based, self-hosted, collaborative markdown editor (formerly CodiMD). It allows multiple people to edit notes, presentations, and technical documentation simultaneously with live rendered previews.

## Technical Specifications
- **Category**: Documents
- **Runtime**: Podman / Docker Container
- **Default Port**: `3010` (mapped to internal `3000`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/hedgedoc/uploads`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user
- Auto-generated cryptographically secure session secrets
- Systemd daemon management via `hedgedoc-<domain>.service`
