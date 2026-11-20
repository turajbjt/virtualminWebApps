# osTicket Customer Support System for Virtualmin

**osTicket** is a widely-used open-source customer support ticket system. It routes inquiries created via email, web forms, and phone calls into a simple multi-user web interface.

---

## Features

- **Multi-Channel Ticketing**: Ingest and manage tickets submitted via web portal or incoming email.
- **Custom Fields & Forms**: Tailor ticket fields, help topics, and lists to match your business inquiries.
- **Service Level Agreements (SLA)**: Track ticket resolution times and automatically escalate overdue requests.
- **Role-Based Staff Permissions**: Assign tickets to specific departments, teams, or agents with granular access controls.
- **Customer Web Portal**: Customers can view past tickets, check status updates, and view knowledge base articles.

---

## Virtualmin Integration

- **Script Name**: `osticket.pl`
- **Category**: Business
- **Runtime**: PHP (8.1 - 8.3 recommended)
- **Database**: MariaDB / MySQL
- **Cron**: Automated cron job (`api/cron.php`) scheduled every 5 minutes in the user crontab for automatic email polling.
- **Permissions**: Sensitive configuration file `include/ost-config.php` secured with restricted permissions (`0600`).

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **osTicket** from the catalog.
3. Specify the target subdirectory (default: `/support` or `/osticket`).
4. Enter the administrator email and choose or auto-generate a secure password.
5. Virtualmin will download the package, wire the MariaDB database, configure `include/ost-config.php`, register background cron polling, and direct you to `/setup/` to complete the initial staff profile.
