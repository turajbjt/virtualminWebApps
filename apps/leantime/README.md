# Leantime Project Management for Virtualmin

**Leantime** is an open-source, strategic project management system for innovators, small teams, and startups. Combining agile methodologies with lean thinking, Leantime brings together idea boards, roadmaps, milestones, Kanban task boards, and time tracking.

---

## Features

- **Strategic Goal & Idea Boards**: Plan your high-level strategy using Lean Canvas and vision boards.
- **Kanban & Sprint Planning**: Flexible task boards with custom status columns, swimlanes, and subtasks.
- **Gantt & Milestone Roadmaps**: Interactive visual project timelines and dependencies.
- **Time Tracking & Timesheets**: Integrated work logging, timesheets, and client reports.
- **Clean Modern Interface**: Engaging, distraction-free user experience tailored for creative teams.

---

## Virtualmin Integration

- **Script Name**: `leantime.pl`
- **Category**: Project
- **Runtime**: PHP 8.1+ / 8.2+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/projects` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Leantime** from the catalog.
3. Choose the target subdirectory (default `/projects`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Finish the setup wizard at `https://yourdomain.com/projects/install`.
