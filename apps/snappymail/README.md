# SnappyMail Webmail Client for Virtualmin

**SnappyMail** is a lightweight, responsive, and privacy-focused open-source webmail client. It is a modernized and actively maintained fork of RainLoop Webmail, designed for maximum speed, low resource consumption, and full mobile compatibility.

---

## Features

- **Blazing Fast**: Engineered with minimal JavaScript and modern PHP 8.x optimizations.
- **Zero Database Requirement**: Runs directly without SQL database overhead (uses local flat files/caching) or optional SQLite/MySQL for contacts.
- **IMAP / SMTP Support**: Connects directly to local Dovecot/Postfix in Virtualmin or external mail services.
- **Sieve Filters & Managesieve**: Full support for email filtering rules directly through the UI.
- **PGP Encryption**: Built-in OpenPGP client-side message encryption and signing.
- **Two-Factor Authentication**: Supports TOTP authenticator apps and WebAuthn hardware keys.
- **Modern Responsive Design**: Intuitive touch-friendly layout for desktop and mobile devices.

---

## Virtualmin Integration

- **Script Name**: `snappymail.pl`
- **Category**: Email
- **Runtime**: PHP 8.0+
- **Database**: None required (local file store)
- **Document Root**: Direct execution under domain's `public_html` (or `/mail` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **SnappyMail** from the catalog.
3. Choose the target subdirectory (default `/mail` or `/snappymail`).
4. Complete the installation.
5. Access the user webmail interface at `https://yourdomain.com/mail`.
6. Access the admin dashboard at `https://yourdomain.com/mail/?admin`.
   - Default username: `admin`
   - Initial password is automatically written to `data/_data_/_default_/admin_password.txt`.
