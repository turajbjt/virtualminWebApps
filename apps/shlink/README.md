# Shlink

[Shlink](https://shlink.io) is an open-source self-hosted URL shortener that can be used to serve shortened URLs under your own domain. It provides REST and command-line APIs, multi-domain support, geolocated visit statistics, QR code generation, and webhooks.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: PHP (8.1 - 8.3)
- **Database**: MariaDB / MySQL or PostgreSQL
- **Install Directory**: `public_html/shlink`

## Virtualmin Integration
- Native PHP web application deployed directly under domain public_html
- Automated MySQL/MariaDB database configuration
- Works seamlessly with Virtualmin Apache/Nginx FastCGI/PHP-FPM
