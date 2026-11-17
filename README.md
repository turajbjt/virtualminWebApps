# Virtualmin Web Apps Suite

<p align="center">
  <strong>A modular, enterprise-ready collection of 1-click open-source web application installers for <a href="https://www.virtualmin.com/">Virtualmin</a>.</strong>
</p>

<p align="center">
  <a href="https://www.virtualmin.com/"><img src="https://img.shields.io/badge/Virtualmin-GPL%20%26%20Pro-blue.svg" alt="Virtualmin Compatible"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="License: GPLv3"></a>
  <a href="https://github.com/turajbjt/virtualminWebApps/actions/workflows/ci.yml"><img src="https://github.com/turajbjt/virtualminWebApps/actions/workflows/ci.yml/badge.svg" alt="CI Status"></a>
  <img src="https://img.shields.io/badge/Apps-69%20Available-orange.svg" alt="69 Applications">
  <img src="https://img.shields.io/badge/Tests-1041%20Passing-brightgreen.svg" alt="1041 Tests Passing">
</p>

---

## Overview

The **Virtualmin Web Apps Suite** transforms any Virtualmin server into an application deployment powerhouse. It extends Virtualmin's native **Manage Web Apps / Install Scripts** engine with modern, open-source applications that are traditionally either missing from the free GPL version or unavailable in Virtualmin Pro altogether.

The repository currently features **69 fully automated web application installers** spanning cloud collaboration, email, database administration, developer tooling, personal finance, photo galleries, surveys, issue tracking, wikis, URL shortening, project management, push notifications, e-learning, feed readers, security, system metrics, ERP/CRM, music streaming, document archiving, team communication, and the entire open-source e-commerce and shopping cart ecosystem.

### Key Capabilities
* **Isolated Daemons & Microservices**: Deploy modern Go, Rust, Node, and container services (Vaultwarden, AdGuard Home, Pi-hole, Trilium Notes, Netdata, Uptime Kuma) running as isolated systemd services behind automated Apache or Nginx reverse proxies with automatic WebSocket forwarding.
* **Complete E-Commerce Suite (PlugnPay Ready)**: Deploy top open-source shopping carts (WooCommerce, OpenCart, osCommerce, PrestaShop, Thirty Bees, AbanteCart, FOSSBilling, Zen Cart, LiteCart, CubeCart) pre-configured and ready for payment gateway integration.
* **PCI DSS Compliant & Security Hardened**: Built following PCI DSS v4.0 secure development standards (Req 6.5, 8.3, 3.4)—enforcing strict path traversal defense (`..` rejection), numeric port validation, CRLF injection prevention, cryptographically secure `/dev/urandom` secret generation, and restricted file modes (`0600`) for all configuration files holding credentials.
* **Comprehensive Automated Unit Testing**: Integrated 1,000+ assertion TAP test suite verifying syntax, library routines, application metadata, security fuzzing, and input validation via `./setup.sh test` and continuous integration.
* **Essential Server Infrastructure**: Deploy premier server utilities including Roundcube Webmail, phpMyAdmin database administration, Baikal CalDAV/CardDAV sync, and PrivateBin zero-knowledge pastebin.
* **Private Cloud, Media & Feeds**: Deploy Nextcloud, ownCloud, Lychee photo management, FreshRSS feed reader, and Shaarli bookmarking.
* **Enterprise Business, Finance & CMS**: Deploy SuiteCRM, Dolibarr ERP/CRM, Firefly III finance manager, Invoice Ninja, Moodle LMS, Grav flat-file CMS, Drupal, Joomla!, phpBB, and Flarum.
* **Single-Command Server Setup**: An all-in-one CLI tool (`setup.sh`) connects, updates, tests, and uninstalls the suite with a single command.

---

## Available Web Applications

The suite provides **69 fully automated web application installers** sorted and grouped into **24 classifications**. All applications follow standardized lifecycle management, isolated runtime environments, and PCI DSS v4.0-compliant input validation and security controls.

### Classification Directory

| Classification | Applications | Count |
| :--- | :--- | :---: |
| [**Analytics**](#analytics) | **Matomo**, **Umami** | `2` |
| [**Blog**](#blog) | **FlatPress**, **Ghost** | `2` |
| [**Business**](#business) | **Dolibarr**, **EspoCRM**, **Invoice Ninja**, **InvoicePlane**, **Monica PRM**, **SuiteCRM** | `6` |
| [**CMS**](#cms) | **Drupal**, **Grav**, **Joomla!** | `3` |
| [**Chat**](#chat) | **Mattermost** | `1` |
| [**Cloud**](#cloud) | **Nextcloud**, **ownCloud** | `2` |
| [**Commerce**](#commerce) | **AbanteCart**, **CubeCart**, **FOSSBilling**, **LiteCart**, **OpenCart**, **osCommerce**, **PrestaShop**, **Thirty Bees**, **WooCommerce**, **Zen Cart** | `10` |
| [**Community**](#community) | **Flarum**, **MyBB**, **phpBB** | `3` |
| [**Database**](#database) | **Adminer**, **phpMyAdmin** | `2` |
| [**Development**](#development) | **Forgejo**, **IT-Tools** | `2` |
| [**Documents**](#documents) | **Paperless-ngx** | `1` |
| [**Education**](#education) | **Chamilo**, **Moodle** | `2` |
| [**Email**](#email) | **Roundcube**, **SnappyMail** | `2` |
| [**Finance**](#finance) | **Firefly III** | `1` |
| [**Knowledge**](#knowledge) | **Trilium Notes** | `1` |
| [**Media**](#media) | **Lychee**, **Navidrome**, **Piwigo** | `3` |
| [**News**](#news) | **FreshRSS**, **Miniflux** | `2` |
| [**Project**](#project) | **Kanboard**, **Leantime**, **MantisBT**, **Vikunja** | `4` |
| [**Security**](#security) | **Passbolt**, **PrivateBin**, **Vaultwarden** | `3` |
| [**Surveys**](#surveys) | **LimeSurvey** | `1` |
| [**Sync**](#sync) | **Baikal** | `1` |
| [**System & DNS**](#system--dns) | **AdGuard Home**, **File Browser**, **Gotify**, **Netdata**, **Pi-hole**, **Uptime Kuma** | `6` |
| [**Utilities**](#utilities) | **CyberChef**, **LinkStack**, **Microbin**, **Shaarli**, **Wallabag**, **YOURLS** | `6` |
| [**Wiki**](#wiki) | **BookStack**, **DokuWiki**, **MediaWiki** | `3` |
| **Total** | **24 Application Classifications** | **`69`** |

---

### Analytics

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Matomo** | `5.1.2` | `2` | PHP / MariaDB + Automated Archiving Cron (Pro Equivalent) | [App Readme](apps/matomo/README.md) |
| **Umami** | `latest` | `2` | Modern Privacy Analytics + Systemd + Reverse Proxy | [App Readme](apps/umami/README.md) |

### Blog

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **FlatPress** | `1.5.1` | `2` | Lightweight Flat-File Blogging Engine (Zero SQL Database) | [App Readme](apps/flatpress/README.md) |
| **Ghost** | `5-alpine` | `2` | Node.js Publishing Platform + Systemd (Pro Equivalent) | [App Readme](apps/ghost/README.md) |

### Business

*6 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Dolibarr** | `20.0.2` | `2` | Full ERP & CRM Suite (Pro Equivalent) | [App Readme](apps/dolibarr/README.md) |
| **EspoCRM** | `10.1.3` | `2` | Fast Single-Page Application (SPA) CRM Platform | [App Readme](apps/espocrm/README.md) |
| **Invoice Ninja** | `5.10.40` | `2` | Invoicing, Payments & Time Tracking (Pro Equivalent) | [App Readme](apps/invoiceninja/README.md) |
| **InvoicePlane** | `1.6.1` | `2` | Open-Source Invoicing, Quotes & Client Management | [App Readme](apps/invoiceplane/README.md) |
| **Monica PRM** | `4.1.2` | `2` | Personal Relationship Management Platform (PHP / MariaDB) | [App Readme](apps/monica/README.md) |
| **SuiteCRM** | `8.10.2` | `2` | Enterprise Customer Relationship Management | [App Readme](apps/suitecrm/README.md) |

### CMS

*3 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Drupal** | `10.3.5` | `2` | Enterprise PHP / MariaDB CMS (Pro Equivalent) | [App Readme](apps/drupal/README.md) |
| **Grav** | `2.2.30` | `2` | Modern Fast Flat-File CMS with Admin Panel | [App Readme](apps/grav/README.md) |
| **Joomla!** | `5.1.4` | `2` | Mobile-Ready PHP / MariaDB CMS (Pro Equivalent) | [App Readme](apps/joomla/README.md) |

### Chat

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Mattermost** | `10.5.1` | `2` | Team Collaboration & Chat Platform (Go Binary + Systemd) | [App Readme](apps/mattermost/README.md) |

### Cloud

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Nextcloud** | `30.0.6` | `2` | PHP 8.1+ / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/nextcloud/README.md) |
| **ownCloud** | `10.13.4` | `2` | PHP / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/owncloud/README.md) |

### Commerce

*10 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **AbanteCart** | `1.4.1` | `2` | Modular PHP / MariaDB Shopping Cart (PlugnPay Ready) | [App Readme](apps/abantecart/README.md) |
| **CubeCart** | `6.5.7` | `2` | Full-Featured PHP E-Commerce Platform (PlugnPay Ready) | [App Readme](apps/cubecart/README.md) |
| **FOSSBilling** | `0.6.22` | `2` | BoxBilling Successor, Hosting & Carts (PlugnPay Ready) | [App Readme](apps/fossbilling/README.md) |
| **LiteCart** | `2.5.5` | `2` | Lightweight High-Speed PHP Cart (PlugnPay Ready) | [App Readme](apps/litecart/README.md) |
| **OpenCart** | `4.0.2.3` | `2` | PHP / MariaDB + CLI Installer (PlugnPay Ready) | [App Readme](apps/opencart/README.md) |
| **osCommerce** | `4.14` | `2` | Classic & Pioneer Shopping Cart Platform (PlugnPay Ready) | [App Readme](apps/oscommerce/README.md) |
| **PrestaShop** | `8.1.7` | `2` | PHP / MariaDB + `index_cli.php` Installer (PlugnPay Ready) | [App Readme](apps/prestashop/README.md) |
| **Thirty Bees** | `1.7.0` | `2` | High-Performance PrestaShop 1.6 Fork (PlugnPay Ready) | [App Readme](apps/thirtybees/README.md) |
| **WooCommerce** | `latest` | `2` | WordPress + WP-CLI Automated Bundle (PlugnPay Ready) | [App Readme](apps/woocommerce/README.md) |
| **Zen Cart** | `2.2.2` | `2` | Classic Open-Source Shopping Cart (PlugnPay Ready) | [App Readme](apps/zencart/README.md) |

### Community

*3 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Flarum** | `latest` | `2` | Modern PHP / Composer Discussion Forum | [App Readme](apps/flarum/README.md) |
| **MyBB** | `1.8.41` | `2` | Modern PHP / MariaDB Discussion Board & Forum | [App Readme](apps/mybb/README.md) |
| **phpBB** | `3.3.13` | `2` | Classic PHP / MariaDB Bulletin Board Forum | [App Readme](apps/phpbb/README.md) |

### Database

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Adminer** | `4.8.1` | `2` | Lightweight Database Management Tool (Single-File PHP) | [App Readme](apps/adminer/README.md) |
| **phpMyAdmin** | `5.2.1` | `2` | Web-Based MySQL/MariaDB Database Administration | [App Readme](apps/phpmyadmin/README.md) |

### Development

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Forgejo** | `17.0.1` | `2` | Standalone Go Binary + Systemd + Git Reverse Proxy | [App Readme](apps/forgejo/README.md) |
| **IT-Tools** | `2024.10.22` | `2` | Standalone Web Developer & Sysadmin Utilities | [App Readme](apps/it_tools/README.md) |

### Documents

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Paperless-ngx** | `3.5.0` | `2` | Document Archiving, Indexing & OCR (Container + Systemd) | [App Readme](apps/paperless_ngx/README.md) |

### Education

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Chamilo** | `3.0.2` | `2` | Enterprise Open-Source E-Learning Platform (PHP / MariaDB) | [App Readme](apps/chamilo/README.md) |
| **Moodle** | `4.4.4` | `2` | Leading Learning Management System (LMS) | [App Readme](apps/moodle/README.md) |

### Email

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Roundcube** | `1.6.9` | `2` | Modern Webmail Platform + IMAP/SMTP Integration | [App Readme](apps/roundcube/README.md) |
| **SnappyMail** | `3.0.1` | `2` | Fast, Modern Webmail Client (Zero Database / IMAP / SMTP) | [App Readme](apps/snappymail/README.md) |

### Finance

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Firefly III** | `6.7.9` | `2` | Personal Finances, Budget & Expense Manager | [App Readme](apps/firefly_iii/README.md) |

### Knowledge

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Trilium Notes** | `0.95.0` | `2` | Standalone Node.js Daemon + WebSocket Reverse Proxy | [App Readme](apps/trilium/README.md) |

### Media

*3 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Lychee** | `7.13.0` | `2` | Self-Hosted Photo Management & Gallery Platform | [App Readme](apps/lychee/README.md) |
| **Navidrome** | `0.64.2` | `2` | Subsonic Modern Music Streaming Server (Go Binary + Systemd) | [App Readme](apps/navidrome/README.md) |
| **Piwigo** | `16.5.0` | `2` | PHP / MariaDB Photo Gallery & Digital Asset Management | [App Readme](apps/piwigo/README.md) |

### News

*2 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **FreshRSS** | `1.24.3` | `2` | Self-Hosted RSS/Atom Feed Reader & Aggregator | [App Readme](apps/freshrss/README.md) |
| **Miniflux** | `2.3.5` | `2` | Minimalist Feed Reader (Go Binary + PostgreSQL + Systemd) | [App Readme](apps/miniflux/README.md) |

### Project

*4 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Kanboard** | `1.2.40` | `2` | Minimalist Visual Kanban Project Management | [App Readme](apps/kanboard/README.md) |
| **Leantime** | `3.4.6` | `2` | Strategic & Agile Project Management (Kanban, Milestones) | [App Readme](apps/leantime/README.md) |
| **MantisBT** | `2.28.4` | `2` | Web-Based Issue & Bug Tracking System (PHP / MariaDB) | [App Readme](apps/mantisbt/README.md) |
| **Vikunja** | `2.8.0` | `2` | To-Do & Task Management + Kanban/Gantt (Go Binary + Systemd) | [App Readme](apps/vikunja/README.md) |

### Security

*3 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Passbolt** | `5.18.0` | `2` | Open-Source Team Password & Secret Manager | [App Readme](apps/passbolt/README.md) |
| **PrivateBin** | `2.1.1` | `2` | Zero-Knowledge Encrypted Pastebin (Client-Side AES) | [App Readme](apps/privatebin/README.md) |
| **Vaultwarden** | `1.32.7` | `2` | Rust Daemon + Systemd + SSL Reverse Proxy + WebSockets | [App Readme](apps/vaultwarden/README.md) |

### Surveys

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **LimeSurvey** | `6.17.19` | `2` | Enterprise Online Survey & Questionnaires Platform | [App Readme](apps/limesurvey/README.md) |

### Sync

*1 Application*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Baikal** | `0.13.0` | `2` | Lightweight CalDAV & CardDAV Contacts/Calendar Sync | [App Readme](apps/baikal/README.md) |

### System & DNS

*6 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **AdGuard Home** | `0.107.80` | `2` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](apps/adguard_home/README.md) |
| **File Browser** | `2.30.0` | `2` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](apps/filebrowser/README.md) |
| **Gotify** | `3.1.1` | `2` | Real-Time Push Notification Server (Go Binary + WebSockets) | [App Readme](apps/gotify/README.md) |
| **Netdata** | `latest` | `2` | Real-Time Metrics & Observability Daemon + Reverse Proxy | [App Readme](apps/netdata/README.md) |
| **Pi-hole** | `latest` | `2` | Containerized Daemon + Systemd + Web Reverse Proxy | [App Readme](apps/pihole/README.md) |
| **Uptime Kuma** | `latest` | `2` | Node.js Daemon + Systemd + WebSocket Reverse Proxy | [App Readme](apps/uptime_kuma/README.md) |

### Utilities

*6 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **CyberChef** | `11.5.0` | `2` | Client-Side Cyber Security Swiss Army Knife | [App Readme](apps/cyberchef/README.md) |
| **LinkStack** | `4.8.8` | `2` | Open-Source Linktree Alternative & Bio Link Hub (PHP) | [App Readme](apps/linkstack/README.md) |
| **Microbin** | `2.1.0` | `2` | Lightweight Encrypted Pastebin & File Sharing (Rust Binary) | [App Readme](apps/microbin/README.md) |
| **Shaarli** | `0.16.10` | `2` | Personal Minimalist Bookmarking & Link Sharing | [App Readme](apps/shaarli/README.md) |
| **Wallabag** | `2.6.17` | `2` | Self-Hosted Read-It-Later & Article Archiver (PHP / MariaDB) | [App Readme](apps/wallabag/README.md) |
| **YOURLS** | `1.10.6` | `2` | Your Own URL Shortener with Click Analytics & API | [App Readme](apps/yourls/README.md) |

### Wiki

*3 Applications*

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **BookStack** | `24.05.4` | `2` | Laravel / PHP / MariaDB + Automated Migrations | [App Readme](apps/bookstack/README.md) |
| **DokuWiki** | `2026-07-14c` | `2` | Standards-Compliant Flat-File Wiki (Zero Database) | [App Readme](apps/dokuwiki/README.md) |
| **MediaWiki** | `1.42.3` | `2` | PHP / MariaDB + Automated CLI Installer (Pro Equivalent) | [App Readme](apps/mediawiki/README.md) |

> **Module Build Number Policy**: The `Build` number tracks the revision of our Virtualmin installer module independently of the upstream application version. Every time an installer script or service configuration is updated, its build number is incremented by 1 so server administrators can easily track changes and verify version freshness via `./setup.sh list`.

*For detailed technical specifications of each app, see the [Applications Reference Manual](docs/APPLICATIONS.md). For planned features, see [ROADMAP.md](ROADMAP.md).*

---

## Documentation Library

* **[Applications Reference Manual](docs/APPLICATIONS.md)**: Full runtime, database, storage directory, port, and systemd service profiles for all 69 applications.
* **[Installation Guide](docs/INSTALLATION.md)**: Automated CLI installation and manual Webmin GUI registration instructions.
* **[Upgrades & Maintenance Guide](docs/UPGRADE_GUIDE.md)**: Managing repository updates (`setup.sh update`), Virtualmin GUI upgrades, and automated cron checking.
* **[E-Commerce & PlugnPay Integration Guide](docs/ECOMMERCE_GUIDE.md)**: Store setup and PlugnPay payment gateway module configuration.
* **[Developer Guide](docs/DEVELOPER_GUIDE.md)**: Virtualmin install script API hooks, coding conventions, and module build tracking.
* **[Contributing Guidelines](CONTRIBUTING.md)**: Standards for adding new web apps, code reviews, and building modules.
* **[Security Policy](SECURITY.md)**: Vulnerability disclosure procedure, response SLAs, and PCI DSS compliance details.
* **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)**: Resolving port conflicts, SELinux policies, Apache/Nginx reverse proxying, and DNS port 53 allocation.
* **[Changelog](CHANGELOG.md)**: Comprehensive record of all releases, version milestones, and structural updates.

---

## Quick Start Installation

Run the following commands on your Virtualmin server as `root` (or with `sudo`):

```bash
# 1. Clone the repository (HTTPS recommended)
git clone https://github.com/turajbjt/virtualminWebApps.git /opt/virtualminWebApps
cd /opt/virtualminWebApps

# (Or clone via SSH if you have authorized SSH keys configured)
# git clone git@github.com:turajbjt/virtualminWebApps.git /opt/virtualminWebApps

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
