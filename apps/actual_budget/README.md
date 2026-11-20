# Actual Budget

[Actual Budget](https://actualbudget.org) is a super fast, privacy-focused, zero-leak personal finance app and envelope budgeting system that gives you total control of your money with multi-device sync and bank synchronization support.

## Technical Specifications
- **Category**: Finance
- **Runtime**: Podman / Docker Container
- **Default Port**: `5006`
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/actual-budget/data`

## Virtualmin Integration
- Isolated rootless container execution under virtual server user
- Persistent local SQLite data store
- Dedicated systemd unit template `actual-budget-<domain>.service`
