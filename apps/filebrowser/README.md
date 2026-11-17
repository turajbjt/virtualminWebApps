# File Browser for Virtualmin

[File Browser](https://filebrowser.org/) provides a clean file managing interface within a specified directory and can be used to upload, delete, preview, and edit files.

## Features in this Virtualmin Module
* **Ultra Lightweight**: Standalone Go binary requiring only ~15MB RAM.
* **Isolated Daemon**: Managed by systemd under the domain owner's account.
* **Apache & Nginx Reverse Proxy**: Pre-configured reverse proxy to domain root.
* **Domain Root Management**: Points directly to `/home/<domain>` to allow easy file management.
