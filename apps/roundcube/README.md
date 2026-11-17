# Roundcube Webmail Virtualmin Installer

**Roundcube** is a browser-based multilingual IMAP client with an application-like user interface. It provides full functionality of an email client, including MIME support, address book, folder manipulation, message searching, and spell checking.

## Architecture
- **Language**: PHP 8.1+ / 8.2+
- **Database**: MariaDB / MySQL
- **Mail Backend**: Local IMAP / SMTP (Postfix / Dovecot)
- **Web Server**: Apache or Nginx

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> Roundcube** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/webmail` or document root.
