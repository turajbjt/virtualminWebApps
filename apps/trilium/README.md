# Trilium Notes Virtualmin Installer

**Trilium Notes** is a hierarchical note taking application with focus on building large personal knowledge bases. It features fast full-text search, tree-structured notes, rich text WYSIWYG editing, mind maps, note encryption, versioning, and script execution.

## Architecture
- **Runtime**: Bundled standalone Node.js server
- **Database**: SQLite (managed within data directory)
- **Process Management**: Systemd unit (`trilium-<dom>.service`) running under domain user permissions
- **Web Server**: Apache or Nginx reverse proxy with WebSocket support

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Trilium Notes** or using the CLI:
```bash
./setup.sh install
```
Data directory: `/home/<dom>/trilium-data`.
