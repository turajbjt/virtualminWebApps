# Grocy Home Pantry & Asset ERP for Virtualmin

**Grocy** is an open-source web application designed as an ERP for home and household management. It manages groceries, pantry inventory, expiration dates, chores, recipes, battery tracking, and equipment maintenance manuals.

---

## Features

- **Pantry & Grocery Stock Tracking**: Barcode scanning, purchase history, minimum stock thresholds, and expiration date tracking.
- **Recipe Management**: Link ingredients to pantry items with automatic stock deduction and shopping list generation.
- **Chore & Task Scheduling**: Track recurring cleaning tasks, maintenance routines, and family chore assignments.
- **Equipment & Battery Tracking**: Keep track of household appliances, serial numbers, manuals, and charge cycles.
- **REST API & Barcode Apps**: Integrates seamlessly with third-party barcode scanning companion apps (Grocy Mobile, Barcode Buddy).

---

## Virtualmin Integration

- **Script Name**: `grocy.pl`
- **Category**: Utilities
- **Runtime**: PHP (8.1 - 8.3 recommended)
- **Database**: Embedded SQLite (`data/grocy.db`) - zero external database required.
- **Permissions**: Sensitive configuration and database stored in `data/` with restricted permissions (`0600`).

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Grocy** from the catalog.
3. Specify the target subdirectory (default: `/grocy` or leave blank for root `/`).
4. Access `https://yourdomain.com/` and log in with default credentials (`admin` / `admin`). Update your password immediately.
