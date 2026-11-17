# InvoicePlane Invoicing for Virtualmin

**InvoicePlane** is a free and open-source application for managing quotes, invoices, clients, and payments. Engineered as a clean, self-hosted alternative to expensive billing SaaS platforms, InvoicePlane puts you in full control of your accounting and customer billing.

---

## Features

- **Quotes, Invoices & Payments**: Convert accepted estimates directly into invoices with a single click.
- **Client Management**: Complete client ledger, transaction histories, and contact management.
- **PDF Generation & Customization**: Customizable PDF templates for professional invoicing.
- **Multiple Payment Gateways**: Connect directly with merchant processors and payment gateways.
- **Multi-Currency & Tax Rates**: Support for diverse tax rules and international currencies.

---

## Virtualmin Integration

- **Script Name**: `invoiceplane.pl`
- **Category**: Business
- **Runtime**: PHP 7.4+ / 8.x
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/invoices` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **InvoicePlane** from the catalog.
3. Choose the target subdirectory (default `/invoices`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Finish the setup wizard at `https://yourdomain.com/invoices/index.php/setup`.
