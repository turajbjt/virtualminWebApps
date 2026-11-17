# Installation & Server Setup Guide

This guide walks you through installing, configuring, and updating the **Virtualmin Web Apps Suite** on your Linux servers.

---

## 1. Prerequisites

Before installing the suite, ensure your server meets the following requirements:
* **Operating System**: Linux (Ubuntu, Debian, AlmaLinux, Rocky Linux, RHEL, CentOS, or Fedora).
* **Control Panel**: Webmin and Virtualmin (GPL or Professional) installed and operational.
* **Perl**: Perl 5.16+ installed (standard on any Webmin system).
* **Root Privileges**: `sudo` or direct root shell access to configure Webmin.

Optional dependencies for specific application types:
* **For Daemons / Containers (Vaultwarden, Pi-hole)**: Podman (`sudo apt install podman` / `sudo dnf install podman`) or Docker.
* **For PHP & E-Commerce Apps (Nextcloud, OpenCart, PrestaShop)**: PHP (8.0+) with `mysqli` / `pdo_mysql`, and MariaDB/MySQL enabled on the virtual server.

---

## 2. Automated Installation via CLI (Recommended)

1. **Clone the repository onto your server**:
   We recommend placing the repository in `/opt/virtualminWebApps` or a central system directory:
   ```bash
   git clone git@github.com:turajbjt/virtualminWebApps.git /opt/virtualminWebApps
   cd /opt/virtualminWebApps
   ```

2. **Run the installation command**:
   ```bash
   sudo ./setup.sh install
   ```

### What `setup.sh install` does:
* Discovers all application modules in `apps/` and synchronizes their `.pl` script links into `scripts/`.
* Connects `lib/` so all shared helper libraries are accessible.
* Registers `custom_scripts_dir=/opt/virtualminWebApps/scripts` in `/etc/webmin/virtual-server/config`.
* Automatically restarts Webmin so the changes take effect immediately.

---

## 3. Manual Installation (Alternative)

If you prefer configuring Virtualmin manually via the Webmin web interface:

1. Clone or download the repository to `/opt/virtualminWebApps`.
2. Generate the flat scripts directory:
   ```bash
   cd /opt/virtualminWebApps
   ./setup.sh update
   ```
3. Log into your Virtualmin web interface (`https://your-server:10000`).
4. Navigate to:
   **Virtualmin -> System Settings -> Server Configuration -> Webmin Modules -> Virtualmin Virtual Servers**
5. Locate the setting **Custom script directory** and set it to:
   ```text
   /opt/virtualminWebApps/scripts
   ```
6. Click **Save**, then restart Webmin from the top-right menu or terminal:
   ```bash
   sudo systemctl restart webmin
   ```

---

## 4. Verifying Application Availability

Once installed, check available applications from the terminal:
```bash
./setup.sh list
```

In the Virtualmin Web GUI:
1. Select any Virtual Server (e.g. `example.com`).
2. Go to **Manage Web Apps** (or **Install Scripts**).
3. Click **Available Scripts**.
4. You will see all web applications organized under their respective categories:
   * **Security & Identity**: Vaultwarden, Passbolt, PrivateBin
   * **System, Monitoring & Networking**: AdGuard Home, Pi-hole, Uptime Kuma, Netdata, Gotify
   * **Cloud & File Storage**: Nextcloud, ownCloud Classic, Filebrowser
   * **Commerce & Digital Sales**: WooCommerce, OpenCart, PrestaShop, Thirty Bees, AbanteCart, FOSSBilling, Zen Cart, osCommerce, CubeCart, LiteCart
   * **Content Management (CMS) & Blogging**: Drupal, Joomla!, Grav, Ghost, FlatPress
   * **Wikis & Knowledge Management**: MediaWiki, BookStack, DokuWiki, Trilium Notes
   * **CRM, Business & Personal Finance**: Dolibarr, SuiteCRM, EspoCRM, Invoice Ninja, InvoicePlane, Firefly III, Monica PRM
   * **Discussion Forums & Communities**: phpBB, Flarum, MyBB
   * **Project Management & Issue Tracking**: Kanboard, Leantime, Vikunja, MantisBT
   * **Developer Tools & Utilities**: Forgejo, IT-Tools, CyberChef, YOURLS, LinkStack, Shaarli, Microbin
   * **Analytics & Performance**: Matomo, Umami
   * **Education & Learning Management**: Moodle, Chamilo LMS
   * **Media, Galleries & Audio Streaming**: Lychee, Piwigo, Navidrome
   * **Communication, Team Chat & Webmail**: Roundcube, SnappyMail, Mattermost
   * **News, Feeds & Aggregation**: FreshRSS, Miniflux
   * **Document Management & Archiving**: Paperless-ngx, Wallabag
   * **Database Administration**: phpMyAdmin, Adminer
   * **Sync, Calendars & Address Books**: Baïkal

---

## 5. Updating the Suite

To pull the latest application definitions, new carts, and bug fixes:
```bash
cd /opt/virtualminWebApps
sudo ./setup.sh update
```
This automatically fetches updates from Git, updates script symlinks, and refreshes Webmin.

For complete details on upgrading already-installed applications on virtual servers via GUI or CLI, see the [Upgrades & Maintenance Guide](UPGRADE_GUIDE.md).

---

## 6. Uninstallation

If you ever wish to unregister the suite from Virtualmin:
```bash
cd /opt/virtualminWebApps
sudo ./setup.sh remove
```
* Note: Unregistering the suite removes the install scripts from the Virtualmin catalog, but **does not** delete or alter web applications already installed on virtual servers.
