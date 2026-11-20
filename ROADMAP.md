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

### Phase 2: E-Commerce & Shopping Carts
*Comprehensive suite of open-source storefront engines, carts, and billing platforms:*
- [x] **WooCommerce** (WordPress e-commerce engine)
- [x] **OpenCart** (Fast, feature-rich standalone PHP/MySQL e-commerce platform)
- [x] **PrestaShop** (Global open-source e-commerce platform)
- [x] **Thirty Bees** (High-performance, community-focused fork of PrestaShop 1.6)
- [x] **AbanteCart** (Modular PHP open-source shopping cart)
- [x] **FOSSBilling / BoxBilling** (Client management, automated billing, and digital shopping cart)
- [x] **Zen Cart** (Established open-source shopping cart system)
- [x] **osCommerce** (Pioneer open-source e-commerce solution)
- [x] **CubeCart** (Powerful PHP e-commerce software)
- [x] **LiteCart** (Modern, lightweight, and fast shopping cart)

---

### Phase 3: Virtualmin Pro Equivalents (PHP & MariaDB/PostgreSQL)
*Free, open-source replacements for scripts typically restricted to Virtualmin Pro:*
- [x] **Matomo** (Formerly Piwik - leading privacy-first Google Analytics alternative)
- [x] **MediaWiki** (The knowledge-base and wiki engine behind Wikipedia)
- [x] **BookStack** (Modern, opinionated documentation and wiki system)
- [x] **Drupal** (Enterprise content management framework)
- [x] **Joomla!** (Flexible, popular CMS)
- [x] **Flarum** (Next-generation, sleek discussion forum)
- [x] **phpBB** (Classic, robust forum platform)
- [x] **Dolibarr** (ERP & CRM for small and medium businesses)
- [x] **SuiteCRM** (Enterprise-level customer relationship management)
- [x] **Invoice Ninja** (Invoicing, payments, and expense tracking)
- [x] **Moodle** (Leading open-source Learning Management System)

---

### Phase 4: Modern Daemons, Developer Tools & Dashboards
*Services that run as dedicated system daemons or web tools behind Virtualmin reverse proxies:*
- [x] **Uptime Kuma** (High-performance uptime and service monitoring dashboard)
- [x] **Forgejo / Gitea** (Lightweight, self-hosted Git collaboration platform)
- [x] **Filebrowser** (Zero-dependency web file manager)
- [x] **Ghost** (Node.js modern publishing and newsletter platform)
- [x] **Umami** (Fast, privacy-focused modern website analytics)
- [x] **Passbolt** (Open-source team credential and password manager)
- [x] **CyberChef** (Cyber security and data analysis web tool)
- [x] **IT-Tools** (Handy collection of developer utilities)
- [x] **Netdata** (Real-time distributed system performance monitor)
- [x] **Trilium Notes** (Hierarchical personal knowledge base)
- [x] **Roundcube** (Browser-based multilingual IMAP webmail client)
- [x] **phpMyAdmin** (Web-based MySQL and MariaDB database administration)
- [x] **PrivateBin** (Zero-knowledge 256-bit AES encrypted pastebin)
- [x] **Kanboard** (Minimalist visual Kanban board project management)
- [x] **FreshRSS** (Self-hosted RSS/Atom feed reader & aggregator)
- [x] **Shaarli** (Personal minimalist bookmarking & link sharing service)
- [x] **Lychee** (Self-hosted photo management and gallery platform)
- [x] **Baikal** (Lightweight CalDAV & CardDAV contacts and calendar sync server)
- [x] **Grav** (Modern fast flat-file CMS with admin panel)
- [x] **Firefly III** (Free and open-source personal finances and budget manager)

---

### Phase 5: Productivity, Collaboration, Media & Utility Tools
- [x] **SnappyMail** (Fast, modern, lightweight webmail client - RainLoop fork)
- [x] **Piwigo** (Open-source photo gallery & digital asset management)
- [x] **LimeSurvey** (Professional online survey & questionnaire platform)
- [x] **MyBB** (Extensible discussion board & community forum)
- [x] **MantisBT** (Web-based issue & bug tracking system)
- [x] **Wallabag** (Self-hosted read-it-later & article archiver)

---

### Phase 6: Knowledge, Database Administration, Business & Strategy Tools
- [x] **DokuWiki** (Standards-compliant flat-file wiki requiring no database)
- [x] **Adminer** (Lightweight single-file database management tool)
- [x] **YOURLS** (Self-hosted URL shortener with click analytics and API)
- [x] **EspoCRM** (Fast single-page application CRM platform for businesses)
- [x] **InvoicePlane** (Self-hosted invoicing, quotes, and client management)
- [x] **Leantime** (Strategic and agile project management with Kanban and milestones)

---

### Phase 7: Real-Time Services, Education, Messaging & Minimalist Tools
- [x] **Chamilo LMS** (Enterprise open-source e-learning and course management platform)
- [x] **LinkStack** (Privacy-first open-source Linktree alternative & bio link hub)
- [x] **Vikunja** (Cross-platform to-do and task management server with Kanban/Gantt)
- [x] **Gotify** (Real-time push notification and messaging server with WebSockets)
- [x] **Miniflux** (Minimalist, opinionated RSS/Atom feed reader on PostgreSQL)
- [x] **Microbin** (Ultra-fast, zero-dependency encrypted pastebin & file sharer in Rust)

---

### Phase 8: Document Management, Streaming, Team Collaboration & Personal Portals
- [x] **Paperless-ngx** (Document management system & OCR archive)
- [x] **Monica PRM** (Personal relationship management platform)
- [x] **Navidrome** (Subsonic-compatible modern music streaming server)
- [x] **Mattermost** (Open-source team communication, messaging, and chat)
- [x] **FlatPress** (Classic lightweight flat-file blogging engine requiring no database)

---

### Phase 9: Helpdesk, Realtime Databases, Peer-to-Peer Sync, Time Tracking & ActivityPub
- [x] **FreeScout** (PHP / MariaDB / Laravel helpdesk & shared mailbox)
- [x] **PocketBase** (Lightweight Go single-binary backend-as-a-service & realtime SQLite database)
- [x] **Syncthing** (Continuous decentralized file synchronization server with web GUI)
- [x] **Kimai** (Time tracking and customer invoicing platform in Symfony / PHP)
- [x] **GoToSocial** (ActivityPub social network server in Go federating with Mastodon)

---

### Phase 10: Audiobooks, Household ERP, PDF Processing & Classic Support
- [x] **Audiobookshelf** (Self-hosted audiobook & podcast server with mobile app syncing)
- [x] **Grocy** (Home pantry, grocery stock, recipes, chores, and battery tracking ERP in PHP/SQLite)
- [x] **Stirling-PDF** (On-premises web-based PDF tool suite: merge, split, OCR, convert, sign)
- [x] **osTicket** (Classic open-source customer support ticket system in PHP/MariaDB)

---

### Phase 11: Developer Pipelines, Automation, Redis/Postgres Management, Dashboards & Remote Desktop
- [x] **phpRedisAdmin** (Web GUI for inspecting and managing Redis key-value stores)
- [x] **Woodpecker CI** (Lightweight pipeline-as-code CI/CD server in Go)
- [x] **Calibre-Web** (eBook library manager and in-browser reader for ePub/PDF)
- [x] **n8n** (Visual workflow automation and self-hosted Zapier alternative with 400+ nodes)
- [x] **Homepage** (Modern application dashboard and server status portal)
- [x] **SearXNG** (Privacy-first metasearch engine combining 70+ search services)
- [x] **Wiki.js** (Modern Node.js documentation wiki with Markdown, WYSIWYG, and Git sync)
- [x] **pgAdmin 4** (The premier management and query interface for PostgreSQL)
- [x] **RustDesk Server** (Self-hosted remote desktop rendezvous and relay server in Rust)

---

### Phase 12: The Century Milestone (100 Web Applications & Diagnostics CLI)
- [x] **Jellyfin** (Open-source home media streaming server for movies, shows, and music)
- [x] **Meilisearch** (Ultra-fast, typo-tolerant open-source instant search engine in Rust)
- [x] **PhotoPrism** (AI-powered personal photo library and visual asset manager)
- [x] **MinIO** (High-performance, S3-compatible multi-cloud object storage daemon in Go)
- [x] **Conduit** (Ultra-lightweight, high-performance Matrix homeserver in Rust)
- [x] **Changedetection.io** (Automated website change detection, price tracking, and notification monitor)
- [x] **Gatus** (Automated service health monitoring dashboard and status page)
- [x] **Shlink** (Self-hosted URL shortener with REST API and detailed geolocated analytics)
- [x] **Linkding** (Minimalist, fast, tag-based self-hosted bookmark manager)
- [x] **Directus** (Instant REST & GraphQL API and data studio on top of SQL databases)
- [x] **Kopia** (Fast, encrypted, deduplicated server backup management with web UI)
- [x] **Actual Budget** (Privacy-first personal finance and envelope budgeting system)
- [x] **Planka** (Real-time collaborative kanban board for teams and agile task management)
- [x] **`setup.sh doctor`**: Automated system, perl module, container runtime, and repository integrity diagnostic CLI


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
