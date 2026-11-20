# Stump

[Stump](https://stumpapp.dev) is a free, open-source, and highly performant digital media server for comics, manga, webtoons, and digital books written in Rust. It offers OPDS feed support, deep library scanning, smart reading lists, and in-browser reading.

## Technical Specifications
- **Category**: Media
- **Runtime**: Podman / Docker Container or Standalone Rust Binary
- **Default Port**: `10801`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/stump/config`, `~/stump/data`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user account
- OPDS e-reader feed support
- Systemd daemon management via `stump-<domain>.service`
