# PrestaShop for Virtualmin

[PrestaShop](https://www.prestashop.com/) is an open-source e-commerce solution powering over 300,000 stores worldwide.

## Features in this Virtualmin Module
* **Automated CLI Setup**: Configures the database, administrator credentials, shop name, and base URL via PrestaShop's `install/index_cli.php`.
* **Automatic Security Cleanup**: Deletes the `install/` directory immediately following successful provisioning.
* **Flexible Subdirectory**: Install to root (`/`) or custom subfolder (`/shop/`).
