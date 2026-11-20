# FreeScout Help Desk for Virtualmin

**FreeScout** is a lightweight, open-source Help Scout alternative written in PHP and powered by Laravel. It provides a shared inbox, ticket management, knowledge base modules, and email conversation threading for support teams without per-agent subscription fees.

---

## Features

- **Shared Team Mailboxes**: Centralize incoming customer emails into unified team queues.
- **Auto-Reply & Saved Replies**: Expedite support responses with templated messages and automation workflows.
- **Native Mail Integration**: Directly integrates with Virtualmin's local Postfix and Dovecot mail services.
- **Multilingual & Mobile-Friendly**: Clean, responsive web interface suitable for desktop and mobile browsers.
- **Module Ecosystem**: Extensible with live chat, knowledge base, custom fields, and notifications.

---

## Virtualmin Integration

- **Script Name**: `freescout.pl`
- **Category**: Business
- **Runtime**: PHP (8.1 - 8.3 recommended)
- **Database**: MariaDB / MySQL
- **Cron Jobs**: Native per-user cron executing `artisan schedule:run` every minute for email polling and background dispatching.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **FreeScout** from the catalog.
3. Choose the target subdirectory (default: `/helpdesk` or root `/`).
4. Enter the administrator email and choose or auto-generate a secure password.
5. Virtualmin will download the package, wire the MariaDB database, generate the application encryption key, write `.env` with restricted permissions (`0600`), and register the background queue cron.
