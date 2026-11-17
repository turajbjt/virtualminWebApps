# YOURLS URL Shortener for Virtualmin

**YOURLS** (Your Own URL Shortener) is a small, versatile, and powerful open-source URL shortening service written in PHP and MySQL. It gives you 100% control over your short links, click analytics, and branding.

---

## Features

- **Full Privacy & Ownership**: Complete control over your short domain, links, and redirection rules.
- **Detailed Click Analytics**: Historical click tracking, referrers, geographic locations, and visitor browsers.
- **Developer API**: Comprehensive REST API to shorten links programmatically from bots, apps, and command-line tools.
- **Plugin Architecture**: Dozens of community plugins available (QR code generators, LDAP auth, custom slugs).
- **Public or Private**: Run as an exclusive internal tool or open shortener.

---

## Virtualmin Integration

- **Script Name**: `yourls.pl`
- **Category**: Utilities
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB
- **Document Root**: Can run directly in domain root `/` (ideal for short domains like `sho.rt/xyz`) or a subdirectory.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **YOURLS** from the catalog.
3. Choose the target subdirectory (empty for root `/` or enter `/s`).
4. Virtualmin provisions the MariaDB database and automatically configures `user/config.php` with credentials and site URLs.
5. Visit `https://yourdomain.com/admin/` to initialize database tables.
