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

### Key Capabilities
* **Isolated Daemons & Microservices**: Deploy modern Go, Rust, and Node services (Vaultwarden, AdGuard Home, Pi-hole) running as isolated systemd services behind automated Apache or Nginx reverse proxies with automatic WebSocket forwarding.
* **Open E-Commerce (PlugnPay Ready)**: Deploy top open-source shopping carts (OpenCart, PrestaShop, Thirty Bees, AbanteCart) pre-configured and ready for payment gateway integration.
* **Private Cloud & Collaboration**: Deploy enterprise cloud storage platforms (Nextcloud, ownCloud Classic) with automated database provisioning and cron job scheduling.
* **Single-Command Server Setup**: An all-in-one CLI tool (`setup.sh`) connects, updates, tests, and uninstalls the suite with a single command.

---

## Available Web Applications

| Application | Category | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Vaultwarden** | Security | `1.32.7` | `1` | Rust Daemon + Systemd + SSL Reverse Proxy + WebSockets | [App Readme](apps/vaultwarden/README.md) |
| **AdGuard Home** | System / DNS | `0.107.80` | `1` | Standalone Go Binary + Systemd + Web Reverse Proxy | [App Readme](apps/adguard_home/README.md) |
| **Pi-hole** | System / DNS | `latest` | `1` | Containerized Daemon + Systemd + Web Reverse Proxy | [App Readme](apps/pihole/README.md) |
| **Uptime Kuma** | System | `latest` | `1` | Node.js Daemon + Systemd + WebSocket Reverse Proxy | [App Readme](apps/uptime_kuma/README.md) |
| **Nextcloud** | Cloud | `30.0.6` | `1` | PHP 8.1+ / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/nextcloud/README.md) |
| **ownCloud** | Cloud | `10.13.4` | `1` | PHP / MariaDB + `occ` CLI Automated Installer | [App Readme](apps/owncloud/README.md) |
| **Matomo** | Analytics | `5.1.2` | `1` | PHP / MariaDB + Automated Archiving Cron (Pro Equivalent) | [App Readme](apps/matomo/README.md) |
| **WooCommerce** | Commerce | `latest` | `1` | WordPress + WP-CLI Automated Bundle (PlugnPay Ready) | [App Readme](apps/woocommerce/README.md) |
| **OpenCart** | Commerce | `4.0.2.3` | `1` | PHP / MariaDB + CLI Installer (PlugnPay Ready) | [App Readme](apps/opencart/README.md) |
| **PrestaShop** | Commerce | `8.1.7` | `1` | PHP / MariaDB + `index_cli.php` Installer (PlugnPay Ready) | [App Readme](apps/prestashop/README.md) |
| **Thirty Bees** | Commerce | `1.7.0` | `1` | High-Performance PrestaShop 1.6 Fork (PlugnPay Ready) | [App Readme](apps/thirtybees/README.md) |
| **AbanteCart** | Commerce | `1.4.1` | `1` | Modular PHP / MariaDB Shopping Cart (PlugnPay Ready) | [App Readme](apps/abantecart/README.md) |
| **FOSSBilling** | Commerce | `0.6.22` | `1` | BoxBilling Successor, Hosting & Carts (PlugnPay Ready) | [App Readme](apps/fossbilling/README.md) |
| **Zen Cart** | Commerce | `2.2.2` | `1` | Classic Open-Source Shopping Cart (PlugnPay Ready) | [App Readme](apps/zencart/README.md) |
| **LiteCart** | Commerce | `2.5.5` | `1` | Lightweight High-Speed PHP Cart (PlugnPay Ready) | [App Readme](apps/litecart/README.md) |
| **CubeCart** | Commerce | `6.5.7` | `1` | Full-Featured PHP E-Commerce Platform (PlugnPay Ready) | [App Readme](apps/cubecart/README.md) |

> **Module Build Number Policy**: The `Build` number tracks the revision of our Virtualmin installer module independently of the upstream application version. Every time an installer script or service configuration is updated, its build number is incremented by 1 so server administrators can easily track changes and verify version freshness via `./setup.sh list`.

*For the complete roadmap of upcoming applications (MediaWiki, Matomo, Uptime Kuma, Forgejo, WooCommerce, etc.), see [ROADMAP.md](ROADMAP.md).*

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
