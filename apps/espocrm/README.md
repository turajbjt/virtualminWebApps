# EspoCRM Customer Relationship Management for Virtualmin

**EspoCRM** is an open-source web application that allows you to see, enter, and evaluate all your company relationships regardless of the type (people, companies, projects, or opportunities). With its ultra-responsive Single Page Application (SPA) architecture, EspoCRM is an exceptionally fast and intuitive alternative to proprietary CRM platforms.

---

## Features

- **Lead & Opportunity Tracking**: Convert leads to opportunities, accounts, and contacts seamlessly.
- **Sales & Customer Pipeline**: Visual sales stages, forecasting, and conversion probability analytics.
- **Email & Calendar Integration**: Two-way IMAP/SMTP sync and Google/Outlook calendar synchronization.
- **Workflow Automation & BPM**: Business Process Management (BPM) engine for automatic task assignment, condition checks, and webhooks.
- **Mobile Responsive SPA**: Fast and intuitive web client optimized for smartphones and tablets.

---

## Virtualmin Integration

- **Script Name**: `espocrm.pl`
- **Category**: Business
- **Runtime**: PHP 8.1+ / 8.2+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/crm` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **EspoCRM** from the catalog.
3. Choose the target subdirectory (default `/crm`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Finish the installation wizard at `https://yourdomain.com/crm/install/`.
