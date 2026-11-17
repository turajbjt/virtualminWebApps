# E-Commerce & PlugnPay Integration Guide

This guide explains how to install open-source shopping carts via the **Virtualmin Web Apps Suite** and connect them to the **PlugnPay Payment Gateway**.

---

## 1. Supported Shopping Carts

| Platform | Category | Integration Method | PlugnPay Module Repo |
| :--- | :--- | :--- | :--- |
| **WooCommerce** | WordPress E-Commerce | WP Plugin | `PlugnPay/shopping-cart-WooCommerce` |
| **OpenCart** | Full E-Commerce | Native Extension | `PlugnPay/shopping-cart-OpenCart` |
| **PrestaShop** | Full E-Commerce | Payment Module | `PlugnPay/shopping-cart-PrestaShop` |
| **Thirty Bees** | High Performance Cart | PrestaShop 1.6 Module | `PlugnPay/shopping-cart-PrestaShop` / `ThirtyBees` |
| **AbanteCart** | Modular E-Commerce | Extension Archive | `PlugnPay/shopping-cart-AbanteCart` |
| **FOSSBilling** | Hosting & Digital Billing | Gateway Extension | `PlugnPay/shopping-cart-BoxBilling` |
| **Zen Cart** | Classic Open Source | Payment Module | Classic PlugnPay Gateway |
| **LiteCart** | Modern Lightweight Cart | Payment Module | Standard Payment Gateway |
| **CubeCart** | Feature-Rich Cart | Gateway Module | Standard Payment Gateway |

---

## 2. Installing Shopping Carts in Virtualmin

1. Ensure the target Virtual Server has **PHP** and **MySQL/MariaDB** features enabled.
2. In Virtualmin, navigate to:
   **[Domain] -> Manage Web Apps / Install Scripts -> Available Scripts**
3. Select your desired shopping cart (e.g. **OpenCart**, **PrestaShop**, **Thirty Bees**, or **AbanteCart**).
4. Select the target directory (e.g. `shop` for `https://example.com/shop/` or leave empty for root domain).
5. Enter shop details and administrator password.
6. Click **Install Now**.
   * Virtualmin will automatically download the release, create the database tables, configure the administrator account, and set proper file permissions.

---

## 3. Integrating PlugnPay Payment Gateway

Once your store is installed, follow these instructions to install the PlugnPay payment gateway extension:

### OpenCart
1. Download the latest release from the [PlugnPay OpenCart Module Repository](https://github.com/PlugnPay/shopping-cart-OpenCart).
2. Log into your OpenCart Admin Dashboard (`https://example.com/admin/`).
3. Navigate to **Extensions -> Installer** and upload the PlugnPay `.ocmod.zip` extension.
4. Go to **Extensions -> Modifications** and click the **Refresh** button.
5. Go to **Extensions -> Extensions -> Payments** and find **PlugnPay**.
6. Click **Edit** and configure:
   * **Merchant Account Name**: Your PlugnPay account username.
   * **Publishable / Secret Key**: Provided in your PlugnPay merchant portal.
   * **Transaction Mode**: Authorize & Capture or Authorization only.
   * **Status**: Enabled.

---

### PrestaShop & Thirty Bees
1. Download the module archive from [PlugnPay PrestaShop Module](https://github.com/PlugnPay/shopping-cart-PrestaShop).
2. Log into the PrestaShop / Thirty Bees Back Office (`https://example.com/admin...`).
3. Navigate to **Modules -> Module Manager** (or **Modules & Services**).
4. Click **Upload a module** and select the PlugnPay zip file.
5. Click **Configure** next to the installed PlugnPay module.
6. Enter your PlugnPay credentials and payment options, then click **Save**.

---

### AbanteCart
1. Download the extension from [PlugnPay AbanteCart Module](https://github.com/PlugnPay/shopping-cart-AbanteCart).
2. Log into the AbanteCart Control Panel.
3. Navigate to **Extensions -> Extension Installer**.
4. Upload and activate the extension.
5. Under **Extensions -> Payments**, configure your PlugnPay merchant settings.

---

## 4. Security & Compliance Checklist

* **SSL/TLS Certificates**: Modern e-commerce mandates HTTPS. Always enable Let's Encrypt SSL certificates in Virtualmin (**Server Configuration -> SSL Certificate -> Let's Encrypt**).
* **PHP OPcache**: For maximum checkout performance, enable OPcache in Virtualmin's PHP Configuration.
* **Cron Jobs**: Ensure order synchronization, currency updates, and inventory crons run under the virtual server's owner account.
