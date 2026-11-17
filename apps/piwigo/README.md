# Piwigo Photo Gallery for Virtualmin

**Piwigo** is mature, open-source photo gallery software for the web. Built by an active community of photographers and web developers, it powers personal photo collections, family archives, and organizational digital asset management systems worldwide.

---

## Features

- **High-Volume Photo Management**: Organize photos into albums, sub-albums, and categories with batch processing.
- **Smart Tagging & Metadata**: Full support for EXIF and IPTC metadata extraction and search.
- **Privacy & Permissions**: Granular access control per group, user, or public visitor.
- **Extensible Architecture**: Hundreds of plugins and modern themes available via the built-in extension manager.
- **Mobile & Desktop Uploaders**: Compatible with mobile apps (iOS & Android) and desktop sync tools (Lightroom, DigiKam).

---

## Virtualmin Integration

- **Script Name**: `piwigo.pl`
- **Category**: Media
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/gallery` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Piwigo** from the catalog.
3. Choose the target subdirectory (default `/gallery` or root `/`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Visit the installation URL to create the administrative user and complete setup.
