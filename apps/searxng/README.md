# SearXNG Metasearch Engine for Virtualmin

**SearXNG** is a free, privacy-respecting metasearch engine that aggregates results from over 70 search services (Google, Bing, DuckDuckGo, Wikipedia, Reddit, GitHub, Qwant, etc.) while blocking profiling, cookies, and search query tracking.

---

## Features

- **Privacy-First Search**: Zero user profiling, tracking cookies, or search IP logging.
- **70+ Search Engines**: Aggregates web, image, video, news, map, and file searches.
- **Inline Image Proxy**: Proxies images and content through your server to prevent browser fingerprinting.
- **OpenSearch Integration**: Add SearXNG as your default browser search engine directly from the address bar.

---

## Virtualmin Integration

- **Script Name**: `searxng.pl`
- **Category**: Utilities
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Deployment**: Managed `systemd` service (`searxng-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx.
- **Configuration**: `settings.yml` secured with cryptographic secret key and restricted file permissions (`0600`).

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **SearXNG** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to begin performing private web searches.
