# Woodpecker CI for Virtualmin

**Woodpecker CI** is a community-driven, lightweight continuous integration engine. It uses a container-based pipeline architecture (configured via `.woodpecker.yml`) and pairs natively with Forgejo, Gitea, GitHub, and GitLab.

---

## Features

- **Pipeline as Code**: Declarative `.woodpecker.yml` pipeline definitions committed directly to your Git repository.
- **Matrix Builds & Steps**: Execute tests across multiple runtime matrices and deploy pipelines concurrently.
- **Native Forgejo Integration**: First-class webhook and OAuth integration with the suite's built-in [Forgejo](file:///home/turajb/cursorProjects/virtualminWebApps/apps/forgejo/README.md) installer.
- **Single-Binary Footprint**: Ultra-low resource usage written in Go with an embedded SQLite or MariaDB database.

---

## Virtualmin Integration

- **Script Name**: `woodpecker.pl`
- **Category**: Development
- **Runtime**: Native Standalone Go Binary
- **Database**: Embedded SQLite
- **Deployment**: Managed `systemd` service (`woodpecker-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Woodpecker CI** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to connect your Forgejo, Gitea, or GitHub OAuth credentials and register build runners.
