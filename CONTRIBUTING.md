# Contributing to the Virtualmin Web Apps Suite

Thank you for your interest in contributing! The **Virtualmin Web Apps Suite** is an open-source project dedicated to expanding the Virtualmin hosting ecosystem with high-quality, modern, and secure 1-click web application installers.

---

## Code of Conduct

All contributors and maintainers are expected to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before participating.

---

## Development Setup

### Prerequisites
* Linux operating system (RHEL, Rocky, AlmaLinux, Debian, Ubuntu, Fedora).
* Perl 5.16 or higher (`perl -v`).
* `prove` (Test::Harness) for running the TAP unit test suite.
* Git.

### 1. Fork & Clone
Fork the repository on GitHub and clone your fork locally:

```bash
# Clone via HTTPS
git clone https://github.com/<your-username>/virtualminWebApps.git
cd virtualminWebApps

# Or clone via SSH
git clone git@github.com:<your-username>/virtualminWebApps.git
cd virtualminWebApps
```

### 2. Verify Your Environment
Run the test suite to ensure everything compiles and passes in your local environment:

```bash
./setup.sh test
```

---

## Adding a New Application Installer

Every application in the suite is self-contained in its own directory under `apps/<app_name>/`.

### 1. Application Directory Layout
Create a new directory under `apps/` with the lowercase identifier of your app:

```text
apps/<app_name>/
├── <app_name>.pl          # Virtualmin install script interface (required)
├── <app_name>.service     # Systemd unit template (required only for daemons)
└── README.md              # Application documentation & setup notes (required)
```

### 2. Required Perl Interface Functions
The `<app_name>.pl` script must implement Virtualmin's script API:

```perl
sub script_<name>_desc { return "Human-Readable App Name"; }
sub script_<name>_category { return "Category"; }   # e.g., Commerce, CMS, Security, System
sub script_<name>_versions { return ("1.0.0"); }     # Upstream application version
sub script_<name>_release { return 1; }              # Module build revision (starts at 1)
sub script_<name>_check { ... }                      # Verifies system requirements (PHP, DB, etc.)
sub script_<name>_depends { ... }                    # Virtualmin feature dependencies (mysql, web, etc.)
sub script_<name>_params { ... }                     # Form fields for Webmin UI
sub script_<name>_parse { ... }                      # Parses user input and validates parameters
sub script_<name>_install { ... }                    # Downloads, unpacks, configures, and deploys
sub script_<name>_uninstall { ... }                  # Safely cleans up directories, services, and configs
```

### 3. Security & Coding Standards
All new installers must comply with our security policy:
* **Path Validation**: Always sanitize paths using `VirtualminWebApps::Common::sanitize_path($in{'path'})`.
* **Random Secrets**: Always generate passwords using `VirtualminWebApps::Common::generate_random_key(16)` (reads `/dev/urandom`).
* **Port Validation**: If allocating ports for daemons, validate with `VirtualminWebApps::Common::validate_port($port)`.
* **Permissions**: Lock secret and credential files to `0600` permissions.
* **Non-Root Execution**: Daemons must execute under the virtual server domain user, not as `root`.

### 4. Link & Test
After creating your application files:
1. Run `./setup.sh update` to automatically generate the symlink in `scripts/`.
2. Run `./setup.sh list` to ensure metadata extracts properly.
3. Run `./setup.sh test` to execute the full test suite (syntax, metadata, security fuzzing, and secret leak scanning).

---

## Module Build Versioning Policy

We strictly decouple the **Upstream Application Version** from our **Module Build Number**:
* `script_<name>_versions`: Upstream software version (e.g., `30.0.6`).
* `script_<name>_release`: Virtualmin module revision (e.g., `1`, `2`, `3`).

**Whenever you modify an existing script's logic, service unit, or configuration template, you MUST increment `script_<name>_release` by 1.**

---

## Submitting a Pull Request

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/add-new-app
   ```
2. Commit your changes with a clear, descriptive commit message:
   ```bash
   git commit -m "Add <app_name> 1-click installer with systemd service and documentation"
   ```
3. Update [CHANGELOG.md](CHANGELOG.md) under the `[Unreleased]` or latest version section.
4. Push your branch to your GitHub fork:
   ```bash
   git push origin feature/add-new-app
   ```
5. Open a Pull Request against `turajbjt/virtualminWebApps:main`.
6. Ensure all GitHub Actions CI checks pass.
