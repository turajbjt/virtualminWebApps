# ArchiveBox

[ArchiveBox](https://archivebox.io) is a powerful, self-hosted internet archiving solution. It takes URLs, browser history, bookmarks, or RSS feeds and creates comprehensive local snapshots (HTML, PDF, screenshot, WARC, git repo, media downloads) for permanent digital preservation.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: Podman / Docker Container
- **Default Port**: `8020` (mapped to internal `8000`)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/archivebox/data`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user account
- Auto-configured persistent data archive store
- Systemd daemon management via `archivebox-<domain>.service`
