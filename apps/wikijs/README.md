# Wiki.js Documentation Engine for Virtualmin

**Wiki.js** is a powerful and modern open-source wiki application built on Node.js. It features a modern interface, multiple editor modes (Markdown, Visual WYSIWYG, AsciiDoc, HTML), full-text search, and automated two-way Git repository synchronization.

---

## Features

- **Multiple Editors**: Author documentation using a rich visual WYSIWYG editor, standard Markdown, or Code blocks.
- **Git Synchronization**: Automatically push and pull articles to external Git repositories (GitHub, GitLab, Forgejo).
- **Asset Management**: Integrated media manager for screenshots, diagrams, and downloadable assets.
- **Extensible Authentication**: Built-in 2FA and integrations with Google, GitHub, Discord, LDAP, and SAML.

---

## Virtualmin Integration

- **Script Name**: `wikijs.pl`
- **Category**: Wiki
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Database**: Embedded SQLite
- **Deployment**: Managed `systemd` service (`wikijs-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Wiki.js** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to create your initial administrator profile.
