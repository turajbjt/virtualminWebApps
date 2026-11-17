# ownCloud Classic for Virtualmin

[ownCloud](https://owncloud.com/) is a private cloud solution for storing, syncing, and sharing files across devices.

## Features in this Virtualmin Module
* **Automated Setup via `occ`**: Automatically handles database setup, tables, admin user, and security configurations.
* **External Data Storage**: Safely places user data in `/home/<domain>/owncloud-data` outside the document root.
* **Trusted Domains**: Automatically whitelists the domain for clean access.
* **Full Integration**: Works with standard Virtualmin PHP-FPM / FCGId and MariaDB/MySQL configurations.
