# Commerce Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Open-source shopping carts, storefront engines, and PlugnPay payment gateway-ready platforms.

This classification includes **10 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **AbanteCart** | `1.4.1` | `2` | Modular PHP / MariaDB Shopping Cart (PlugnPay Ready) | [App Readme](../../apps/abantecart/README.md) |
| **CubeCart** | `6.5.7` | `2` | Full-Featured PHP E-Commerce Platform (PlugnPay Ready) | [App Readme](../../apps/cubecart/README.md) |
| **FOSSBilling** | `0.6.22` | `2` | BoxBilling Successor, Hosting & Carts (PlugnPay Ready) | [App Readme](../../apps/fossbilling/README.md) |
| **LiteCart** | `2.5.5` | `2` | Lightweight High-Speed PHP Cart (PlugnPay Ready) | [App Readme](../../apps/litecart/README.md) |
| **OpenCart** | `4.0.2.3` | `2` | PHP / MariaDB + CLI Installer (PlugnPay Ready) | [App Readme](../../apps/opencart/README.md) |
| **osCommerce** | `4.14` | `2` | Classic & Pioneer Shopping Cart Platform (PlugnPay Ready) | [App Readme](../../apps/oscommerce/README.md) |
| **PrestaShop** | `8.1.7` | `2` | PHP / MariaDB + `index_cli.php` Installer (PlugnPay Ready) | [App Readme](../../apps/prestashop/README.md) |
| **Thirty Bees** | `1.7.0` | `2` | High-Performance PrestaShop 1.6 Fork (PlugnPay Ready) | [App Readme](../../apps/thirtybees/README.md) |
| **WooCommerce** | `latest` | `2` | WordPress + WP-CLI Automated Bundle (PlugnPay Ready) | [App Readme](../../apps/woocommerce/README.md) |
| **Zen Cart** | `2.2.2` | `2` | Classic Open-Source Shopping Cart (PlugnPay Ready) | [App Readme](../../apps/zencart/README.md) |

---

## Technical Details

### AbanteCart

* **Category**: Commerce
* **Version**: `1.4.1` | **Build**: `2`
* **Upstream**: [https://www.abantecart.com](https://www.abantecart.com)
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-AbanteCart`.


### CubeCart

* **Category**: Commerce
* **Version**: `6.5.7` | **Build**: `2`
* **Upstream**: [https://www.cubecart.com](https://www.cubecart.com)
* **Architecture**: Full-featured PHP/MariaDB shopping cart with pre-configured database parameters.


### FOSSBilling

* **Category**: Commerce / Billing
* **Version**: `0.6.22` | **Build**: `2`
* **Upstream**: [https://fossbilling.org](https://fossbilling.org)
* **Architecture**: Modern BoxBilling successor with automated background cron scheduling.
* **PlugnPay Ready**: Compatible with BoxBilling payment integrations (`PlugnPay/shopping-cart-BoxBilling`).


### LiteCart

* **Category**: Commerce
* **Version**: `2.5.5` | **Build**: `2`
* **Upstream**: [https://www.litecart.net](https://www.litecart.net)
* **Architecture**: Ultra-lightweight PHP/MariaDB shopping cart without heavy frameworks.


### OpenCart

* **Category**: Commerce
* **Version**: `4.0.2.3` | **Build**: `2`
* **Upstream**: [https://www.opencart.com](https://www.opencart.com)
* **Installation**: Automated via `install/cli_install.php` with automatic post-install cleanup of `install/`.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-OpenCart`.


### osCommerce

* **Category**: Commerce
* **Version**: `4.14` | **Build**: `2`
* **Upstream**: [https://www.oscommerce.com](https://www.oscommerce.com)
* **Architecture**: Classic & pioneer PHP open-source shopping cart with full PlugnPay payment gateway module support.
* **Database**: MariaDB / MySQL.


### PrestaShop

* **Category**: Commerce
* **Version**: `8.1.7` | **Build**: `2`
* **Upstream**: [https://www.prestashop.com](https://www.prestashop.com)
* **Installation**: Automated via `install/index_cli.php`.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-PrestaShop`.


### Thirty Bees

* **Category**: Commerce
* **Version**: `1.7.0` | **Build**: `2`
* **Upstream**: [https://thirtybees.com](https://thirtybees.com)
* **Architecture**: High-performance fork of PrestaShop 1.6 with automated CLI setup.
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-PrestaShop` / `ThirtyBees`.


### WooCommerce

* **Category**: Commerce
* **Version**: `latest` | **Build**: `2`
* **Upstream**: [https://woocommerce.com](https://woocommerce.com)
* **Architecture**: WordPress core with WooCommerce plugin.
* **Installation**: Automated via WP-CLI (`wp core download`, `wp config create`, `wp core install`, `wp plugin install woocommerce --activate`).
* **PlugnPay Ready**: Fully supported by `PlugnPay/shopping-cart-WooCommerce`.


### Zen Cart

* **Category**: Commerce
* **Version**: `2.2.2` | **Build**: `2`
* **Upstream**: [https://www.zen-cart.com](https://www.zen-cart.com)
* **Architecture**: Classic PHP/MariaDB shopping cart with pre-configured database parameters.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
