# Vikunja Task Management for Virtualmin

**Vikunja** is an open-source, self-hostable to-do list and task management system built for all platforms. It enables individuals and teams to organize tasks with lists, Kanban boards, table views, and Gantt charts.

---

## Features

- **Multiple View Modes**: Kanban boards, task lists, calendar overviews, and interactive Gantt charts.
- **Subtasks & Dependencies**: Model complex tasks with nested subtasks and prerequisite relationships.
- **Reminders & Due Dates**: Recurring task intervals, priority labels, and email reminders.
- **Cross-Platform Compatibility**: Official desktop apps, Android/iOS mobile apps, and full web client.
- **Collaborative Sharing**: Share entire projects, lists, or individual tasks with team members or public read-only links.

---

## Virtualmin Integration

- **Script Name**: `vikunja.pl`
- **Category**: Project
- **Runtime**: Native Standalone Go Binary + Embedded Web Frontend
- **Database**: Embedded SQLite (or MariaDB)
- **Deployment**: Managed `systemd` service (`vikunja-<domain>.service`) listening on dynamic TCP port, reverse-proxied by Apache/Nginx.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Vikunja** from the catalog.
3. Configure the local reverse-proxy port (default auto-allocated).
4. Virtualmin deploys the binary, generates JWT encryption secrets, registers the systemd unit, and configures the web reverse proxy.
5. Open `https://yourdomain.com/` to register your initial administrator account.
