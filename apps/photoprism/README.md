# PhotoPrism

[PhotoPrism](https://www.photoprism.app) is an AI-powered photo app for decentralized web environments. It makes use of the latest technologies to automatically tag, organize, and find pictures in your private photo library without compromising privacy.

## Technical Specifications
- **Category**: Media
- **Runtime**: Podman / Docker Container
- **Default Port**: `2342`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/photoprism/storage`, `~/photoprism/originals`, `~/photoprism/import`

## Virtualmin Integration
- Runs securely in a rootless container under the domain owner user
- Auto-generated admin password
- Systemd integration with restart resiliency via `photoprism-<domain>.service`
