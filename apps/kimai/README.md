# Kimai Time Tracking & Invoicing for Virtualmin

**Kimai** is a free, open-source time tracker and timesheet software built with Symfony and PHP. It tracks work times, prints summaries, exports timesheets, calculates budgets, and generates customer invoices.

---

## Features

- **Precise Work Time Tracking**: Record working hours via web browser, mobile apps, or desktop widgets.
- **Customer & Project Hierarchies**: Organize activities across customers, projects, and tasks with granular hourly rates.
- **Reporting & Analytics**: Comprehensive dashboards, export to Excel/PDF/CSV, and weekly/monthly summary reviews.
- **Invoicing System**: Generate customizable invoices for billable activities and track payment statuses.
- **REST API**: Fully documented API for integration with billing engines, payroll, and external CRMs.

---

## Virtualmin Integration

- **Script Name**: `kimai.pl`
- **Category**: Business
- **Runtime**: PHP (8.1 - 8.3 recommended)
- **Database**: MariaDB / MySQL
- **Configuration**: Stores database credentials and cryptographic app secret in restricted `.env.local` (`0600`).

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Kimai** from the catalog.
3. Choose the target subdirectory (default: `/kimai` or root `/`).
4. Enter the administrator email and choose or auto-generate a secure password.
5. Virtualmin will download the package, wire the MariaDB database, generate the application secrets, and configure permissions.
