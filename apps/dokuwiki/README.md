# DokuWiki Documentation Engine for Virtualmin

**DokuWiki** is a simple to use and highly versatile open-source wiki software that doesn't require a database. It is loved by developers, sysadmins, and teams for its clean and readable syntax, ease of maintenance, and built-in access controls.

---

## Features

- **No Database Required**: All data stored in standard plain text files; zero SQL overhead.
- **Built-in Authentication & ACLs**: Granular permissions per page or entire namespaces.
- **Rich Plugin Ecosystem**: Over 1,000 community plugins adding syntax highlighters, discussion tools, media managers, and themes.
- **Revision History**: Complete revision history and difference viewing for all wiki documents.
- **Lightweight & Fast**: Minimal server resource footprint and instantaneous page caching.

---

## Virtualmin Integration

- **Script Name**: `dokuwiki.pl`
- **Category**: Wiki
- **Runtime**: PHP 8.0+
- **Database**: None (flat-file Markdown/text store)
- **Document Root**: Direct execution under domain's `public_html` (or `/wiki` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **DokuWiki** from the catalog.
3. Choose the target subdirectory (default `/wiki` or root `/`).
4. Complete the initial configuration wizard at `https://yourdomain.com/wiki/install.php`.
5. Once configured, DokuWiki disables the installer file automatically for security.
