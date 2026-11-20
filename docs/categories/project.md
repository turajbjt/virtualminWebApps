# Project Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Visual Kanban project management, issue tracking, milestones, and task boards.

This classification includes **5 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Kanboard** | `1.2.40` | `3` | Minimalist Visual Kanban Project Management | [App Readme](../../apps/kanboard/README.md) |
| **Leantime** | `3.4.6` | `3` | Strategic & Agile Project Management (Kanban, Milestones) | [App Readme](../../apps/leantime/README.md) |
| **MantisBT** | `2.28.4` | `3` | Web-Based Issue & Bug Tracking System (PHP / MariaDB) | [App Readme](../../apps/mantisbt/README.md) |
| **Planka** | `1.22.1` | `1` | Realtime Collaborative Kanban Board (Container + Systemd) | [App Readme](../../apps/planka/README.md) |
| **Vikunja** | `2.8.0` | `3` | To-Do & Task Management + Kanban/Gantt (Go Binary + Systemd) | [App Readme](../../apps/vikunja/README.md) |

---

## Technical Details

### Kanboard

* **Category**: Project
* **Version**: `1.2.40` | **Build**: `3`
* **Upstream**: [https://kanboard.org](https://kanboard.org)
* **Architecture**: Minimalist visual Kanban board project management tool. Uses zero-configuration SQLite backend by default or optional MariaDB.
* **Database**: SQLite / MariaDB.


### Leantime

* **Category**: Project
* **Version**: `3.4.6` | **Build**: `3`
* **Upstream**: [https://leantime.io](https://leantime.io)
* **Architecture**: Strategic project management system for agile teams and startups, combining Lean Canvas idea boards, Kanban sprint workflows, Gantt roadmaps, and time logging.
* **Database**: MariaDB / MySQL.


### MantisBT

* **Category**: Project
* **Version**: `2.28.4` | **Build**: `3`
* **Upstream**: [https://www.mantisbt.org](https://www.mantisbt.org)
* **Architecture**: Web-based bug and issue tracking system with customizable issue workflows, role-based project access control, email notifications, and REST API support.
* **Database**: MariaDB / MySQL.


### Planka

* **Category**: Project
* **Version**: `1.22.1` | **Build**: `1`
* **Upstream**: [https://planka.app](https://planka.app)
* **Architecture**: Real-time collaborative kanban board for agile project and task management with cards, checklists, labels, and attachments. Supervised by systemd and reverse-proxied with WebSockets.
* **Database**: Embedded SQLite.


### Vikunja

* **Category**: Project
* **Version**: `2.8.0` | **Build**: `3`
* **Upstream**: [https://vikunja.io](https://vikunja.io)
* **Architecture**: Modern, self-hostable to-do list and task management system built in Go with an embedded web frontend, managed by systemd and reverse-proxied with SSL.
* **Database**: Embedded SQLite (or MariaDB).


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
