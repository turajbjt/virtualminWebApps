# RustDesk Server for Virtualmin

**RustDesk Server** is a full-featured, open-source remote desktop server written in Rust. It functions as an on-premises rendezvous and relay server for RustDesk clients (TeamViewer, AnyDesk, and LogMeIn alternative).

---

## Features

- **Full Privacy & Self-Hosted**: End-to-end encryption between remote client and host with zero third-party relays.
- **Rendezvous & Relay Services**: Manages connection establishment, direct P2P hole punching, and fallback relaying.
- **Multi-Platform Support**: Connects Linux, Windows, macOS, Android, and iOS devices.
- **Low CPU & Memory Usage**: High-concurrency async Rust runtime operating smoothly with minimal memory.

---

## Virtualmin Integration

- **Script Name**: `rustdesk.pl`
- **Category**: System
- **Runtime**: Native Standalone Rust Binary
- **Deployment**: Managed `systemd` service (`rustdesk-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **RustDesk Server** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Configure your RustDesk client apps by entering `yourdomain.com` under **ID/Relay Server** settings.
