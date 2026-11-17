# MantisBT Bug Tracker for Virtualmin

**MantisBT** is a popular, free, and open-source web-based bug tracking system. Built on PHP and MySQL/MariaDB, MantisBT strikes a delicate balance between simplicity and power, allowing teams to get started instantly while managing complex software issue lifecycles.

---

## Features

- **Issue Lifecycle Tracking**: Customizable workflows, status states, resolutions, and priorities.
- **Role-Based Access Control**: Granular permissions per project (Viewer, Reporter, Updater, Developer, Manager, Administrator).
- **Email Notifications**: Automatic alert dispatch on issue submission, reassignment, or comment addition.
- **Roadmaps & Change Logs**: Track deliverables across releases and target milestones.
- **REST & SOAP APIs**: Integrate with CI/CD pipelines, Git repositories, and third-party developer tools.

---

## Virtualmin Integration

- **Script Name**: `mantisbt.pl`
- **Category**: Project
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/bugs` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **MantisBT** from the catalog.
3. Choose the target subdirectory (default `/bugs` or root `/`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Complete the installation wizard at `https://yourdomain.com/bugs/admin/install.php`.
6. Default initial credentials after database initialization:
   - Username: `administrator`
   - Password: `root` (prompted to change immediately upon first sign-in).
