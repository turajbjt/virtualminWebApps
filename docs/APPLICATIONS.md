# Applications Reference Manual

A comprehensive technical reference for all 69 web application installers provided by the **Virtualmin Web Apps Suite**.

---

## Quick Reference Index

| Application | Category | Runtime / Stack | DB Type | Default Port | Storage Location | Systemd Service |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Vaultwarden** | Security | Rust / Container | SQLite | `8000` | `~/vaultwarden-data/` | `vaultwarden-<dom>.service` |
| **AdGuard Home** | System / DNS | Standalone Go Binary | Embedded | `3000` (Web), `53` (DNS) | `~/adguard-home/` | `adguard-home-<dom>.service` |
| **Pi-hole** | System / DNS | Container Daemon | SQLite | `8080` (Web), `53` (DNS) | `~/pihole-data/` | `pihole-<dom>.service` |
| **Uptime Kuma** | System | Node.js / Container | SQLite | `3001` | `~/uptime-kuma-data/` | `uptime-kuma-<dom>.service` |
| **File Browser** | System | Standalone Go Binary | BoltDB | `8085` | `~/filebrowser/` | `filebrowser-<dom>.service` |
| **Forgejo** | Development | Standalone Go Binary | MariaDB | `3000` (Web), `2222` (SSH) | `~/forgejo/` | `forgejo-<dom>.service` |
| **Nextcloud** | Cloud | PHP 8.1+ / Apache/Nginx | MariaDB | Webserver | `~/public_html/`, `~/nextcloud-data/` | PHP-FPM / Webserver |
| **ownCloud** | Cloud | PHP 7.4-8.2 / Webserver | MariaDB | Webserver | `~/public_html/`, `~/owncloud-data/` | PHP-FPM / Webserver |
| **MediaWiki** | Wiki | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **BookStack** | Wiki | Laravel PHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Matomo** | Analytics | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Flarum** | Community | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Dolibarr** | Business | PHP 7.4-8.2 / Webserver | MariaDB | Webserver | `~/public_html/<dir>/`, `~/dolibarr-documents/` | PHP-FPM / Webserver |
| **WooCommerce** | Commerce | WordPress / PHP | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **OpenCart** | Commerce | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **PrestaShop** | Commerce | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Thirty Bees** | Commerce | PHP 7.4-8.2 / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **AbanteCart** | Commerce | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **FOSSBilling** | Commerce | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Zen Cart** | Commerce | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **LiteCart** | Commerce | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **CubeCart** | Commerce | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Invoice Ninja** | Business | Laravel PHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Ghost** | Blog | Node.js / Container | MariaDB | `2368` | `~/ghost-content/` | `ghost-<dom>.service` |
| **Drupal** | CMS | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Joomla!** | CMS | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **phpBB** | Community | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Umami** | Analytics | Node.js / Container | MariaDB | `3000` | `~/umami-data/` | `umami-<dom>.service` |
| **osCommerce** | Commerce | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **SuiteCRM** | Business | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Moodle** | Education | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/`, `~/moodledata/` | PHP-FPM / Webserver |
| **Passbolt** | Security | CakePHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **CyberChef** | Utilities | Client-Side HTML5 / JS | None | Webserver | `~/public_html/<dir>/` | Webserver Static |
| **IT-Tools** | Development | Client-Side Vue / Vite | None | Webserver | `~/public_html/<dir>/` | Webserver Static |
| **Roundcube** | Email | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **phpMyAdmin** | Database | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **PrivateBin** | Security | PHP 8.0+ / Webserver | Filesystem | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Kanboard** | Project | PHP 8.0+ / Webserver | SQLite / MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Trilium Notes** | Knowledge | Standalone Node.js Binary | SQLite | `8080` | `~/trilium-data/` | `trilium-<dom>.service` |
| **Netdata** | System | Container Daemon | Embedded | `19999` | `~/netdata-config/` | `netdata-<dom>.service` |
| **FreshRSS** | News | PHP 8.0+ / Webserver | MariaDB / SQLite | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Shaarli** | Utilities | PHP 8.0+ / Webserver | Filesystem | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Lychee** | Media | Laravel PHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Baikal** | Sync | PHP 8.0+ / Webserver | SQLite / MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Grav** | CMS | Flat-File PHP / Webserver | None | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Firefly III** | Finance | Laravel PHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **SnappyMail** | Email | PHP 8.0+ / Webserver | Filesystem | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Piwigo** | Media | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **LimeSurvey** | Surveys | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **MyBB** | Community | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **MantisBT** | Project | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Wallabag** | Utilities | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **DokuWiki** | Wiki | PHP 8.0+ / Webserver | Filesystem | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Adminer** | Database | PHP 7.4+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **YOURLS** | Utilities | PHP 8.0+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **EspoCRM** | Business | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **InvoicePlane** | Business | PHP 7.4+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Leantime** | Project | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Chamilo** | Education | PHP 8.1+ / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **LinkStack** | Utilities | PHP 8.1+ / Webserver | SQLite / MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Vikunja** | Project | Standalone Go Binary | SQLite | `3456` | `~/vikunja/` | `vikunja-<dom>.service` |
| **Gotify** | System | Standalone Go Binary | SQLite | `8088` | `~/gotify/` | `gotify-<dom>.service` |
| **Miniflux** | News | Standalone Go Binary | PostgreSQL | `8089` | `~/miniflux/` | `miniflux-<dom>.service` |
| **Microbin** | Utilities | Standalone Rust Binary | Filesystem | `8087` | `~/microbin/` | `microbin-<dom>.service` |
| **Navidrome** | Media | Standalone Go Binary | SQLite | `4533` | `~/navidrome/data/`, `~/music/` | `navidrome-<dom>.service` |
| **FlatPress** | Blog | Flat-File PHP / Webserver | None | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Monica PRM** | Business | Laravel PHP / Webserver | MariaDB | Webserver | `~/public_html/<dir>/` | PHP-FPM / Webserver |
| **Mattermost** | Chat | Standalone Go Binary | MariaDB | `8065` | `~/mattermost/data/` | `mattermost-<dom>.service` |
| **Paperless-ngx** | Documents | Container Daemon | SQLite | `8000` | `~/paperless/data/` | `paperless-<dom>.service` |

---

## Detailed Application Guides

### 1. Vaultwarden
* **Category**: Security
* **Version**: `1.32.7` | **Build**: `1`
* **Upstream**: [https://github.com/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)
* **Architecture**: Standalone daemon or rootless container managed by systemd, listening on `127.0.0.1:8000` and reverse-proxied by Apache/Nginx.
* **Requirements**: SSL/HTTPS enabled on the domain (Bitwarden clients enforce Web Crypto APIs).
* **Key Configuration**:
  * Environment: `/home/<domain>/vaultwarden.env`
  * Data Directory: `/home/<domain>/vaultwarden-data`
  * WebSockets: `/notifications/hub` forwarded to ws backend for instant multi-device vault synchronization.
  * Admin Portal: Accessible at `/admin` if an `ADMIN_TOKEN` is configured during setup.

---

### 2. AdGuard Home
* **Category**: System / DNS
* **Version**: `0.107.80` | **Build**: `1`
* **Upstream**: [https://adguard.com/en/adguard-home.html](https://adguard.com/en/adguard-home.html)
* **Architecture**: Standalone pre-compiled Go binary (amd64, arm64, armv7) managed by systemd (`adguard-home-<domain>.service`).
* **Ports**:
  * Web Dashboard: `127.0.0.1:3000` (automatically reverse-proxied to domain root).
  * DNS Port: `53` (TCP/UDP, configurable if local BIND or resolver uses 53).
* **Configuration**: `/home/<domain>/adguard-home/AdGuardHome.yaml`

---

### 3. Pi-hole
* **Category**: System / DNS
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://pi-hole.net](https://pi-hole.net)
* **Architecture**: Isolated container daemon (Podman or Docker) preventing conflicts with host web and DNS services.
* **Ports**:
  * Web Admin: `127.0.0.1:8080` (reverse-proxied to `https://<domain>/admin/`).
  * DNS Port: `53` (TCP/UDP).
* **Data Storage**: `/home/<domain>/pihole-data/etc-pihole` and `/etc-dnsmasq.d`.

---

### 4. Uptime Kuma
* **Category**: System
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://uptime.kuma.pet](https://uptime.kuma.pet)
* **Architecture**: High-performance Node.js service running via container and systemd.
* **Ports**: `127.0.0.1:3001` (reverse-proxied with full WebSocket / Socket.io forwarding).
* **Data Storage**: `/home/<domain>/uptime-kuma-data/`.

---

### 5. File Browser
* **Category**: System
* **Version**: `2.30.0` | **Build**: `1`
* **Upstream**: [https://filebrowser.org](https://filebrowser.org)
* **Architecture**: Single static Go binary (~15MB RAM) running as a systemd service under the domain user.
* **Default Port**: `127.0.0.1:8085` (reverse-proxied to domain root).
* **Root Directory**: Bound to `/home/<domain>` for full home directory management.
* **Default Credentials**: `admin` / `admin`.

---

### 6. Forgejo
* **Category**: Development
* **Version**: `17.0.1` | **Build**: `1`
* **Upstream**: [https://forgejo.org](https://forgejo.org)
* **Architecture**: Standalone static Go binary with MariaDB database backend and systemd unit (`forgejo-<domain>.service`).
* **Ports**:
  * HTTP Web: `127.0.0.1:3000` (reverse-proxied).
  * SSH Port: `2222` (configurable for Git over SSH).
* **Configuration**: `/home/<domain>/forgejo/custom/conf/app.ini`.
* **Repositories**: Stored in `/home/<domain>/forgejo/data/forgejo-repositories`.

---

### 7. Nextcloud
* **Category**: Cloud
* **Version**: `30.0.6` | **Build**: `1`
* **Upstream**: [https://nextcloud.com](https://nextcloud.com)
* **Architecture**: Standard PHP 8.1+ with MariaDB/MySQL.
* **Installation**: Automated via Nextcloud's `occ maintenance:install` CLI.
* **Data Directory**: `/home/<domain>/nextcloud-data` (secured outside `public_html`).
* **Cron Execution**: `*/5 * * * * php -f /path/to/cron.php` registered in domain crontab.

---

### 8. ownCloud Classic
* **Category**: Cloud
* **Version**: `10.13.4` | **Build**: `1`
* **Upstream**: [https://owncloud.com](https://owncloud.com)
* **Architecture**: PHP with MariaDB/MySQL.
* **Data Directory**: `/home/<domain>/owncloud-data` outside `public_html`.

---

### 9. MediaWiki
* **Category**: Wiki
* **Version**: `1.42.3` | **Build**: `1`
* **Upstream**: [https://www.mediawiki.org](https://www.mediawiki.org)
* **Architecture**: PHP with MariaDB/MySQL.
* **Installation**: Automated CLI installation using MediaWiki's `maintenance/run.php install` (generates `LocalSettings.php`, tables, and admin account).

---

### 10. BookStack
* **Category**: Wiki
* **Version**: `24.05.4` | **Build**: `1`
* **Upstream**: [https://www.bookstackapp.com](https://www.bookstackapp.com)
* **Architecture**: Laravel PHP with MariaDB.
* **Installation**: Automated `.env` configuration, `artisan key:generate`, and database migration execution.
* **Default Credentials**: `admin@admin.com` / `password`.

---

### 11. Matomo (Piwik Analytics)
* **Category**: Analytics
* **Version**: `5.1.2` | **Build**: `1`
* **Upstream**: [https://matomo.org](https://matomo.org)
* **Architecture**: PHP with MariaDB.
* **Configuration**: Automated `config/config.ini.php` database connection and security salt generation.
* **Archiving Cron**: `5 * * * * php console core:archive` registered in crontab for high-performance reporting.

---

### 12. Flarum
* **Category**: Community / Forums
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://flarum.org](https://flarum.org)
* **Architecture**: Modern PHP with Composer-based automated dependency deployment.

---

### 13. Dolibarr ERP & CRM
* **Category**: Business
* **Version**: `20.0.2` | **Build**: `1`
* **Upstream**: [https://www.dolibarr.org](https://www.dolibarr.org)
* **Architecture**: PHP with MariaDB.
* **Document Isolation**: Uploaded business invoices and documents stored in `/home/<domain>/dolibarr-documents` outside `public_html`.

---

### 14. WooCommerce (WordPress)
* **Category**: Commerce
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://woocommerce.com](https://woocommerce.com)
* **Architecture**: WordPress core with WooCommerce plugin.
* **Installation**: Automated via WP-CLI (`wp core download`, `wp config create`, `wp core install`, `wp plugin install woocommerce --activate`).
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-WooCommerce`.

---

### 15. OpenCart
* **Category**: Commerce
* **Version**: `4.0.2.3` | **Build**: `1`
* **Upstream**: [https://www.opencart.com](https://www.opencart.com)
* **Installation**: Automated via `install/cli_install.php` with automatic post-install cleanup of `install/`.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-OpenCart`.

---

### 16. PrestaShop
* **Category**: Commerce
* **Version**: `8.1.7` | **Build**: `1`
* **Upstream**: [https://www.prestashop.com](https://www.prestashop.com)
* **Installation**: Automated via `install/index_cli.php`.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-PrestaShop`.

---

### 17. Thirty Bees
* **Category**: Commerce
* **Version**: `1.7.0` | **Build**: `1`
* **Upstream**: [https://thirtybees.com](https://thirtybees.com)
* **Architecture**: High-performance fork of PrestaShop 1.6 with automated CLI setup.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-PrestaShop` / `ThirtyBees`.

---

### 18. AbanteCart
* **Category**: Commerce
* **Version**: `1.4.1` | **Build**: `1`
* **Upstream**: [https://www.abantecart.com](https://www.abantecart.com)
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-AbanteCart`.

---

### 19. FOSSBilling
* **Category**: Commerce / Billing
* **Version**: `0.6.22` | **Build**: `1`
* **Upstream**: [https://fossbilling.org](https://fossbilling.org)
* **Architecture**: Modern BoxBilling successor with automated background cron scheduling.
* **PlugnPay Ready**: Compatible with BoxBilling payment integrations (`PlugnPay/shopping-cart-BoxBilling`).

---

### 20. Zen Cart
* **Category**: Commerce
* **Version**: `2.2.2` | **Build**: `1`
* **Upstream**: [https://www.zen-cart.com](https://www.zen-cart.com)
* **Architecture**: Classic PHP/MariaDB shopping cart with pre-configured database parameters.

---

### 21. LiteCart
* **Category**: Commerce
* **Version**: `2.5.5` | **Build**: `1`
* **Upstream**: [https://www.litecart.net](https://www.litecart.net)
* **Architecture**: Ultra-lightweight PHP/MariaDB shopping cart without heavy frameworks.

---

### 22. CubeCart
* **Category**: Commerce
* **Version**: `6.5.7` | **Build**: `1`
* **Upstream**: [https://www.cubecart.com](https://www.cubecart.com)
* **Architecture**: Full-featured PHP/MariaDB shopping cart with pre-configured database parameters.

---

### 23. Invoice Ninja
* **Category**: Business
* **Version**: `5.10.40` | **Build**: `1`
* **Upstream**: [https://www.invoiceninja.com](https://www.invoiceninja.com)
* **Architecture**: Laravel PHP with MariaDB database.
* **Scheduler Cron**: `* * * * * php artisan schedule:run` registered in crontab for recurring invoices and reminder automation.

---

### 24. Ghost
* **Category**: Blog / Publishing
* **Version**: `5-alpine` | **Build**: `1`
* **Upstream**: [https://ghost.org](https://ghost.org)
* **Architecture**: Node.js container daemon managed by systemd (`ghost-<domain>.service`) with Apache/Nginx reverse proxying to `127.0.0.1:2368`.
* **Data Storage**: `/home/<domain>/ghost-content`.

---

### 25. Drupal
* **Category**: CMS
* **Version**: `10.3.5` | **Build**: `1`
* **Upstream**: [https://www.drupal.org](https://www.drupal.org)
* **Architecture**: Enterprise PHP/MariaDB CMS with pre-configured `sites/default/settings.php` and hash salts.

---

### 26. Joomla!
* **Category**: CMS
* **Version**: `5.1.4` | **Build**: `1`
* **Upstream**: [https://www.joomla.org](https://www.joomla.org)
* **Architecture**: Mobile-ready PHP/MariaDB CMS with automated pre-installation setup.

---

### 27. phpBB
* **Category**: Community / Forums
* **Version**: `3.3.13` | **Build**: `1`
* **Upstream**: [https://www.phpbb.com](https://www.phpbb.com)
* **Architecture**: Classic PHP/MariaDB bulletin board forum with pre-configured database parameters.

---

### 28. Umami Analytics
* **Category**: Analytics
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://umami.is](https://umami.is)
* **Architecture**: Lightweight Node.js privacy analytics daemon managed by systemd (`umami-<domain>.service`), reverse-proxied to `127.0.0.1:3000` with MariaDB backend.
* **Default Credentials**: `admin` / `umami`.

---

### 29. osCommerce
* **Category**: Commerce
* **Version**: `4.14` | **Build**: `1`
* **Upstream**: [https://www.oscommerce.com](https://www.oscommerce.com)
* **Architecture**: Classic & pioneer PHP open-source shopping cart with full PlugnPay payment gateway module support.
* **Database**: MariaDB / MySQL.

---

### 30. SuiteCRM
* **Category**: Business
* **Version**: `8.10.2` | **Build**: `1`
* **Upstream**: [https://suitecrm.com](https://suitecrm.com)
* **Architecture**: Enterprise-grade customer relationship management (CRM) application with modular business workflows and automated permissions.
* **Database**: MariaDB / MySQL.

---

### 31. Moodle
* **Category**: Education / CMS
* **Version**: `4.4.4` | **Build**: `1`
* **Upstream**: [https://moodle.org](https://moodle.org)
* **Architecture**: Global open-source Learning Management System (LMS) with isolated data directory (`$HOME/moodledata`) for hardened security.
* **Database**: MariaDB / MySQL / PostgreSQL.

---

### 32. Passbolt
* **Category**: Security
* **Version**: `5.18.0` | **Build**: `1`
* **Upstream**: [https://www.passbolt.com](https://www.passbolt.com)
* **Architecture**: Open-source team password and secret manager built on OpenPGP and CakePHP.
* **Database**: MariaDB / MySQL.

---

### 33. CyberChef
* **Category**: Utilities
* **Version**: `11.5.0` | **Build**: `1`
* **Upstream**: [https://gchq.github.io/CyberChef/](https://gchq.github.io/CyberChef/)
* **Architecture**: GCHQ's "Cyber Swiss Army Knife" — 100% client-side HTML5 & WebAssembly web app. Zero server-side runtime or database requirement.

---

### 34. IT-Tools
* **Category**: Development / Utilities
* **Version**: `2024.10.22` | **Build**: `1`
* **Upstream**: [https://it-tools.tech](https://it-tools.tech)
* **Architecture**: Client-side collection of developer utilities (token generators, regex testers, converters, formatters) served as static pre-built assets. Zero server-side compute.

---

### 35. Roundcube Webmail
* **Category**: Email
* **Version**: `1.6.9` | **Build**: `1`
* **Upstream**: [https://roundcube.net](https://roundcube.net)
* **Architecture**: Modern, browser-based multilingual IMAP webmail platform with automated MySQL schema import, random DES key generation, and local Dovecot/Postfix integration.
* **Database**: MariaDB / MySQL.

---

### 36. phpMyAdmin
* **Category**: Database
* **Version**: `5.2.1` | **Build**: `1`
* **Upstream**: [https://www.phpmyadmin.net](https://www.phpmyadmin.net)
* **Architecture**: The premier web-based MySQL/MariaDB management tool. Auto-generates a unique 32-character Blowfish encryption secret and isolated cache directory.
* **Database**: MariaDB / MySQL.

---

### 37. PrivateBin
* **Category**: Security
* **Version**: `2.1.1` | **Build**: `1`
* **Upstream**: [https://privatebin.info](https://privatebin.info)
* **Architecture**: Zero-knowledge encrypted pastebin. Data is encrypted and decrypted exclusively in the client browser using 256-bit AES-GCM.
* **Database**: Filesystem storage (`data/`).

---

### 38. Kanboard
* **Category**: Project
* **Version**: `1.2.40` | **Build**: `1`
* **Upstream**: [https://kanboard.org](https://kanboard.org)
* **Architecture**: Minimalist visual Kanban board project management tool. Uses zero-configuration SQLite backend by default or optional MariaDB.
* **Database**: SQLite / MariaDB.

---

### 39. Trilium Notes
* **Category**: Knowledge
* **Version**: `0.95.0` | **Build**: `1`
* **Upstream**: [https://triliumnotes.org](https://triliumnotes.org)
* **Architecture**: Hierarchical note-taking application powered by a self-contained Node.js server binary, running as a dedicated systemd service (`trilium-<dom>.service`) behind an automated Apache/Nginx reverse proxy with WebSocket support.
* **Storage**: `/home/<dom>/trilium-data`.

---

### 40. Netdata
* **Category**: System
* **Version**: `latest` | **Build**: `1`
* **Upstream**: [https://www.netdata.cloud](https://www.netdata.cloud)
* **Architecture**: Real-time infrastructure observability and metrics dashboard running as a containerized system daemon (`netdata-<dom>.service`), reverse-proxied to internal port 19999 with WebSocket support.

---

### 41. FreshRSS
* **Category**: News
* **Version**: `1.24.3` | **Build**: `1`
* **Upstream**: [https://freshrss.org](https://freshrss.org)
* **Architecture**: Fast, lightweight self-hosted RSS/Atom feed aggregator with multi-user accounts, full-text search, and third-party mobile client API support (Google Reader / Fever).
* **Database**: MariaDB / MySQL or SQLite.

---

### 42. Shaarli
* **Category**: Utilities
* **Version**: `0.16.10` | **Build**: `1`
* **Upstream**: [https://shaarli.readthedocs.io](https://shaarli.readthedocs.io)
* **Architecture**: Personal, minimalist, zero-SQL link sharing and bookmarking service with built-in tagging, full privacy, and flat-file storage.
* **Database**: Flat-file JSON/datastore.

---

### 43. Lychee
* **Category**: Media
* **Version**: `7.13.0` | **Build**: `1`
* **Upstream**: [https://lycheeorg.github.io](https://lycheeorg.github.io)
* **Architecture**: Self-hosted photo management system and album gallery with full EXIF inspection, public/private sharing, and responsive layouts.
* **Database**: MariaDB / MySQL.

---

### 44. Baikal
* **Category**: Sync
* **Version**: `0.13.0` | **Build**: `1`
* **Upstream**: [https://sabre.io/baikal/](https://sabre.io/baikal/)
* **Architecture**: Lightweight CalDAV and CardDAV server for cross-device contacts and calendar synchronization.
* **Database**: SQLite / MariaDB.

---

### 45. Grav CMS
* **Category**: CMS
* **Version**: `2.2.30` | **Build**: `1`
* **Upstream**: [https://getgrav.org](https://getgrav.org)
* **Architecture**: Award-winning flat-file CMS with modern Twig templating, Markdown content authoring, and a pre-packaged Admin Panel.
* **Database**: Flat-file Markdown/YAML.

---

### 46. Firefly III
* **Category**: Finance
* **Version**: `6.7.9` | **Build**: `1`
* **Upstream**: [https://www.firefly-iii.org](https://www.firefly-iii.org)
* **Architecture**: Feature-rich personal finances manager supporting double-entry bookkeeping, budgeting, recurring transactions, and financial reporting.
* **Database**: MariaDB / MySQL.

---

### 47. SnappyMail
* **Category**: Email
* **Version**: `3.0.1` | **Build**: `1`
* **Upstream**: [https://snappymail.eu](https://snappymail.eu)
* **Architecture**: Ultra-fast, lightweight webmail client (modern RainLoop fork) engineered with minimal footprint, no required SQL database, OpenPGP message encryption, and full mobile optimization.
* **Database**: Filesystem / Flat-file (Zero database overhead; connects directly to Dovecot/Postfix or external IMAP/SMTP).

---

### 48. Piwigo
* **Category**: Media
* **Version**: `16.5.0` | **Build**: `1`
* **Upstream**: [https://piwigo.org](https://piwigo.org)
* **Architecture**: Mature photo gallery and digital asset management software featuring batch processing, EXIF/IPTC metadata extraction, and multi-tier privacy control.
* **Database**: MariaDB / MySQL.

---

### 49. LimeSurvey
* **Category**: Surveys
* **Version**: `6.17.19` | **Build**: `1`
* **Upstream**: [https://www.limesurvey.org](https://www.limesurvey.org)
* **Architecture**: Enterprise-grade online statistical survey and questionnaire platform supporting 30+ question types, conditional skip logic, invitation tokens, and statistical export.
* **Database**: MariaDB / MySQL.

---

### 50. MyBB
* **Category**: Community
* **Version**: `1.8.41` | **Build**: `1`
* **Upstream**: [https://mybb.com](https://mybb.com)
* **Architecture**: Free and open-source bulletin board forum software with role-based moderation queues, member reputation scoring, thread subscriptions, and plugin extensibility.
* **Database**: MariaDB / MySQL.

---

### 51. MantisBT
* **Category**: Project
* **Version**: `2.28.4` | **Build**: `1`
* **Upstream**: [https://www.mantisbt.org](https://www.mantisbt.org)
* **Architecture**: Web-based bug and issue tracking system with customizable issue workflows, role-based project access control, email notifications, and REST API support.
* **Database**: MariaDB / MySQL.

---

### 52. Wallabag
* **Category**: Utilities
* **Version**: `2.6.17` | **Build**: `1`
* **Upstream**: [https://wallabag.org](https://wallabag.org)
* **Architecture**: Self-hosted read-it-later article archiver and Pocket alternative providing distraction-free reading, offline e-reader export (EPUB, PDF, MOBI), and browser extensions.
* **Database**: MariaDB / MySQL.

---

### 53. DokuWiki
* **Category**: Wiki
* **Version**: `2026-07-14c` | **Build**: `1`
* **Upstream**: [https://www.dokuwiki.org](https://www.dokuwiki.org)
* **Architecture**: Highly versatile, standards-compliant open-source wiki operating without any SQL database; stores documents in plain text with full ACLs and revision control.
* **Database**: Filesystem / Plain Text.

---

### 54. Adminer
* **Category**: Database
* **Version**: `4.8.1` | **Build**: `1`
* **Upstream**: [https://www.adminer.org](https://www.adminer.org)
* **Architecture**: Ultra-lightweight, single-file database management tool with support for MySQL, MariaDB, PostgreSQL, SQLite, and superior performance.
* **Database**: Direct connection to Virtualmin database engines.

---

### 55. YOURLS
* **Category**: Utilities
* **Version**: `1.10.6` | **Build**: `1`
* **Upstream**: [https://yourls.org](https://yourls.org)
* **Architecture**: Robust self-hosted URL shortening service providing detailed click metrics, referrer analytics, developer REST API, and custom short links.
* **Database**: MariaDB / MySQL.

---

### 56. EspoCRM
* **Category**: Business
* **Version**: `10.1.3` | **Build**: `1`
* **Upstream**: [https://www.espocrm.com](https://www.espocrm.com)
* **Architecture**: Responsive Single Page Application (SPA) CRM platform enabling companies to manage relationships, sales opportunities, email integration, and workflow automation.
* **Database**: MariaDB / MySQL.

---

### 57. InvoicePlane
* **Category**: Business
* **Version**: `1.6.1` | **Build**: `1`
* **Upstream**: [https://invoiceplane.com](https://invoiceplane.com)
* **Architecture**: Clean open-source invoicing and client management software with quote-to-invoice conversion, PDF invoice generation, multi-currency support, and payment integration.
* **Database**: MariaDB / MySQL.

---

### 58. Leantime
* **Category**: Project
* **Version**: `3.4.6` | **Build**: `1`
* **Upstream**: [https://leantime.io](https://leantime.io)
* **Architecture**: Strategic project management system for agile teams and startups, combining Lean Canvas idea boards, Kanban sprint workflows, Gantt roadmaps, and time logging.
* **Database**: MariaDB / MySQL.

---

### 59. Chamilo LMS
* **Category**: Education
* **Version**: `3.0.2` | **Build**: `1`
* **Upstream**: [https://chamilo.org](https://chamilo.org)
* **Architecture**: Enterprise-grade open-source Learning Management System (LMS) providing comprehensive course authoring, skills management, automated testing, and virtual classrooms.
* **Database**: MariaDB / MySQL.

---

### 60. LinkStack
* **Category**: Utilities
* **Version**: `4.8.8` | **Build**: `1`
* **Upstream**: [https://linkstack.org](https://linkstack.org)
* **Architecture**: Privacy-respecting open-source link-in-bio platform and Linktree alternative featuring customizable themes, vCard downloads, and multi-user support.
* **Database**: SQLite / MariaDB.

---

### 61. Vikunja
* **Category**: Project
* **Version**: `2.8.0` | **Build**: `1`
* **Upstream**: [https://vikunja.io](https://vikunja.io)
* **Architecture**: Modern, self-hostable to-do list and task management system built in Go with an embedded web frontend, managed by systemd and reverse-proxied with SSL.
* **Database**: Embedded SQLite (or MariaDB).

---

### 62. Gotify
* **Category**: System
* **Version**: `3.1.1` | **Build**: `1`
* **Upstream**: [https://gotify.net](https://gotify.net)
* **Architecture**: Real-time push notification and messaging server in Go, featuring continuous WebSockets, REST API message dispatch, and native Android app synchronization.
* **Database**: Embedded SQLite.

---

### 63. Miniflux
* **Category**: News
* **Version**: `2.3.5` | **Build**: `1`
* **Upstream**: [https://miniflux.app](https://miniflux.app)
* **Architecture**: Minimalist, fast, and opinionated feed reader written in Go, operating as an isolated daemon reverse-proxied by Apache/Nginx with native PostgreSQL database integration.
* **Database**: PostgreSQL.

---

### 64. Microbin
* **Category**: Utilities
* **Version**: `2.1.0` | **Build**: `1`
* **Upstream**: [https://microbin.eu](https://microbin.eu)
* **Architecture**: Ultra-fast, zero-dependency encrypted pastebin and file sharing service written in Rust, featuring client-side encryption, burn-after-reading expiration, and QR code sharing.
* **Database**: Filesystem / Embedded.

---

### 65. Navidrome
* **Category**: Media
* **Version**: `0.64.2` | **Build**: `1`
* **Upstream**: [https://www.navidrome.org](https://www.navidrome.org)
* **Architecture**: Modern, lightweight music streaming server and Subsonic-compatible API backend written in Go. Operates as an isolated daemon managed by systemd and reverse-proxied by Apache or Nginx.
* **Database**: Embedded SQLite.

---

### 66. FlatPress
* **Category**: Blog
* **Version**: `1.5.1` | **Build**: `1`
* **Upstream**: [https://www.flatpress.org](https://www.flatpress.org)
* **Architecture**: Lightweight, standards-compliant blogging engine that stores posts, comments, and settings completely in flat text files with zero SQL database requirements.
* **Database**: None (Flat Files).

---

### 67. Monica PRM
* **Category**: Business
* **Version**: `4.1.2` | **Build**: `1`
* **Upstream**: [https://www.monicahq.com](https://www.monicahq.com)
* **Architecture**: Personal Relationship Management (PRM) platform built with Laravel/PHP to document interactions, milestones, contact notes, and relationships.
* **Database**: MariaDB / MySQL.

---

### 68. Mattermost
* **Category**: Chat
* **Version**: `10.5.1` | **Build**: `1`
* **Upstream**: [https://mattermost.com](https://mattermost.com)
* **Architecture**: High-performance, open-source team collaboration and messaging service written in Go. Runs as a systemd service, backed by MariaDB, and reverse-proxied with full WebSocket forwarding.
* **Database**: MariaDB / MySQL.

---

### 69. Paperless-ngx
* **Category**: Documents
* **Version**: `3.5.0` | **Build**: `1`
* **Upstream**: [https://docs.paperless-ngx.com](https://docs.paperless-ngx.com)
* **Architecture**: Automated document indexing, Optical Character Recognition (OCR), and searchable archiving platform running inside an isolated container with systemd integration and reverse proxying.
* **Database**: SQLite (or PostgreSQL via container).




