# Virtualmin Web Apps Suite - Master Roadmap

A modular collection of open-source web application installers for [Virtualmin](https://www.virtualmin.com/) ("Manage Web Apps" / Install Scripts).

---

## 1. Project Goals & Architecture

* **Modular Structure**: Each web app lives in its own self-contained directory (`apps/<app-name>/`), complete with its Virtualmin Perl script interface, service templates, and documentation.
* **Unified Management**: The central `./setup.sh` CLI allows one-command installation, updating, status inspection, and removal from any Virtualmin server.
* **Dual Execution Models**:
  1. **PHP/Database (LAMP/LEMP)**: Standard document-root installations (WordPress, Nextcloud, PrestaShop, etc.) with automatic MariaDB/PostgreSQL wiring.
  2. **Daemon / Microservices**: Native standalone binaries or containerized services (Vaultwarden, AdGuard Home, Uptime Kuma) running as isolated `systemd` units, automatically reverse-proxied with SSL and WebSocket forwarding by Apache or Nginx.

---

## 2. Complete Web Application Roadmap

### Phase 1: High-Priority Essentials & Infrastructure
- [x] **Vaultwarden** *(Priority #1)*: Ultra-lightweight Rust Bitwarden server + WebSockets + SSL reverse proxy.
- [x] **AdGuard Home** *(Priority #2)*: Self-contained Go DNS server & network-wide ad/tracker blocker with web UI.
- [x] **Pi-hole**: DNS sinkhole & network ad blocker.
- [x] **Nextcloud**: Enterprise-grade self-hosted cloud storage, calendar, contacts, and collaboration suite.
- [x] **ownCloud**: Private cloud storage and sync platform (Classic & Infinite Scale).

---

### Phase 2: E-Commerce & Shopping Carts (Full PlugnPay & FOSS Suite)
*All major open-source carts, including full coverage of the PlugnPay payment gateway ecosystem:*
- [x] **WooCommerce** (WordPress e-commerce engine)
- [x] **OpenCart** (Fast, feature-rich standalone PHP/MySQL e-commerce platform)
- [x] **PrestaShop** (Global open-source e-commerce platform)
- [x] **Thirty Bees** (High-performance, community-focused fork of PrestaShop 1.6)
- [x] **AbanteCart** (Modular PHP open-source shopping cart)
- [ ] **X-Cart** (PHP-based customizable shopping cart platform)
- [x] **FOSSBilling / BoxBilling** (Client management, automated billing, and digital shopping cart)
- [ ] **EasyCart Catalog** (Lightweight catalog and cart system)
- [x] **Zen Cart** (Established open-source shopping cart system)
- [ ] **osCommerce** (Pioneer open-source e-commerce solution)
- [x] **CubeCart** (Powerful PHP e-commerce software)
- [x] **LiteCart** (Modern, lightweight, and fast shopping cart)
- [ ] **Shopware Community Edition** (Enterprise-grade modern headless PHP/Symfony e-commerce)

---

### Phase 3: Virtualmin Pro Equivalents (PHP & MariaDB/PostgreSQL)
*Free, open-source replacements for scripts typically restricted to Virtualmin Pro:*
- [x] **Matomo** (Formerly Piwik - leading privacy-first Google Analytics alternative)
- [x] **MediaWiki** (The knowledge-base and wiki engine behind Wikipedia)
- [x] **BookStack** (Modern, opinionated documentation and wiki system)
- [ ] **Drupal** (Enterprise content management framework)
- [ ] **Joomla!** (Flexible, popular CMS)
- [x] **Flarum** (Next-generation, sleek discussion forum)
- [ ] **phpBB** (Classic, robust forum platform)
- [x] **Dolibarr** (ERP & CRM for small and medium businesses)
- [ ] **SuiteCRM** (Enterprise-level customer relationship management)
- [ ] **Invoice Ninja** (Invoicing, payments, and expense tracking)
- [ ] **Moodle** (Leading open-source Learning Management System)

---

### Phase 4: Modern Daemons, Developer Tools & Dashboards
*Services that run as dedicated system daemons behind Virtualmin reverse proxies:*
- [x] **Uptime Kuma** (High-performance uptime and service monitoring dashboard)
- [x] **Forgejo / Gitea** (Lightweight, self-hosted Git collaboration platform)
- [x] **Filebrowser** (Zero-dependency web file manager)
- [ ] **Umami** (Fast, privacy-focused modern website analytics)
- [ ] **Ghost** (Node.js modern publishing and newsletter platform)
- [ ] **Passbolt** (Open-source team credential and password manager)
- [ ] **CyberChef** (Cyber security and data analysis web tool)
- [ ] **IT-Tools** (Handy collection of developer utilities)
- [ ] **Netdata** (Real-time distributed system performance monitor)
- [ ] **Trilium Notes** (Hierarchical personal knowledge base)

---

## 3. Directory Layout Standard

```text
virtualminWebApps/
├── setup.sh                         # CLI installer & updater for Virtualmin servers
├── README.md                        # Documentation & quick start guide
├── ROADMAP.md                       # Master roadmap & categorized apps
├── lib/                             # Shared Perl helper modules
│   ├── Common.pl                    # Logging, downloads, checksums, unpack
│   ├── SystemdHelper.pl             # Systemd unit management
│   ├── ProxyHelper.pl               # Apache & Nginx reverse proxy configuration
│   └── PortManager.pl               # Dynamic TCP port allocation
├── apps/                            # Source directory for all web applications
│   ├── vaultwarden/                 # Self-contained app folder
│   │   ├── vaultwarden.pl           # Virtualmin install script module
│   │   ├── vaultwarden.service      # Systemd service unit template
│   │   └── README.md
│   ├── adguard-home/
│   ├── nextcloud/
│   ├── opencart/
│   └── ...
└── scripts/                         # Flattened directory exposed to Virtualmin
    ├── lib -> ../lib
    ├── vaultwarden.pl -> ../apps/vaultwarden/vaultwarden.pl
    └── ...
```
