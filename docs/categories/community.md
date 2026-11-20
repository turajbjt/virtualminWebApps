# Community Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Modern discussion platforms, community bulletin boards, and forum software.

This classification includes **4 Applications** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Flarum** | `latest` | `3` | Modern PHP / Composer Discussion Forum | [App Readme](../../apps/flarum/README.md) |
| **GoToSocial** | `0.17.4` | `1` | ActivityPub Social Server (Go / SQLite) | [App Readme](../../apps/gotosocial/README.md) |
| **MyBB** | `1.8.41` | `3` | Modern PHP / MariaDB Discussion Board & Forum | [App Readme](../../apps/mybb/README.md) |
| **phpBB** | `3.3.13` | `3` | Classic PHP / MariaDB Bulletin Board Forum | [App Readme](../../apps/phpbb/README.md) |

---

## Technical Details

### Flarum

* **Category**: Community / Forums
* **Version**: `latest` | **Build**: `3`
* **Upstream**: [https://flarum.org](https://flarum.org)
* **Architecture**: Modern PHP with Composer-based automated dependency deployment.


### GoToSocial

* **Category**: Community
* **Version**: `0.17.4` | **Build**: `1`
* **Upstream**: [https://gotosocial.org](https://gotosocial.org)
* **Architecture**: Fast, low-memory ActivityPub server in Go. Federates with Mastodon and the Fediverse. Runs as a managed systemd service reverse-proxied over HTTPS with WebSocket forwarding.
* **Database**: Embedded SQLite.


### MyBB

* **Category**: Community
* **Version**: `1.8.41` | **Build**: `3`
* **Upstream**: [https://mybb.com](https://mybb.com)
* **Architecture**: Free and open-source bulletin board forum software with role-based moderation queues, member reputation scoring, thread subscriptions, and plugin extensibility.
* **Database**: MariaDB / MySQL.


### phpBB

* **Category**: Community / Forums
* **Version**: `3.3.13` | **Build**: `3`
* **Upstream**: [https://www.phpbb.com](https://www.phpbb.com)
* **Architecture**: Classic PHP/MariaDB bulletin board forum with pre-configured database parameters.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
