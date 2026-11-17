# Knowledge Applications

> Part of the [Virtualmin Web Apps Suite](../../README.md). [← Back to Main Directory](../../README.md#classification-directory)

Hierarchical knowledge bases, note-taking applications, and research organizers.

This classification includes **1 Application** ready for 1-click deployment on Virtualmin servers.

---

## Overview Table

| Application | App Version | Build | Architecture / Type | Documentation |
| :--- | :--- | :--- | :--- | :--- |
| **Trilium Notes** | `0.95.0` | `2` | Standalone Node.js Daemon + WebSocket Reverse Proxy | [App Readme](../../apps/trilium/README.md) |

---

## Technical Details

### Trilium Notes

* **Category**: Knowledge
* **Version**: `0.95.0` | **Build**: `2`
* **Upstream**: [https://triliumnotes.org](https://triliumnotes.org)
* **Architecture**: Hierarchical note-taking application powered by a self-contained Node.js server binary, running as a dedicated systemd service (`trilium-<dom>.service`) behind an automated Apache/Nginx reverse proxy with WebSocket support.
* **Storage**: `/home/<dom>/trilium-data`.


---

[← Back to Classification Directory](../../README.md#classification-directory) | [Main Documentation](../../docs/APPLICATIONS.md)
