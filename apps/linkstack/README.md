# LinkStack for Virtualmin

**LinkStack** is a modern, privacy-focused open-source alternative to Linktree and similar link-in-bio services. It enables influencers, artists, brands, and companies to host their own customizable personal landing page showcasing all social profiles, portfolios, and links on their private domain.

---

## Features

- **Custom Themes & Styling**: Over a dozen customizable themes with font, color, and background controls.
- **Privacy & Tracking**: Zero third-party ad tracking, with built-in privacy-respecting click analytics.
- **VCard & Contact Sharing**: Allow visitors to download a direct vCard file to their smartphone contacts.
- **Multi-User Capabilities**: Run as an exclusive personal page or allow team members to create individual link pages.
- **SEO & Social Cards**: Automated OpenGraph and Twitter cards for optimal social sharing previews.

---

## Virtualmin Integration

- **Script Name**: `linkstack.pl`
- **Category**: Utilities
- **Runtime**: PHP 8.1+ / 8.2+
- **Database**: SQLite or MySQL/MariaDB
- **Document Root**: Can run directly in root `/` (ideal for short domains) or in `/links`

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **LinkStack** from the catalog.
3. Choose the target subdirectory (default `/links` or root `/`).
4. Complete the intuitive setup wizard at `https://yourdomain.com/links/`.
