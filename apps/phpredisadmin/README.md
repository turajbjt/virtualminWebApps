# phpRedisAdmin for Virtualmin

**phpRedisAdmin** is a simple, lightweight web-based management interface for Redis databases written in PHP. It allows administrators to inspect keys, view string and hash structures, inspect lists and sets, monitor server metrics, and execute Redis commands directly from the browser.

---

## Features

- **Key Inspection & Search**: Search and filter keys across multiple Redis databases.
- **Data Structure Support**: View and manipulate Strings, Hashes, Lists, Sets, and Sorted Sets.
- **Server Information & Stats**: Real-time memory consumption, connected clients, uptime, and command stats.
- **Zero Daemon Overhead**: Native PHP script served directly by Apache/Nginx and PHP-FPM without external daemons.

---

## Virtualmin Integration

- **Script Name**: `phpredisadmin.pl`
- **Category**: Database
- **Runtime**: PHP (8.0 - 8.3)
- **Database**: Local or remote Redis instance
- **Configuration**: `includes/config.inc.php` secured with restricted permissions (`0600`).

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **phpRedisAdmin** from the catalog.
3. Choose the target subdirectory (default: `/redis`).
4. Access `https://yourdomain.com/redis/` to view your Redis server.
