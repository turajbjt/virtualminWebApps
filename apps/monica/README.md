# Monica PRM - Virtualmin Web App

[Monica](https://www.monicahq.com/) is an open-source Personal Relationship Management (PRM) system designed to organize interactions, memories, notes, and tasks related to your friends, family, and professional contacts.

## Features

* **Contact Timelines & Journaling**: Log conversations, activities, and important life events for each contact.
* **Reminders & Alerts**: Automated notifications for birthdays, anniversaries, and follow-ups.
* **Relationship Graph**: Track relationships between contacts, family trees, and circles.
* **Debts & Loans**: Keep track of money lent or borrowed.
* **Privacy-First**: Zero tracking, self-hosted on your own MariaDB database.

## Virtualmin Integration Details

* **Runtime Model**: PHP 8.1+ application running in `public_html` (or subfolder like `/monica`).
* **Database**: Automated MariaDB/MySQL database provisioning and `.env` configuration.
* **Directory Structure**: Includes pre-compiled Composer vendor dependencies.
