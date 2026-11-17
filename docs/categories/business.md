# Business Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Enterprise Resource Planning (ERP), Customer Relationship Management (CRM), and client invoicing suites.

This classification includes **6 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Dolibarr** | `20.0.2` | `2` | Full ERP & CRM Suite (Pro Equivalent) | [App Readme](../../apps/dolibarr/README.md) |
| **EspoCRM** | `10.1.3` | `2` | Fast Single-Page Application (SPA) CRM Platform | [App Readme](../../apps/espocrm/README.md) |
| **Invoice Ninja** | `5.10.40` | `2` | Invoicing, Payments & Time Tracking (Pro Equivalent) | [App Readme](../../apps/invoiceninja/README.md) |
| **InvoicePlane** | `1.6.1` | `2` | Open-Source Invoicing, Quotes & Client Management | [App Readme](../../apps/invoiceplane/README.md) |
| **Monica PRM** | `4.1.2` | `2` | Personal Relationship Management Platform (PHP / MariaDB) | [App Readme](../../apps/monica/README.md) |
| **SuiteCRM** | `8.10.2` | `2` | Enterprise Customer Relationship Management | [App Readme](../../apps/suitecrm/README.md) |

---

## Technical Details

### Dolibarr

* **Category**: Business
* **Version**: `20.0.2` | **Build**: `2`
* **Upstream**: [https://www.dolibarr.org](https://www.dolibarr.org)
* **Architecture**: PHP with MariaDB.
* **Document Isolation**: Uploaded business invoices and documents stored in `/home/<domain>/dolibarr-documents` outside `public_html`.


### EspoCRM

* **Category**: Business
* **Version**: `10.1.3` | **Build**: `2`
* **Upstream**: [https://www.espocrm.com](https://www.espocrm.com)
* **Architecture**: Responsive Single Page Application (SPA) CRM platform enabling companies to manage relationships, sales opportunities, email integration, and workflow automation.
* **Database**: MariaDB / MySQL.


### Invoice Ninja

* **Category**: Business
* **Version**: `5.10.40` | **Build**: `2`
* **Upstream**: [https://www.invoiceninja.com](https://www.invoiceninja.com)
* **Architecture**: Laravel PHP with MariaDB database.
* **Scheduler Cron**: `* * * * * php artisan schedule:run` registered in crontab for recurring invoices and reminder automation.


### InvoicePlane

* **Category**: Business
* **Version**: `1.6.1` | **Build**: `2`
* **Upstream**: [https://invoiceplane.com](https://invoiceplane.com)
* **Architecture**: Clean open-source invoicing and client management software with quote-to-invoice conversion, PDF invoice generation, multi-currency support, and payment integration.
* **Database**: MariaDB / MySQL.


### Monica PRM

* **Category**: Business
* **Version**: `4.1.2` | **Build**: `2`
* **Upstream**: [https://www.monicahq.com](https://www.monicahq.com)
* **Architecture**: Personal Relationship Management (PRM) platform built with Laravel/PHP to document interactions, milestones, contact notes, and relationships.
* **Database**: MariaDB / MySQL.


### SuiteCRM

* **Category**: Business
* **Version**: `8.10.2` | **Build**: `2`
* **Upstream**: [https://suitecrm.com](https://suitecrm.com)
* **Architecture**: Enterprise-grade customer relationship management (CRM) application with modular business workflows and automated permissions.
* **Database**: MariaDB / MySQL.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
