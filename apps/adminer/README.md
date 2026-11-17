# Adminer Database Manager for Virtualmin

**Adminer** (formerly phpMinAdmin) is a full-featured, lightweight database management tool written in PHP. Unlike heavyweight alternatives like phpMyAdmin, Adminer consists of a single optimized PHP file ready to deploy instantly.

---

## Features

- **Multi-Engine Support**: Seamlessly connect to MySQL, MariaDB, PostgreSQL, SQLite, MS SQL, Oracle, and Elasticsearch.
- **Superior Performance**: Fast loading times and low memory consumption.
- **Robust Security**: No long-term background state, strict CSRF validation, and brute-force protection.
- **Full Database Control**: Create, drop, alter, and browse tables, indexes, foreign keys, views, stored procedures, and triggers.
- **Export & Import**: Export table structures and data to SQL or CSV, and execute SQL commands directly.

---

## Virtualmin Integration

- **Script Name**: `adminer.pl`
- **Category**: Database
- **Runtime**: PHP 7.4+ / 8.x
- **Database**: Connects to Virtualmin MariaDB / PostgreSQL
- **Document Root**: Single-file deployment under domain's `public_html/adminer/index.php`

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Adminer** from the catalog.
3. Choose the target subdirectory (default `/adminer`).
4. Access the web interface at `https://yourdomain.com/adminer/`.
5. Sign in using your Virtualmin MySQL/MariaDB database credentials (server: `localhost`).
