# Paperless-ngx - Virtualmin Web App

[Paperless-ngx](https://docs.paperless-ngx.com/) is a community-driven document management system that transforms your physical documents into searchable online archives.

## Features

* **Automated OCR**: Scans and performs Optical Character Recognition using Tesseract across multi-page PDFs, TIFFs, and images.
* **Document Ingestion**: Watches a consume folder (`~/paperless/consume`), supports IMAP email ingestion, and web uploads.
* **Full-Text Search**: Fast, indexed full-text search with automatic tagging, document types, and correspondents.
* **Multi-Language OCR**: Pre-configured support for English, German, French, Spanish, and multiple international languages.
* **Privacy & Isolation**: Runs safely in a hardened container with all files mounted directly inside the user's home directory.

## Virtualmin Integration Details

* **Runtime Model**: Isolated Podman / Docker container managed via `systemd` (`paperless-<domain>.service`).
* **Port Management**: Dynamic internal port allocation (default: `8000`).
* **Reverse Proxy**: Apache / Nginx reverse proxy with WebSocket support for real-time document upload feedback.
* **Data Storage**: Document data, media, export, and intake directories isolated in `~/paperless/`.
