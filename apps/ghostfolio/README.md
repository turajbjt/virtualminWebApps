# Ghostfolio

[Ghostfolio](https://ghostfol.io) is an open-source wealth management dashboard driven by the principles of privacy and simplicity. It allows individuals to track stock portfolios, cryptocurrencies, ETFs, dividends, and net worth across multiple accounts and currencies.

## Technical Specifications
- **Category**: Finance
- **Runtime**: Podman / Docker Container
- **Default Port**: `3333`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/ghostfolio/data`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user account
- Auto-generated cryptographically secure JWT secrets
- Systemd daemon management via `ghostfolio-<domain>.service`
