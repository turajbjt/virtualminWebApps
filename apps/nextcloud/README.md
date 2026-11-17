# Nextcloud for Virtualmin

[Nextcloud](https://nextcloud.com/) is the most deployed on-premises content collaboration platform in the world, combining productivity and real-time document editing, file sync and share, video meetings, calendars, contacts, and email.

## Features in this Virtualmin Module
* **Free, Open-Source Implementation**: Eliminates the requirement for Virtualmin Pro for Nextcloud deployments.
* **Automated Installation via `occ`**: Automatically configures the MySQL/MariaDB database, administrative user, data directories, and system paths.
* **Hardened Data Directory**: Automatically creates and permissions the data directory (`/home/<domain>/nextcloud-data`) outside of `public_html` according to security best practices.
* **Automated Cron Scheduling**: Configures background jobs via system crontab (`cron.php`) running every 5 minutes.
* **Trusted Domains**: Automatically whitelists the domain name upon setup.

## Architecture & Storage
* **Web Root**: `/home/<domain>/public_html/` (or designated subdirectory)
* **Data Directory**: `/home/<domain>/nextcloud-data/`
* **Cron Execution**: `*/5 * * * * php -f /path/to/cron.php`
* **Requirements**: PHP 8.1+ and MySQL/MariaDB enabled on the virtual server.
