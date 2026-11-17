# Forgejo for Virtualmin

[Forgejo](https://forgejo.org/) is a community-driven, 100% free software lightweight Git forge (forked from Gitea).

## Features in this Virtualmin Module
* **Single Native Binary**: Runs directly on the host using official static binaries (amd64 and arm64).
* **Systemd Service**: Runs under the domain owner account with automatic restarts.
* **Apache & Nginx Reverse Proxy**: Pre-configured reverse proxy with WebSocket support for live push/pull and dashboard events.
* **MariaDB Database Wiring**: Pre-configures database credentials into `custom/conf/app.ini`.
