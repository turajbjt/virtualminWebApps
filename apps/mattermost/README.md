# Mattermost - Virtualmin Web App

[Mattermost](https://mattermost.com/) is an open-source, self-hosted enterprise collaboration, messaging, and chat platform alternative to Slack and Microsoft Teams.

## Features

* **Channels & Direct Messages**: Organized public, private, and 1-on-1 team discussions with Markdown, threads, and emojis.
* **Audio & Screen Sharing**: Built-in voice calls and collaborative meetings.
* **Integrations & Webhooks**: Rich API, incoming/outgoing webhooks, slash commands, and bot support.
* **Full Data Ownership**: Self-hosted backend running on MariaDB/MySQL with enterprise-level security.
* **Cross-Platform Clients**: Native desktop and mobile apps for Windows, macOS, Linux, iOS, and Android.

## Virtualmin Integration Details

* **Runtime Model**: Standalone Go compiled daemon managed via `systemd` (`mattermost-<domain>.service`).
* **Port Management**: Dynamic internal port allocation (default: `8065`).
* **Reverse Proxy**: Apache / Nginx reverse proxy with full WebSocket forwarding (`/api/v4/websocket`).
* **Database**: Automated MariaDB/MySQL database provisioning and connection configuration.
* **Initial Setup**: First visitor to the configured domain registers as the primary system administrator.
