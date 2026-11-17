# OpenCart for Virtualmin

[OpenCart](https://www.opencart.com/) is an easy-to-use, feature-packed open-source e-commerce platform that powers hundreds of thousands of online stores globally.

## Features in this Virtualmin Module
* **Automated CLI Provisioning**: Automatically configures the database, table prefixes, and administrator credentials via OpenCart's `cli_install.php`.
* **Security Hardening**: Automatically removes the `install/` directory post-setup to prevent unauthorized reconfiguration.
* **Flexible Target Directory**: Install to domain root (`/`) or dedicated shop directory (e.g. `/store/`).
