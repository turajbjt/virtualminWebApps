# Changelog

All notable changes to the **Virtualmin Web Apps Suite** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to Semantic Versioning.

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
