# Gotify Push Notification Server for Virtualmin

**Gotify** is a simple and private server for sending and receiving push notifications. Self-hosted and written in Go, Gotify provides an open alternative to Google Firebase Cloud Messaging (FCM) or Apple Push Notifications (APN) for server alerts, script notifications, and automated workflows.

---

## Features

- **Real-Time Push Notifications**: Delivers push alerts instantly via continuous WebSockets.
- **REST API & CLI**: Send notifications using simple HTTP `POST` requests or command-line scripts.
- **Android App Support**: Official Google Play and F-Droid Android clients with customizable priority levels.
- **Markdown & Images**: Notifications support rich text formatting and inline screenshots.
- **Zero Third-Party Relays**: 100% private transmission directly between your server and client devices.

---

## Virtualmin Integration

- **Script Name**: `gotify.pl`
- **Category**: System
- **Runtime**: Native Standalone Go Binary
- **Database**: Embedded SQLite
- **Deployment**: Managed `systemd` service (`gotify-<domain>.service`) listening on dynamic TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Gotify** from the catalog.
3. Configure the local reverse-proxy port (default auto-allocated).
4. Access the web dashboard at `https://yourdomain.com/`.
5. Sign in using the initial default credentials (`admin` / `admin`) and update your password immediately under **Users**.
