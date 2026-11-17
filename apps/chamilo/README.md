# Chamilo LMS for Virtualmin

**Chamilo LMS** is a free, open-source e-learning and course management system (Learning Management System) aimed at improving access to education and knowledge globally. It is backed by the non-profit Chamilo Association and used by universities, government organizations, and enterprises worldwide.

---

## Features

- **Course Authoring**: Create interactive SCORM-compliant courses, tests, quizzes, and assignments.
- **Skills Management & Badges**: Award competency badges and certificates upon course completion.
- **Virtual Classrooms**: Video conference integration, chat, and discussion forums.
- **Multi-Tenant Portals**: Support for departmental sub-campuses and distinct educational groups.
- **Multilingual Support**: Fully translated into over 50 languages with multi-device responsive design.

---

## Virtualmin Integration

- **Script Name**: `chamilo.pl`
- **Category**: Education
- **Runtime**: PHP 8.1+ / 8.2+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/chamilo` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Chamilo LMS** from the catalog.
3. Choose the target subdirectory (default `/chamilo`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Finish the setup wizard at `https://yourdomain.com/chamilo/`.
