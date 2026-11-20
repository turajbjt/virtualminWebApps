# Planka

[Planka](https://planka.app) is an elegant, open-source, real-time collaborative kanban board for teams and solo developers (alternative to Trello). It features lists, cards, labels, due dates, checklists, attachments, and real-time updates.

## Technical Specifications
- **Category**: Project
- **Runtime**: Podman / Docker Container
- **Default Port**: `1337`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directories**: `~/planka`, `~/planka/avatars`, `~/planka/backgrounds`, `~/planka/attachments`

## Virtualmin Integration
- Isolated rootless container execution under domain owner user
- Auto-generated secret key and SQLite persistent storage
- Systemd daemon management via `planka-<domain>.service`
