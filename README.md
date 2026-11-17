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
* **Complete E-Commerce Suite**: Deploy top open-source shopping carts (WooCommerce, OpenCart, osCommerce, PrestaShop, Thirty Bees, AbanteCart, FOSSBilling, Zen Cart, LiteCart, CubeCart) pre-configured with database wiring and automated deployment.
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

Click any classification below to view its dedicated catalog page, technical architecture, and installation guides:

| Classification | Applications | Count |
| :--- | :--- | :---: |
| [**Analytics**](docs/categories/analytics.md) | **Matomo**, **Umami** | `2` |
| [**Blog**](docs/categories/blog.md) | **FlatPress**, **Ghost** | `2` |
| [**Business**](docs/categories/business.md) | **Dolibarr**, **EspoCRM**, **Invoice Ninja**, **InvoicePlane**, **Monica PRM**, **SuiteCRM** | `6` |
| [**Chat**](docs/categories/chat.md) | **Mattermost** | `1` |
| [**Cloud**](docs/categories/cloud.md) | **Nextcloud**, **ownCloud** | `2` |
| [**CMS**](docs/categories/cms.md) | **Drupal**, **Grav**, **Joomla!** | `3` |
| [**Commerce**](docs/categories/commerce.md) | **AbanteCart**, **CubeCart**, **FOSSBilling**, **LiteCart**, **OpenCart**, **osCommerce**, **PrestaShop**, **Thirty Bees**, **WooCommerce**, **Zen Cart** | `10` |
| [**Community**](docs/categories/community.md) | **Flarum**, **MyBB**, **phpBB** | `3` |
| [**Database**](docs/categories/database.md) | **Adminer**, **phpMyAdmin** | `2` |
| [**Development**](docs/categories/development.md) | **Forgejo**, **IT-Tools** | `2` |
| [**Documents**](docs/categories/documents.md) | **Paperless-ngx** | `1` |
| [**Education**](docs/categories/education.md) | **Chamilo**, **Moodle** | `2` |
| [**Email**](docs/categories/email.md) | **Roundcube**, **SnappyMail** | `2` |
| [**Finance**](docs/categories/finance.md) | **Firefly III** | `1` |
| [**Knowledge**](docs/categories/knowledge.md) | **Trilium Notes** | `1` |
| [**Media**](docs/categories/media.md) | **Lychee**, **Navidrome**, **Piwigo** | `3` |
| [**News**](docs/categories/news.md) | **FreshRSS**, **Miniflux** | `2` |
| [**Project**](docs/categories/project.md) | **Kanboard**, **Leantime**, **MantisBT**, **Vikunja** | `4` |
| [**Security**](docs/categories/security.md) | **Passbolt**, **PrivateBin**, **Vaultwarden** | `3` |
| [**Surveys**](docs/categories/surveys.md) | **LimeSurvey** | `1` |
| [**Sync**](docs/categories/sync.md) | **Baikal** | `1` |
| [**System & DNS**](docs/categories/system-dns.md) | **AdGuard Home**, **File Browser**, **Gotify**, **Netdata**, **Pi-hole**, **Uptime Kuma** | `6` |
| [**Utilities**](docs/categories/utilities.md) | **CyberChef**, **LinkStack**, **Microbin**, **Shaarli**, **Wallabag**, **YOURLS** | `6` |
| [**Wiki**](docs/categories/wiki.md) | **BookStack**, **DokuWiki**, **MediaWiki** | `3` |
| **Total** | **24 Application Classifications** | **`69`** |

> **Module Build Number Policy**: The `Build` number tracks the revision of our Virtualmin installer module independently of the upstream application version. Every time an installer script or service configuration is updated, its build number is incremented by 1 so server administrators can easily track changes and verify version freshness via `./setup.sh list`.

*For detailed technical specifications of each app, see the [Applications Reference Manual](docs/APPLICATIONS.md). For planned features, see [ROADMAP.md](ROADMAP.md).*

---

## Documentation Library

* **[Applications Reference Manual](docs/APPLICATIONS.md)**: Full runtime, database, storage directory, port, and systemd service profiles for all 69 applications.
* **[Installation Guide](docs/INSTALLATION.md)**: Automated CLI installation and manual Webmin GUI registration instructions.
* **[Upgrades & Maintenance Guide](docs/UPGRADE_GUIDE.md)**: Managing repository updates (`setup.sh update`), Virtualmin GUI upgrades, and automated cron checking.
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
│   ├── TROUBLESHOOTING.md           # Common edge cases, port binding, and SELinux
│   └── categories/                  # 24 dedicated classification catalogs
└── scripts/                         # Flattened directory exposed to Virtualmin
    ├── lib -> ../lib
    ├── vaultwarden.pl -> ../apps/vaultwarden/vaultwarden.pl
    └── ...
```

---

## Documentation Links

* [Application Reference Manual](docs/APPLICATIONS.md): Complete technical reference for all 69 web applications, default ports, paths, database types, and services.
* [Installation Guide](docs/INSTALLATION.md): Detailed installation instructions, prerequisites, and automated vs manual setup.
* [Upgrades & Maintenance Guide](docs/UPGRADE_GUIDE.md): Complete guide to updating the suite (`setup.sh update`) and upgrading applications on virtual servers via GUI and CLI.
* [Developer Guide](docs/DEVELOPER_GUIDE.md): Complete specifications of the Virtualmin script API and how to contribute new application modules.
* [Troubleshooting Guide](docs/TROUBLESHOOTING.md): Solutions for port conflicts, SELinux policies, reverse proxies, and Web Crypto requirements.
* [Master Roadmap](ROADMAP.md): Categorized list of upcoming FOSS applications.

---

## Testing & Quality Assurance

To test that all Perl modules and application scripts have valid syntax and load shared libraries properly:

```bash
./setup.sh test
```

---

## Disclaimer & Limitation of Liability

> [!WARNING]
> **Use at Your Own Risk (YMMV — Your Mileage May Vary)**
>
> This project is free, open-source software provided strictly on an **"AS IS"** and **"AS AVAILABLE"** basis, without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, non-infringement, security, compatibility, or error-free operation.

* **No Liability for Damages**: Under no circumstances shall the authors, maintainers, contributors, or copyright holders be liable for any direct, indirect, incidental, special, exemplary, consequential, or punitive damages (including, but not limited to, loss of data, loss of revenue or profits, system downtime, business interruption, security compromises, hardware or software corruption, or costs of procurement of substitute goods or services) arising out of or related to the use, misuse, installation, operation, configuration, or inability to use this software or any third-party application provisioned by it, even if advised of the possibility of such damages.
* **Administrator Responsibility & Mandatory Backups**: Automated installers execute with system administrative and root privileges, create system users, provision databases, configure web servers, open network ports, and manage systemd units. **You are solely and exclusively responsible for inspecting all scripts, evaluating security and compatibility with your environment, testing deployments on non-production staging systems, and maintaining independent, restorable, and verified system backups prior to deploying any application to a production server.**
* **Independent Project & Trademarks**: This is an independent community project and is **not** affiliated with, endorsed by, sponsored by, or associated with Virtualmin, Inc., Webmin, or any upstream software developers, organizations, or trademarks referenced in this repository (e.g., WordPress, Nextcloud, PrestaShop, Vaultwarden, Bitwarden, etc.). All product names, registered trademarks, and logos remain the exclusive property of their respective trademark holders and are utilized solely for descriptive and identification purposes.

---

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).
See the [LICENSE](LICENSE) file for complete terms and conditions.
