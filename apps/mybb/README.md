# MyBB Discussion Board for Virtualmin

**MyBB** (formerly MyBulletinBoard) is a free and open-source forum software package. Engineered for ease of use, security, and extensibility, MyBB powers online communities ranging from small hobbyist groups to massive enterprise support forums.

---

## Features

- **Intuitive Community Engine**: Threads, multi-quote replies, polls, ratings, and subscriptions.
- **Granular Moderation**: Inline moderation, moderation queues, warnings, and comprehensive audit logs.
- **Reputation & Badging**: Built-in member reputation system and user promotions.
- **Plugin & Theme Ecosystem**: Extensive library of community-authored plugins and themes.
- **Search Engine Optimization**: Clean URLs and rich metadata out of the box.

---

## Virtualmin Integration

- **Script Name**: `mybb.pl`
- **Category**: Community
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/forum` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **MyBB** from the catalog.
3. Choose the target subdirectory (default `/forum` or root `/`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Complete the installation wizard at `https://yourdomain.com/forum/install/`.
6. Once installation completes, Virtualmin or the admin removes the `install/` directory for security.
