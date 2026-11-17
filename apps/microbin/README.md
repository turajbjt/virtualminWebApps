# Microbin Pastebin & File Sharing for Virtualmin

**Microbin** is an ultra-fast, lightweight, and self-contained pastebin and file sharing service written in Rust. Compiling down to a single zero-dependency binary, Microbin offers burn-after-reading pastes, client-side encryption, QR code generation, and syntax highlighting.

---

## Features

- **Blazing Fast**: Native Rust implementation with near-instantaneous page render times and minimal RAM usage.
- **Client-Side & Server Encryption**: Optional password protection and burn-after-reading expiry.
- **File Uploads & Raw Text**: Upload images, configuration files, logs, or plain code snippets.
- **QR Code Sharing**: Instantly display QR codes for mobile scanning.
- **Zero Database Requirement**: Embedded local file storage; requires no external database.

---

## Virtualmin Integration

- **Script Name**: `microbin.pl`
- **Category**: Utilities
- **Runtime**: Native Standalone Musl Rust Binary
- **Database**: None (self-contained local storage)
- **Deployment**: Managed `systemd` service (`microbin-<domain>.service`) reverse-proxied by Apache/Nginx.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Microbin** from the catalog.
3. Configure the local reverse-proxy port (default auto-allocated).
4. Access Microbin at `https://yourdomain.com/`.
