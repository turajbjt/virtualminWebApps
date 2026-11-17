# Virtualmin Web Apps Suite

<p align="center">
  <strong>A modular, enterprise-ready collection of 1-click open-source web application installers for <a href="https://www.virtualmin.com/">Virtualmin</a>.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Virtualmin-GPL%20%26%20Pro-blue.svg" alt="Virtualmin Compatible">
  <img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="License">
  <img src="https://img.shields.io/badge/Architecture-Modular%20Monorepo-orange.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/Tests-Passing-brightgreen.svg" alt="Tests">
</p>

---

## Overview

The **Virtualmin Web Apps Suite** transforms any Virtualmin server into an application deployment powerhouse. It extends Virtualmin's native **Manage Web Apps / Install Scripts** engine with modern, open-source applications that are traditionally either missing from the free GPL version or unavailable in Virtualmin Pro altogether.

The repository currently features **69 fully automated web application installers** spanning cloud collaboration, email, database administration, developer tooling, personal finance, photo galleries, surveys, issue tracking, wikis, URL shortening, project management, push notifications, e-learning, feed readers, security, system metrics, ERP/CRM, music streaming, document archiving, team communication, and the entire open-source e-commerce and shopping cart ecosystem.

### Key Capabilities
* **Isolated Daemons & Microservices**: Deploy modern Go, Rust, Node, and container services (Vaultwarden, AdGuard Home, Pi-hole, Trilium Notes, Netdata, Uptime Kuma) running as isolated systemd services behind automated Apache or Nginx reverse proxies with automatic WebSocket forwarding.
* **Complete E-Commerce Suite (PlugnPay Ready)**: Deploy top open-source shopping carts (WooCommerce, OpenCart, osCommerce, PrestaShop, Thirty Bees, AbanteCart, FOSSBilling, Zen Cart, LiteCart, CubeCart) pre-configured and ready for payment gateway integration.
* **Essential Server Infrastructure**: Deploy premier server utilities including Roundcube Webmail, phpMyAdmin database administration, Baikal CalDAV/CardDAV sync, and PrivateBin zero-knowledge pastebin.
* **Private Cloud, Media & Feeds**: Deploy Nextcloud, ownCloud, Lychee photo management, FreshRSS feed reader, and Shaarli bookmarking.
* **Enterprise Business, Finance & CMS**: Deploy SuiteCRM, Dolibarr ERP/CRM, Firefly III finance manager, Invoice Ninja, Moodle LMS, Grav flat-file CMS, Drupal, Joomla!, phpBB, and Flarum.
* **Single-Command Server Setup**: An all-in-one CLI tool (`setup.sh`) connects, updates, tests, and uninstalls the suite with a single command.

---

## Available Web Applications

| Application | Category | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Vaultwarden** | Security | `1.32.7` | `1` | Rust Daemon + Systemd + SSL Reverse Proxy + WebSockets | [App Readme](apps/vaultwarden/README.md) |
| **AdGuard Home** | System / DNS | `0.107.80` | `1` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](apps/adguard_home/README.md) |
| **Pi-hole** | System / DNS | `latest` | `1` | Containerized Daemon + Systemd + Web Reverse Proxy | [App Readme](apps/pihole/README.md) |
| **Uptime Kuma** | System | `latest` | `1` | Node.js Daemon + Systemd + WebSocket Reverse Proxy | [App Readme](apps/uptime_kuma/README.md) |
| **File Browser** | System | `2.30.0` | `1` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](apps/filebrowser/README.md) |
| **Forgejo** | Development | `17.0.1` | `1` | Standalone Go Binary + Systemd + Git Reverse Proxy | [App Readme](apps/forgejo/README.md) |
| **Nextcloud** | Cloud | `30.0.6` | `1` | PHP 8.1+ / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/nextcloud/README.md) |
| **ownCloud** | Cloud | `10.13.4` | `1` | PHP / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/owncloud/README.md) |
| **MediaWiki** | Wiki | `1.42.3` | `1` | PHP / MariaDB + Automated CLI Installer (Pro Equivalent) | [App Readme](apps/mediawiki/README.md) |
| **BookStack** | Wiki | `24.05.4` | `1` | Laravel / PHP / MariaDB + Automated Migrations | [App Readme](apps/bookstack/README.md) |
| **Drupal** | CMS | `10.3.5` | `1` | Enterprise PHP / MariaDB CMS (Pro Equivalent) | [App Readme](apps/drupal/README.md) |
| **Joomla!** | CMS | `5.1.4` | `1` | Mobile-Ready PHP / MariaDB CMS (Pro Equivalent) | [App Readme](apps/joomla/README.md) |
| **Ghost** | Blog | `5-alpine` | `1` | Node.js Publishing Platform + Systemd (Pro Equivalent) | [App Readme](apps/ghost/README.md) |
| **Matomo** | Analytics | `5.1.2` | `1` | PHP / MariaDB + Automated Archiving Cron (Pro Equivalent) | [App Readme](apps/matomo/README.md) |
| **Umami** | Analytics | `latest` | `1` | Modern Privacy Analytics + Systemd + Reverse Proxy | [App Readme](apps/umami/README.md) |
| **Flarum** | Community | `latest` | `1` | Modern PHP / Composer Discussion Forum | [App Readme](apps/flarum/README.md) |
| **phpBB** | Community | `3.3.13` | `1` | Classic PHP / MariaDB Bulletin Board Forum | [App Readme](apps/phpbb/README.md) |
| **Dolibarr** | Business | `20.0.2` | `1` | Full ERP & CRM Suite (Pro Equivalent) | [App Readme](apps/dolibarr/README.md) |
| **SuiteCRM** | Business | `8.10.2` | `1` | Enterprise Customer Relationship Management | [App Readme](apps/suitecrm/README.md) |
| **Invoice Ninja** | Business | `5.10.40` | `1` | Invoicing, Payments & Time Tracking (Pro Equivalent) | [App Readme](apps/invoiceninja/README.md) |
| **Moodle** | Education | `4.4.4` | `1` | Leading Learning Management System (LMS) | [App Readme](apps/moodle/README.md) |
| **Passbolt** | Security | `5.18.0` | `1` | Open-Source Team Password & Secret Manager | [App Readme](apps/passbolt/README.md) |
| **CyberChef** | Utilities | `11.5.0` | `1` | Client-Side Cyber Security Swiss Army Knife | [App Readme](apps/cyberchef/README.md) |
| **IT-Tools** | Development | `2024.10.22` | `1` | Standalone Web Developer & Sysadmin Utilities | [App Readme](apps/it_tools/README.md) |
| **Roundcube** | Email | `1.6.9` | `1` | Modern Webmail Platform + IMAP/SMTP Integration | [App Readme](apps/roundcube/README.md) |
| **phpMyAdmin** | Database | `5.2.1` | `1` | Web-Based MySQL/MariaDB Database Administration | [App Readme](apps/phpmyadmin/README.md) |
| **PrivateBin** | Security | `2.1.1` | `1` | Zero-Knowledge Encrypted Pastebin (Client-Side AES) | [App Readme](apps/privatebin/README.md) |
| **Kanboard** | Project | `1.2.40` | `1` | Minimalist Visual Kanban Project Management | [App Readme](apps/kanboard/README.md) |
| **Trilium Notes** | Knowledge | `0.95.0` | `1` | Standalone Node.js Daemon + WebSocket Reverse Proxy | [App Readme](apps/trilium/README.md) |
| **Netdata** | System | `latest` | `1` | Real-Time Metrics & Observability Daemon + Reverse Proxy | [App Readme](apps/netdata/README.md) |
| **FreshRSS** | News | `1.24.3` | `1` | Self-Hosted RSS/Atom Feed Reader & Aggregator | [App Readme](apps/freshrss/README.md) |
| **Shaarli** | Utilities | `0.16.10` | `1` | Personal Minimalist Bookmarking & Link Sharing | [App Readme](apps/shaarli/README.md) |
| **Lychee** | Media | `7.13.0` | `1` | Self-Hosted Photo Management & Gallery Platform | [App Readme](apps/lychee/README.md) |
| **Baikal** | Sync | `0.13.0` | `1` | Lightweight CalDAV & CardDAV Contacts/Calendar Sync | [App Readme](apps/baikal/README.md) |
| **Grav** | CMS | `2.2.30` | `1` | Modern Fast Flat-File CMS with Admin Panel | [App Readme](apps/grav/README.md) |
| **Firefly III** | Finance | `6.7.9` | `1` | Personal Finances, Budget & Expense Manager | [App Readme](apps/firefly_iii/README.md) |
| **WooCommerce** | Commerce | `latest` | `1` | WordPress + WP-CLI Automated Bundle (PlugnPay Ready) | [App Readme](apps/woocommerce/README.md) |
| **OpenCart** | Commerce | `4.0.2.3` | `1` | PHP / MariaDB + CLI Installer (PlugnPay Ready) | [App Readme](apps/opencart/README.md) |
| **osCommerce** | Commerce | `4.14` | `1` | Classic & Pioneer Shopping Cart Platform (PlugnPay Ready) | [App Readme](apps/oscommerce/README.md) |
| **PrestaShop** | Commerce | `8.1.7` | `1` | PHP / MariaDB + `index_cli.php` Installer (PlugnPay Ready) | [App Readme](apps/prestashop/README.md) |
| **Thirty Bees** | Commerce | `1.7.0` | `1` | High-Performance PrestaShop 1.6 Fork (PlugnPay Ready) | [App Readme](apps/thirtybees/README.md) |
| **AbanteCart** | Commerce | `1.4.1` | `1` | Modular PHP / MariaDB Shopping Cart (PlugnPay Ready) | [App Readme](apps/abantecart/README.md) |
| **FOSSBilling** | Commerce | `0.6.22` | `1` | BoxBilling Successor, Hosting & Carts (PlugnPay Ready) | [App Readme](apps/fossbilling/README.md) |
| **Zen Cart** | Commerce | `2.2.2` | `1` | Classic Open-Source Shopping Cart (PlugnPay Ready) | [App Readme](apps/zencart/README.md) |
| **LiteCart** | Commerce | `2.5.5` | `1` | Lightweight High-Speed PHP Cart (PlugnPay Ready) | [App Readme](apps/litecart/README.md) |
| **CubeCart** | Commerce | `6.5.7` | `1` | Full-Featured PHP E-Commerce Platform (PlugnPay Ready) | [App Readme](apps/cubecart/README.md) |
| **SnappyMail** | Email | `3.0.1` | `1` | Fast, Modern Webmail Client (Zero Database / IMAP / SMTP) | [App Readme](apps/snappymail/README.md) |
| **Piwigo** | Media | `16.5.0` | `1` | PHP / MariaDB Photo Gallery & Digital Asset Management | [App Readme](apps/piwigo/README.md) |
| **LimeSurvey** | Surveys | `6.17.19` | `1` | Enterprise Online Survey & Questionnaires Platform | [App Readme](apps/limesurvey/README.md) |
| **MyBB** | Community | `1.8.41` | `1` | Modern PHP / MariaDB Discussion Board & Forum | [App Readme](apps/mybb/README.md) |
| **MantisBT** | Project | `2.28.4` | `1` | Web-Based Issue & Bug Tracking System (PHP / MariaDB) | [App Readme](apps/mantisbt/README.md) |
| **Wallabag** | Utilities | `2.6.17` | `1` | Self-Hosted Read-It-Later & Article Archiver (PHP / MariaDB) | [App Readme](apps/wallabag/README.md) |
| **DokuWiki** | Wiki | `2026-07-14c` | `1` | Standards-Compliant Flat-File Wiki (Zero Database) | [App Readme](apps/dokuwiki/README.md) |
| **Adminer** | Database | `4.8.1` | `1` | Lightweight Database Management Tool (Single-File PHP) | [App Readme](apps/adminer/README.md) |
| **YOURLS** | Utilities | `1.10.6` | `1` | Your Own URL Shortener with Click Analytics & API | [App Readme](apps/yourls/README.md) |
| **EspoCRM** | Business | `10.1.3` | `1` | Fast Single-Page Application (SPA) CRM Platform | [App Readme](apps/espocrm/README.md) |
| **InvoicePlane** | Business | `1.6.1` | `1` | Open-Source Invoicing, Quotes & Client Management | [App Readme](apps/invoiceplane/README.md) |
| **Leantime** | Project | `3.4.6` | `1` | Strategic & Agile Project Management (Kanban, Milestones) | [App Readme](apps/leantime/README.md) |
| **Chamilo** | Education | `3.0.2` | `1` | Enterprise Open-Source E-Learning Platform (PHP / MariaDB) | [App Readme](apps/chamilo/README.md) |
| **LinkStack** | Utilities | `4.8.8` | `1` | Open-Source Linktree Alternative & Bio Link Hub (PHP) | [App Readme](apps/linkstack/README.md) |
| **Vikunja** | Project | `2.8.0` | `1` | To-Do & Task Management + Kanban/Gantt (Go Binary + Systemd) | [App Readme](apps/vikunja/README.md) |
| **Gotify** | System | `3.1.1` | `1` | Real-Time Push Notification Server (Go Binary + WebSockets) | [App Readme](apps/gotify/README.md) |
| **Miniflux** | News | `2.3.5` | `1` | Minimalist Feed Reader (Go Binary + PostgreSQL + Systemd) | [App Readme](apps/miniflux/README.md) |
| **Microbin** | Utilities | `2.1.0` | `1` | Lightweight Encrypted Pastebin & File Sharing (Rust Binary) | [App Readme](apps/microbin/README.md) |
| **Navidrome** | Media | `0.64.2` | `1` | Subsonic Modern Music Streaming Server (Go Binary + Systemd) | [App Readme](apps/navidrome/README.md) |
| **FlatPress** | Blog | `1.5.1` | `1` | Lightweight Flat-File Blogging Engine (Zero SQL Database) | [App Readme](apps/flatpress/README.md) |
| **Monica PRM** | Business | `4.1.2` | `1` | Personal Relationship Management Platform (PHP / MariaDB) | [App Readme](apps/monica/README.md) |
| **Mattermost** | Chat | `10.5.1` | `1` | Team Collaboration & Chat Platform (Go Binary + Systemd) | [App Readme](apps/mattermost/README.md) |
| **Paperless-ngx** | Documents | `3.5.0` | `1` | Document Archiving, Indexing & OCR (Container + Systemd) | [App Readme](apps/paperless_ngx/README.md) |

> **Module Build Number Policy**: The `Build` number tracks the revision of our Virtualmin installer module independently of the upstream application version. Every time an installer script or service configuration is updated, its build number is incremented by 1 so server administrators can easily track changes and verify version freshness via `./setup.sh list`.

*For detailed technical specifications of each app, see the [Applications Reference Manual](docs/APPLICATIONS.md). For planned features, see [ROADMAP.md](ROADMAP.md).*

---

## Documentation Library

* **[Applications Reference Manual](docs/APPLICATIONS.md)**: Full runtime, database, storage directory, port, and systemd service profiles for all 69 applications.
* **[Installation Guide](docs/INSTALLATION.md)**: Automated CLI installation and manual Webmin GUI registration instructions.
* **[Upgrades & Maintenance Guide](docs/UPGRADE_GUIDE.md)**: Managing repository updates (`setup.sh update`), Virtualmin GUI upgrades, and automated cron checking.
* **[E-Commerce & PlugnPay Integration Guide](docs/ECOMMERCE_GUIDE.md)**: Store setup and PlugnPay payment gateway module configuration.
* **[Developer Guide](docs/DEVELOPER_GUIDE.md)**: Virtualmin install script API hooks, coding conventions, and module build tracking.
* **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)**: Resolving port conflicts, SELinux policies, Apache/Nginx reverse proxying, and DNS port 53 allocation.
* **[Changelog](CHANGELOG.md)**: Comprehensive record of all releases, version milestones, and structural updates.

---

## Quick Start Installation

Run the following commands on your Virtualmin server as `root` (or with `sudo`):

```bash
# 1. Clone the repository
git clone git@github.com:turajbjt/virtualminWebApps.git /opt/virtualminWebApps
cd /opt/virtualminWebApps

# 2. Register the suite into Virtualmin
sudo ./setup.sh install
```

### Accessing in Virtualmin
1. Log into your Virtualmin web interface (`https://your-server:10000`).
2. Select any Virtual Server.
3. Click **Manage Web Apps** (or **Install Scripts**) in the left sidebar menu.
4. Click **Available Scripts** to install any application.

---

## Suite Management CLI (`./setup.sh`)

The repository includes a management CLI (`setup.sh`) for server management:

```bash
sudo ./setup.sh <command>
```

| Command | Action |
| :--- | :--- |
| `install` | Registers the suite into Virtualmin configuration and synchronizes scripts. |
| `update` | Pulls latest Git changes, re-synchronizes script links, and refreshes Webmin. |
| `remove` | Safely unhooks the suite from Virtualmin configuration. |
| `list` | Displays a table of all available web applications, categories, and versions. |
| `status` | Checks server configuration, active script paths, and available apps. |
| `test` | Runs syntax validation (`perl -cw`) across all scripts and shared libraries. |

---

## Repository Structure

```text
virtualminWebApps/
├── setup.sh                         # Master CLI manager (install/update/status/list/test)
├── README.md                        # Project documentation and landing page
├── ROADMAP.md                       # Comprehensive app roadmap and backlog
├── apps/                            # Individual application modules
│   ├── vaultwarden/                 # Vaultwarden Bitwarden password manager
│   ├── adguard_home/                # AdGuard Home network ad/tracker blocker
│   ├── pihole/                      # Pi-hole DNS sinkhole
│   ├── nextcloud/                   # Nextcloud cloud collaboration platform
│   ├── owncloud/                    # ownCloud cloud storage
│   ├── opencart/                    # OpenCart e-commerce platform
│   ├── prestashop/                  # PrestaShop e-commerce platform
│   ├── thirtybees/                  # Thirty Bees high-performance e-commerce
│   └── abantecart/                  # AbanteCart modular shopping cart
├── lib/                             # Shared Perl helper libraries
│   ├── Common.pl                    # Downloads, archive extraction, permissions, architecture
│   ├── PortManager.pl               # Dynamic TCP port detection and allocation
│   ├── SystemdHelper.pl             # Automated systemd service unit lifecycle
│   └── ProxyHelper.pl               # Apache & Nginx reverse proxy & WebSocket wiring
├── docs/                            # Comprehensive guides and documentation
│   ├── INSTALLATION.md              # Detailed server setup and installation guide
│   ├── DEVELOPER_GUIDE.md           # Guide to writing new Virtualmin web app installers
│   ├── ECOMMERCE_GUIDE.md           # Shopping carts and PlugnPay payment integration
│   └── TROUBLESHOOTING.md           # Common edge cases, port binding, and SELinux
└── scripts/                         # Flattened directory exposed to Virtualmin
    ├── lib -> ../lib
    ├── vaultwarden.pl -> ../apps/vaultwarden/vaultwarden.pl
    └── ...
```

---

## Documentation Links

* [Application Reference Manual](docs/APPLICATIONS.md): Complete technical reference for all 64 web applications, default ports, paths, database types, and services.
* [Installation Guide](docs/INSTALLATION.md): Detailed installation instructions, prerequisites, and automated vs manual setup.
* [Upgrades & Maintenance Guide](docs/UPGRADE_GUIDE.md): Complete guide to updating the suite (`setup.sh update`) and upgrading applications on virtual servers via GUI and CLI.
* [Developer Guide](docs/DEVELOPER_GUIDE.md): Complete specifications of the Virtualmin script API and how to contribute new application modules.
* [E-Commerce & PlugnPay Guide](docs/ECOMMERCE_GUIDE.md): Instructions for setting up stores and installing PlugnPay payment gateways.
* [Troubleshooting Guide](docs/TROUBLESHOOTING.md): Solutions for port conflicts, SELinux policies, reverse proxies, and Web Crypto requirements.
* [Master Roadmap](ROADMAP.md): Categorized list of upcoming FOSS applications.

---

## Testing & Quality Assurance

To test that all Perl modules and application scripts have valid syntax and load shared libraries properly:

```bash
./setup.sh test
```

---

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).
