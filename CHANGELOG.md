# Changelog

All notable changes to the **Virtualmin Web Apps Suite** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to Semantic Versioning.

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
