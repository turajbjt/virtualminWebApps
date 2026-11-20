# pgAdmin 4 for Virtualmin

**pgAdmin 4** is the leading open-source management tool for PostgreSQL databases. It provides a feature-rich graphical interface to manage database objects, write SQL queries, inspect server activity, and monitor performance.

---

## Features

- **Object Management**: Manage databases, schemas, tables, views, functions, triggers, and sequences.
- **SQL Query Tool**: Syntax highlighting, execution plan visualizer, auto-completion, and graphical query builder.
- **Server Monitoring Dashboard**: Real-time server sessions, locks, transactions per second, and database size metrics.
- **PostgreSQL Focus**: Direct complement to `phpMyAdmin` (for MySQL) for hosting environments utilizing PostgreSQL.

---

## Virtualmin Integration

- **Script Name**: `pgadmin4.pl`
- **Category**: Database
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Database**: PostgreSQL (Virtualmin managed or external)
- **Deployment**: Managed `systemd` service (`pgadmin4-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **pgAdmin 4** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` using the auto-generated admin credentials presented upon installation.
