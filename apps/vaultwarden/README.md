# Vaultwarden for Virtualmin

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is an alternative implementation of the Bitwarden client API written in Rust and compatible with upstream Bitwarden clients, ideal for self-hosted deployment where running the official resource-heavy service is not ideal.

## Features in this Virtualmin Module
* **Low Memory Footprint**: Runs in ~30-50MB RAM compared to the official server's 2GB+.
* **Automatic SSL Validation**: Automatically verifies that SSL/HTTPS is enabled on the domain (Bitwarden clients enforce Web Crypto APIs which require secure contexts).
* **Systemd Integration**: Provisions a monitored `vaultwarden-<domain>.service` systemd unit.
* **Apache & Nginx Reverse Proxy**: Automatically configures the webserver reverse proxy rules, including WebSockets (`/notifications/hub`) for instant multi-device vault synchronization.
* **Configurable Registration & Admin Token**: Controls user sign-ups and enables optional admin portal (`/admin`).

## Architecture & Data Storage
* **Data Directory**: `/home/<domain>/vaultwarden-data`
* **Environment File**: `/home/<domain>/vaultwarden.env`
* **Default Port**: Dynamically allocated (defaults to 8000+)
* **Runtime**: Auto-detects and supports **Podman**, **Docker**, or native binary execution.
