# Changelog

All notable changes to the **Virtualmin Web Apps Suite** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to Semantic Versioning.

---

## [1.10.0] - 2026-11-17

### Security & PCI DSS Compliance
- **Path Traversal Defense (PCI DSS Req 6.5.8)**:
  - Integrated `VirtualminWebApps::Common::sanitize_path()` across all 52 directory-based web applications.
  - Strictly rejects `..` traversal sequences, poison null bytes (`\0`), backslashes, leading slashes, and shell metacharacters.
- **Cryptographically Secure PRNG (PCI DSS Req 8.3.6)**:
  - Replaced pseudo-random password generation across all installers with `VirtualminWebApps::Common::generate_random_key()`, reading from `/dev/urandom` with a minimum 16-character length and high-entropy mixed character pool.
- **Port Bounds & Injection Prevention (PCI DSS Req 6.5.1)**:
  - Enforced strict numeric validation (`1024-65535`) on all daemon and microservice ports via `VirtualminWebApps::Common::validate_port()`, blocking shell and SQL injection vectors.
- **Protection of Stored Authentication Data (PCI DSS Req 3.4)**:
  - Enforced restricted file permissions (`chmod 0600`) on all configuration files containing database passwords, encryption keys, and secrets (`.env`, `config.php`, `parameters.yml`).
- **HTTP Response Splitting & Header Injection Defense**:
  - `VirtualminWebApps::ProxyHelper` sanitizes proxy paths and rejects CRLF control characters.
- **Systemd Service Unit Sanitization**:
  - `VirtualminWebApps::SystemdHelper` strictly validates unit filenames against path traversal out of `/etc/systemd/system/`.

### Added
- **Automated Unit & Security Test Suite (1,035 Tests)**:
  - Created dedicated TAP test suite under `tests/`:
    - `tests/01_syntax.t`: Syntax verification across all 73 scripts and libraries.
    - `tests/02_common_lib.t`: 38 unit tests verifying `Common.pl` security and utility routines.
    - `tests/03_port_manager.t`: 8 unit tests verifying port detection and bounds safety.
    - `tests/04_systemd_helper.t`: 10 unit tests verifying service unit management and name sanitization.
    - `tests/05_proxy_helper.t`: 9 unit tests verifying Apache/Nginx proxy block generation and injection prevention.
    - `tests/06_app_metadata.t`: 690 unit tests verifying all metadata and lifecycle hooks across all 69 applications.
    - `tests/07_security_input_filtering.t`: 207 security tests fuzzing every application against path traversal, command injection, and invalid port inputs.
  - Integrated test suite directly into `./setup.sh test` and `.github/workflows/ci.yml`.

### Changed
- **Module Build Revision Bump**:
  - Incremented `script_<name>_release` from `1` to `2` across all 69 applications in adherence to the module versioning policy.

---

## [1.9.0] - 2026-11-17

### Added
- **GitHub Actions CI Workflow** (`.github/workflows/ci.yml`):
  - Automated continuous integration workflow executing on push and PR to `main` and `master`.
  - Performs syntax verification (`./setup.sh test`), catalog extraction (`./setup.sh list`), and symlink validation.
- **Installation Guide Expansion** (`docs/INSTALLATION.md`):
  - Thoroughly expanded Section 4 to reflect all 17 application categories across the entire 69-application suite.
- **Navidrome** (`apps/navidrome/`):
  - Modern Subsonic-compatible music streaming server and API backend in Go (v0.64.2).
  - Standalone compiled binary daemon with dynamic port allocation (`4533`), systemd service unit, and SSL reverse proxy.
- **FlatPress** (`apps/flatpress/`):
  - Classic lightweight flat-file blogging engine (v1.5.1) requiring zero SQL database.
  - Fast file-based storage, Smarty theming, RSS/Atom feeds, and automated setup wizard routing.
- **Monica PRM** (`apps/monica/`):
  - Personal Relationship Management (PRM) platform (v4.1.2) built on Laravel & PHP.
  - Automated MariaDB/MySQL database provisioning, `.env` generation, and security key generation.
- **Mattermost Team Edition** (`apps/mattermost/`):
  - High-performance team collaboration, messaging, and chat server in Go (v10.5.1).
  - Standalone daemon with systemd integration, dynamic port allocation (`8065`), MariaDB integration, and WebSocket reverse proxy.
- **Paperless-ngx** (`apps/paperless_ngx/`):
  - Community-driven document indexing, Optical Character Recognition (OCR), and archiving system (v3.5.0).
  - Isolated Podman/Docker container runtime, systemd service unit, dynamic port allocation (`8000`), and WebSocket reverse proxy.
- **Milestone 69**:
  - Suite expanded to 69 fully automated web application installers.
  - Syntax verification passed across all 73 Perl scripts and shared libraries.

---

## [1.8.0] - 2026-11-17

### Added
- **Chamilo LMS** (`apps/chamilo/`):
  - Enterprise-grade open-source Learning Management System (v3.0.2).
  - SCORM-compliant courses, skills management, automated testing, and virtual classrooms.
- **LinkStack** (`apps/linkstack/`):
  - Privacy-first open-source Linktree alternative (v4.8.8).
  - Customizable profile themes, privacy-preserving click stats, vCard sharing, and multi-user support.
- **Vikunja** (`apps/vikunja/`):
  - Modern cross-platform to-do list and task organizer (v2.8.0).
  - Standalone Go binary with embedded frontend, systemd service, and reverse proxy.
  - Kanban sprint boards, Gantt charts, subtasks, relations, and attachments.
- **Gotify** (`apps/gotify/`):
  - Self-hosted real-time push notification and messaging server (v3.1.1).
  - Standalone Go binary with WebSocket reverse proxying and official Android client support.
- **Miniflux** (`apps/miniflux/`):
  - Minimalist, fast, opinionated feed reader (v2.3.5).
  - Standalone Go binary with PostgreSQL database wiring, keyboard navigation, and Fever API support.
- **Microbin** (`apps/microbin/`):
  - Ultra-fast, lightweight encrypted pastebin and file sharer in Rust (v2.1.0).
  - Client-side encryption, burn-after-reading pastes, QR code sharing, and systemd service.
- **Milestone 64**:
  - Suite expanded to 64 fully automated web application installers.
  - Syntax verification passed across all 68 Perl scripts and shared libraries.

---

## [1.7.0] - 2026-11-17

### Added
- **DokuWiki** (`apps/dokuwiki/`):
  - Standards-compliant flat-file wiki (v2026-07-14c) requiring no SQL database.
  - Built-in ACL permissions, revision history, and extensive plugin support.
- **Adminer** (`apps/adminer/`):
  - Lightweight single-file database management tool (v4.8.1).
  - Multi-engine support (MySQL, MariaDB, PostgreSQL, SQLite) with instant deployment and zero overhead.
- **YOURLS** (`apps/yourls/`):
  - Self-hosted URL shortener (v1.10.6) with click tracking, geographic analytics, and developer REST API.
  - Automated configuration of database credentials and random cookie security salt.
- **EspoCRM** (`apps/espocrm/`):
  - Modern Single Page Application (SPA) CRM platform (v10.1.3).
  - Lead/opportunity pipelines, email sync, workflow automation, and mobile-optimized interface.
- **InvoicePlane** (`apps/invoiceplane/`):
  - Open-source invoicing, quotes, and client management platform (v1.6.1).
  - Multi-currency, tax rules, customizable PDF invoicing, and automated configuration.
- **Leantime** (`apps/leantime/`):
  - Strategic and agile project management system (v3.4.6).
  - Idea boards, Kanban boards, Gantt charts, milestone tracking, and integrated timesheets.
- **Milestone 58**:
  - Suite expanded to 58 fully automated web application installers.
  - Syntax verification passed across all 62 Perl scripts and shared libraries.

---

## [1.6.0] - 2026-11-17

### Added
- **SnappyMail** (`apps/snappymail/`):
  - Fast, modern, and lightweight webmail client (v3.0.1) engineered as an active fork of RainLoop.
  - Zero SQL database requirement; connects directly to local Virtualmin Dovecot/Postfix or remote IMAP/SMTP.
  - Built-in OpenPGP client-side encryption, Sieve filters, and dedicated administrator panel.
- **Piwigo** (`apps/piwigo/`):
  - Mature open-source photo gallery and digital asset management platform (v16.5.0).
  - Batch photo uploads, EXIF/IPTC metadata extraction, granular album permissions, and mobile sync support.
- **LimeSurvey** (`apps/limesurvey/`):
  - Leading open-source online statistical survey and questionnaire engine (v6.17.19).
  - 30+ advanced question types, conditional branching, participant tokens, and export to SPSS, R, CSV, and Excel.
- **MyBB** (`apps/mybb/`):
  - Full-featured community discussion board and forum system (v1.8.41).
  - Inline moderation, member reputation ratings, theme/plugin system, and automated unpack handling.
- **MantisBT** (`apps/mantisbt/`):
  - Web-based bug and issue tracking platform (v2.28.4).
  - Granular project access control, customizable issue states, email notifications, and REST/SOAP APIs.
- **Wallabag** (`apps/wallabag/`):
  - Self-hosted read-it-later article archiver (v2.6.17).
  - Distraction-free article extraction, offline e-reader export (EPUB/PDF/MOBI), and browser/mobile sync.
- **Milestone 52**:
  - Suite expanded to 52 fully automated web application installers.
  - Syntax verification passed across all 56 Perl scripts and shared libraries.

---

## [1.5.0] - 2026-11-17

### Added
- **FreshRSS** (`apps/freshrss/`):
  - Self-hosted RSS/Atom feed aggregator (v1.24.3) with multi-user accounts and mobile API support.
- **Shaarli** (`apps/shaarli/`):
  - Minimalist personal bookmarking and link-sharing service (v0.16.10) with flat-file storage.
- **Lychee** (`apps/lychee/`):
  - Modern self-hosted photo management system and album gallery (v7.13.0) with automated Laravel environment configuration.
- **Baikal** (`apps/baikal/`):
  - Lightweight CalDAV & CardDAV server (v0.13.0) for cross-device calendar and contacts synchronization.
- **Grav CMS** (`apps/grav/`):
  - High-speed flat-file CMS (v2.2.30) pre-packaged with the Grav Admin Panel.
- **Firefly III** (`apps/firefly_iii/`):
  - Free and open-source personal finances manager (v6.7.9) with automated encryption key and database provisioning.
- **Milestone 46**:
  - Suite expanded to 46 fully automated web application installers.
  - Updated `README.md`, `ROADMAP.md`, and `docs/APPLICATIONS.md`.

---

## [1.4.0] - 2026-11-17

### Added
- **Roundcube Webmail** (`apps/roundcube/`):
  - Browser-based multilingual IMAP webmail client (v1.6.9).
  - Automated MariaDB schema import, DES encryption key generation, and local Dovecot/Postfix integration.
- **phpMyAdmin** (`apps/phpmyadmin/`):
  - The premier web-based MySQL/MariaDB database administration tool (v5.2.1).
  - Automated Blowfish secret generation and dedicated template cache folder.
- **PrivateBin** (`apps/privatebin/`):
  - Zero-knowledge 256-bit AES-GCM encrypted pastebin (v2.1.1).
  - Client-side encryption ensures the server has zero visibility into pasted content.
- **Kanboard** (`apps/kanboard/`):
  - Minimalist visual Kanban project management tool (v1.2.40).
  - Zero-configuration SQLite backend by default or optional MariaDB.
- **Trilium Notes** (`apps/trilium/`):
  - Hierarchical personal knowledge base and note-taking server (v0.95.0).
  - Standalone bundled Node.js server binary with dedicated systemd service and reverse proxying with WebSockets.
- **Netdata Monitoring** (`apps/netdata/`):
  - Real-time infrastructure observability and metrics dashboard.
  - Isolated system daemon with automated Apache/Nginx reverse proxying to port 19999.
- **Documentation Expansion**:
  - Updated `README.md`, `ROADMAP.md`, and `docs/APPLICATIONS.md` to catalog all 40 applications.

---

## [1.3.0] - 2026-11-17

### Added
- **osCommerce Installer** (`apps/oscommerce/`):
  - Added support for osCommerce v4 Community Edition.
  - Native PlugnPay payment gateway integration instructions added to `docs/ECOMMERCE_GUIDE.md`.
  - Configured database provisioning and permission hardening.
- **SuiteCRM Installer** (`apps/suitecrm/`):
  - Enterprise Customer Relationship Management (CRM) platform (version 8.10.2).
  - Open-source replacement for enterprise CRM offerings in Virtualmin Pro.
- **Moodle LMS Installer** (`apps/moodle/`):
  - World-leading Learning Management System (LMS) version 4.4.4.
  - Hardened automated data directory configuration (`$HOME/moodledata`) placed outside the public web root.
- **Passbolt Password Manager** (`apps/passbolt/`):
  - OpenPGP-based team password and credential manager version 5.18.0.
  - Automated permissions for CakePHP tmp/cache paths.
- **CyberChef Installer** (`apps/cyberchef/`):
  - GCHQ's "Cyber Swiss Army Knife" client-side security and data analysis web tool (version 11.5.0).
  - Client-side execution with zero backend/database dependencies.
- **IT-Tools Installer** (`apps/it_tools/`):
  - Useful suite of developer and sysadmin tools (token generators, regex testers, converters, formatters).
  - Client-side static assets with zero backend/database dependencies.
- **Updated Reference Manual**:
  - Expanded `docs/APPLICATIONS.md` to cover all 34 web applications.
  - Expanded `docs/ECOMMERCE_GUIDE.md` with osCommerce PlugnPay instructions.

---

## [1.2.0] - 2026-11-17

### Added
- **Invoice Ninja** (`apps/invoiceninja/`): Laravel-powered invoicing, payments, and expense tracking with cron task automation.
- **Ghost** (`apps/ghost/`): Node.js modern blogging and newsletter publishing engine with dedicated systemd service and reverse proxying.
- **Drupal** (`apps/drupal/`): Enterprise PHP/MariaDB content management system (v10.3.5) with automated hash salt generation.
- **Joomla!** (`apps/joomla/`): Mobile-ready content management system (v5.1.4).
- **phpBB** (`apps/phpbb/`): Classic community bulletin board forum (v3.3.13).
- **Umami Analytics** (`apps/umami/`): Modern privacy-friendly Google Analytics alternative with systemd service and reverse proxying.

---

## [1.1.0] - 2026-11-17

### Added
- **Core Priority 1**: Vaultwarden (Rust Bitwarden server with WebSocket synchronization and SSL reverse proxy).
- **Core Priority 2**: AdGuard Home (Go DNS ad/tracker blocker) and Pi-hole (DNS sinkhole).
- **Cloud Collaboration**: Nextcloud Hub and ownCloud Classic with automated `occ` setup.
- **E-Commerce Suite (PlugnPay & FOSS)**:
  - WooCommerce (WordPress WP-CLI bundle)
  - OpenCart (CLI automated database setup)
  - PrestaShop & Thirty Bees (`index_cli.php` automation)
  - AbanteCart
  - FOSSBilling
  - Zen Cart
  - LiteCart
  - CubeCart
- **Wikis & Analytics**:
  - MediaWiki & BookStack
  - Matomo Analytics (Piwik)
  - Dolibarr ERP & CRM
  - Flarum Forum
  - Forgejo Git
  - File Browser lightweight web manager
  - Uptime Kuma monitoring dashboard
- **Shared Perl Helper Libraries**:
  - `lib/Common.pl`: Resilient downloads, multi-format extraction, ownership, arch detection.
  - `lib/PortManager.pl`: TCP port conflict detection and dynamic allocation.
  - `lib/SystemdHelper.pl`: Systemd unit templating, reloading, and lifecycle management.
  - `lib/ProxyHelper.pl`: Automated Apache & Nginx reverse proxy configuration with WebSocket support.
- **Management CLI (`setup.sh`)**:
  - Commands: `install`, `update`, `remove`, `status`, `list`, `test`.
  - Dynamic module parsing and formatting.

---

## [1.0.0] - 2026-11-17

### Initial Release
- Project monorepo architecture and Virtualmin custom script subsystem integration.
- Module Build Number revision tracking policy (`script_<name>_release`).
