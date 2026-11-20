# Changelog

All notable changes to the **Virtualmin Web Apps Suite** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to Semantic Versioning.

---

## [2.1.0] - 2026-11-20

### Added
- **10 New Web Application Installers (Suite Expanded from 100 to 110 Applications across 24 Classifications)**:
  - **Immich (`apps/immich/`)**: High-performance photo and video backup and management platform with AI facial recognition, object detection, and mobile sync (`immich-<dom>.service`).
  - **HedgeDoc (`apps/hedgedoc/`)**: Real-time collaborative Markdown note-taking platform with live rendered preview and presentation mode (`hedgedoc-<dom>.service`).
  - **ArchiveBox (`apps/archivebox/`)**: Open-source self-hosted internet archiving solution preserving web pages as HTML, PDF, screenshots, and WARC (`archivebox-<dom>.service`).
  - **PairDrop (`apps/pairdrop/`)**: Local and cross-network encrypted file sharing in the browser (AirDrop alternative) with WebRTC and WebSockets (`pairdrop-<dom>.service`).
  - **Ghostfolio (`apps/ghostfolio/`)**: Privacy-focused open-source wealth and portfolio management dashboard for stocks, ETFs, and crypto (`ghostfolio-<dom>.service`).
  - **RomM (`apps/romm/`)**: Modern retro video game ROM library manager with IGDB metadata scraping and in-browser emulator integration (`romm-<dom>.service`).
  - **Stump (`apps/stump/`)**: High-performance digital comic, manga, and book streaming server written in Rust with OPDS feed support (`stump-<dom>.service`).
  - **Appwrite (`apps/appwrite/`)**: Complete self-hosted Backend-as-a-Service providing authentication, databases, file storage, and cloud functions (`appwrite-<dom>.service`).
  - **Mumble / Murmur (`apps/mumble/`)**: Low-latency, encrypted high-quality voice chat server for gaming and team communications (`mumble-<dom>.service`).
  - **Borgmatic (`apps/borgmatic/`)**: Simple, configuration-driven backup software wrapping BorgBackup with encryption, retention schedules, and prune policies (`borgmatic-<dom>.service`).
- **1-Click Bootstrap Installer (`install.sh`)**:
  - Portable shell installer enabling instant one-command installation on any Virtualmin server via `curl -fsSL .../install.sh | sudo bash`.
- **Interactive CLI Catalog Tools**:
  - `setup.sh search <query>`: Instant catalog search filtering across application names, categories, and descriptions.
  - `setup.sh info <app>`: Technical inspector card showing author, upstream site, supported versions, build revision, dependencies, runtime mode, and service status.
- **GitHub Release Automation (`.github/workflows/release.yml`)**:
  - Automated release pipeline building distribution archives (`virtualmin-webapps-*.tar.gz`) and publishing GitHub Releases upon tag creation.
- **Enhanced Continuous Integration**:
  - Added multi-version test matrix (Ubuntu 22.04 & 24.04) and ShellCheck script linting.
- **Automated Test Suite Expansion**:
  - Expanded automated test suite from 1,775 to **1,945 tests** across all 9 TAP test files (`01_syntax.t` through `09_virtualmin_loader.t`), maintaining 100% PASS rate across all 110 applications.

---

## [2.0.0] - 2026-11-20

### Added
- **The Century Milestone: 13 New Web Application Installers (Suite Expanded from 87 to 100 Applications across 24 Classifications)**:
  - **Jellyfin (`apps/jellyfin/`)**: Open-source home media streaming server for movies, shows, music, and live TV. Full WebSocket reverse proxying and systemd supervision (`jellyfin-<dom>.service`).
  - **Meilisearch (`apps/meilisearch/`)**: Lightning-fast, typo-tolerant open-source search engine in Rust with instant search-as-you-type (<50ms) and master API key generation (`meilisearch-<dom>.service`).
  - **PhotoPrism (`apps/photoprism/`)**: AI-powered personal photo library and visual asset management system with automatic image categorization and facial recognition (`photoprism-<dom>.service`).
  - **MinIO (`apps/minio/`)**: High-performance, S3-compatible multi-cloud object storage daemon in Go with web console and PRNG credentials (`minio-<dom>.service`).
  - **Conduit (`apps/conduit/`)**: Ultra-lightweight, high-performance Matrix homeserver written in Rust with minimal memory footprint and systemd service supervision (`conduit-<dom>.service`).
  - **Changedetection.io (`apps/changedetection/`)**: Automated web page change monitoring, price alerts, and restock tracking with notifications across 70+ notification services (`changedetection-<dom>.service`).
  - **Gatus (`apps/gatus/`)**: Automated service health monitoring dashboard and status page with YAML configuration and WebSocket reverse proxying (`gatus-<dom>.service`).
  - **Shlink (`apps/shlink/`)**: Self-hosted URL shortener with REST API, geolocated analytics, QR codes, and native PHP/MariaDB execution.
  - **Linkding (`apps/linkding/`)**: Minimalist, fast, tag-based self-hosted bookmark manager with Wayback Machine archiving (`linkding-<dom>.service`).
  - **Directus (`apps/directus/`)**: Instant open-source REST & GraphQL API engine and headless CMS on top of SQL databases with role-based access control (`directus-<dom>.service`).
  - **Kopia (`apps/kopia/`)**: Fast, secure, end-to-end encrypted and deduplicated server backup management suite with built-in Web UI (`kopia-<dom>.service`).
  - **Actual Budget (`apps/actual_budget/`)**: Super fast, privacy-first personal finance app and envelope budgeting system (`actual-budget-<dom>.service`).
  - **Planka (`apps/planka/`)**: Real-time collaborative kanban board for agile project and task management with WebSockets (`planka-<dom>.service`).
- **`setup.sh doctor` Diagnostic Command**:
  - Full diagnostic health check for system environment, kernel, Perl runtime, required core modules, Webmin/Virtualmin integration status, CLI utilities (curl, wget, tar, unzip, gzip, systemctl), container engines (Podman, Docker), and broken symlink detection.
- **GitHub Actions CI/CD Integration**:
  - Added repository and system diagnostics verification step into `.github/workflows/ci.yml`.
- **Automated Test Suite Expansion**:
  - Expanded automated test suite from 1,554 to **1,775 tests** across all 9 TAP test files (`01_syntax.t` through `09_virtualmin_loader.t`), maintaining a 100% PASS rate across all 100 applications.

---

## [1.13.0] - 2026-11-20

### Added
- **18 New Web Application Installers (Suite Expanded from 69 to 87 Applications across 24 Classifications)**:
  - **phpRedisAdmin (`apps/phpredisadmin/`)**: Lightweight web GUI for Redis databases written in PHP, enabling key search, structure inspection, memory metrics, and CLI command execution.
  - **Woodpecker CI (`apps/woodpecker/`)**: Standalone Go binary continuous integration engine with declarative `.woodpecker.yml` pipelines, native Forgejo/Gitea webhook wiring, and systemd supervision (`woodpecker-<dom>.service`).
  - **Calibre-Web (`apps/calibre_web/`)**: Clean web UI for browsing, in-browser reading (ePub, PDF, CBR), and downloading eBooks using a Calibre database. Supervised by systemd (`calibre-web-<dom>.service`) and reverse-proxied.
  - **n8n (`apps/n8n/`)**: Fair-code workflow automation and integration platform (Zapier alternative) connecting webhooks, APIs, databases, and AI agents via visual canvas (`n8n-<dom>.service`).
  - **Homepage (`apps/homepage/`)**: Modern application dashboard and service status portal organizing apps into categorized tiles with live server metrics and service widgets (`homepage-<dom>.service`).
  - **SearXNG (`apps/searxng/`)**: Privacy-first metasearch engine combining 70+ search services with zero profiling, cookies, or query logging (`searxng-<dom>.service`).
  - **Wiki.js (`apps/wikijs/`)**: Modern documentation wiki engine with Markdown, Visual WYSIWYG, AsciiDoc, full-text search, and automated two-way Git synchronization (`wikijs-<dom>.service`).
  - **pgAdmin 4 (`apps/pgadmin4/`)**: The premier web-based management tool for PostgreSQL databases featuring graphical schema inspection, SQL query runner, and server monitoring (`pgadmin4-<dom>.service`).
  - **RustDesk Server (`apps/rustdesk/`)**: High-performance, self-hosted remote desktop rendezvous and relay server in Rust (`hbbs` / `hbbr`) for encrypted remote desktop clients (`rustdesk-<dom>.service`).
  - **Audiobookshelf (`apps/audiobookshelf/`)**: Self-hosted audiobook and podcast server with streaming, progress sync, multi-user accounts, and mobile companion app support (`audiobookshelf-<dom>.service`).
  - **Grocy (`apps/grocy/`)**: Web-based ERP for home and household management (groceries, pantry inventory, recipes, tasks, and battery tracking). Pure PHP application with embedded SQLite database.
  - **Stirling-PDF (`apps/stirling_pdf/`)**: Powerful locally hosted, browser-based PDF manipulation tools (merging, splitting, OCR, conversions, signing) running via systemd (`stirling-pdf-<dom>.service`).
  - **osTicket (`apps/osticket/`)**: Battle-tested open-source customer support ticketing system with SLA plans, auto-responders, staff routing, and background email polling via user crontab.
  - **FreeScout (`apps/freescout/`)**: Self-hosted Help Scout alternative written in PHP (Laravel) with MariaDB backend, shared mailboxes, automated background queue/email polling via user crontab, and PCI DSS restricted `.env` permissions (`0600`).
  - **PocketBase (`apps/pocketbase/`)**: Single-binary Go backend with embedded SQLite database, realtime subscriptions via SSE/WebSockets, built-in auth, file storage, systemd daemon management (`pocketbase-<dom>.service`), and reverse proxying with WebSocket support.
  - **Syncthing (`apps/syncthing/`)**: Continuous, decentralized, peer-to-peer file synchronization engine written in Go with TLS mutual authentication and web management GUI. Managed via systemd (`syncthing-<dom>.service`) and reverse-proxied.
  - **Kimai (`apps/kimai/`)**: Open-source time tracking, timesheet recording, and customer invoicing web application built with Symfony and PHP with MariaDB database backend and secured `.env.local` permissions (`0600`).
  - **GoToSocial (`apps/gotosocial/`)**: Lightweight ActivityPub social network server in Go federating with Mastodon and the Fediverse with embedded SQLite database, systemd daemon unit (`gotosocial-<dom>.service`), and HTTPS reverse proxying with WebSockets.
- **Automated Test Suite Expansion**:
  - Expanded automated test coverage from 1,248 to **1,554 tests** across 9 test suites with 100% PASS rate.
  - Verified syntax, metadata, security fuzzing, input validation, and Virtualmin loader compatibility across all 87 applications.

### Changed
- **UI Readability & Module Titles (All 69 Applications)**:
  - Formatted application titles across all 69 installer scripts (`script_<name>_desc`) with a hyphen separator (`App Name - Description`), e.g., `AbanteCart - E-Commerce Platform`, eliminating visual ambiguity in the Virtualmin **Manage Web Apps / Install Scripts** catalog.
  - Incremented installer build numbers across all 69 modules to **Build 3** (`script_<name>_release`) in compliance with the Module Build Number Policy.
  - Synchronized technical documentation across `docs/APPLICATIONS.md` and all 24 category catalogs in `docs/categories/` to reflect the updated Build 3 metadata.

---

## [1.12.0] - 2026-11-17

### Fixed
- **Virtualmin Core Integration & Registration (`setup.sh`)**:
  - Resolved issue where scripts were not appearing in Virtualmin's **Manage Web Apps / Install Scripts** web interface.
  - Rewrote installer to register scripts directly into Virtualmin's official custom scripts directory: `/etc/webmin/virtual-server/scripts/`, which is natively scanned by Virtualmin's `@scripts_directories` loader routine.
  - Cleaned up obsolete `custom_scripts_dir=` config setting.
  - Added automatic detection and whitelisting in `/etc/webmin/virtual-server/scriptsunavail` for environments with strict `denydefault=1` policies.
  - Fixed `scripts/lib` symlink in Git repository to use relative target `../lib` instead of absolute dev path, preventing unstaged changes and rebase conflicts on external clones.
- **Dynamic Perl `@INC` Symlink Resolution (All 69 Applications)**:
  - Updated all 69 application installer scripts in `apps/*/*.pl` to resolve symlinks dynamically via `Cwd::abs_path(__FILE__)` before calculating library search paths.
  - Eliminates `Can't locate Common.pl in @INC` errors when scripts are executed via Perl's `do` operator from `/etc/webmin/virtual-server/scripts/`.

### Added
- **Virtualmin Loader Test Suite (`tests/09_virtualmin_loader.t`)**:
  - Implemented 207 comprehensive automated tests replicating Virtualmin's exact `get_script()` loading mechanism via `do()` through symlinked directories without local libraries.
  - Verified 100% success rate across all 69 application descriptors and version hooks.

### Documentation
- **Installation & Troubleshooting Updates**:
  - Updated `docs/INSTALLATION.md` and `docs/TROUBLESHOOTING.md` with accurate Virtualmin script directory architecture (`/etc/webmin/virtual-server/scripts`), CLI audit commands (`virtualmin list-available-scripts --source custom`), and UI tab navigation tips.

---

## [1.11.0] - 2026-11-17

### Added
- **Formal Open Source Licensing (`LICENSE`)**:
  - Added root GNU General Public License v3.0 (`LICENSE`) enabling native GitHub license detection and verification.
- **Security Policy (`SECURITY.md`)**:
  - Formulated comprehensive security policy detailing supported versions, vulnerability disclosure procedures, response SLAs (48h acknowledgment, 5d triage, 14d patch), and architectural PCI DSS v4.0 controls.
- **Contribution Standards (`CONTRIBUTING.md` & `CODE_OF_CONDUCT.md`)**:
  - Added development and contribution guidelines covering application layout standards, required Virtualmin script interface hooks, module build versioning, and test execution.
  - Established community standards and pledge for inclusive, professional collaboration.
- **GitHub Issue & Pull Request Templates (`.github/`)**:
  - `.github/ISSUE_TEMPLATE/bug_report.md`: Structured bug reporting capturing OS, Virtualmin version, web server, and logs.
  - `.github/ISSUE_TEMPLATE/app_request.md`: Dedicated template for community proposals of new web application installers.
  - `.github/ISSUE_TEMPLATE/feature_request.md`: Feature enhancement proposal template.
  - `.github/PULL_REQUEST_TEMPLATE.md`: Contributor checklist ensuring adherence to coding standards, test validation, and build number increments.
- **Dedicated Category Catalogs (`docs/categories/`)**:
  - Generated 24 dedicated markdown catalogs under `docs/categories/` corresponding to each application classification.
  - Each catalog provides a filtered overview table, technical architecture summaries, database requirements, and direct links to individual application documentation.
- **Disclaimer & Limitation of Liability**:
  - Added comprehensive "AS IS", no-warranty, limitation of liability, and trademark disclaimer sections to `README.md`, `docs/INSTALLATION.md`, and CLI headers, emphasizing administrator backup obligations and non-affiliation with Virtualmin, Inc. or upstream projects.

### Changed
- **Vendor Neutrality & Documentation Cleanup**:
  - Removed `docs/ECOMMERCE_GUIDE.md` and sanitized all vendor-specific payment gateway references across the repository to maintain strict open-source neutrality.
- **Modular Directory in README.md**:
  - Updated the Classification Directory in `README.md` to link directly to the new dedicated category catalog pages.
  - Streamlined `README.md` by offloading verbose inline category tables to dedicated pages, improving readability and navigation.
- **Documentation & Clone Protocols**:
  - Updated [README.md](README.md) and [docs/INSTALLATION.md](docs/INSTALLATION.md) to use HTTPS clone URLs (`https://github.com/turajbjt/virtualminWebApps.git`) by default for universal server accessibility without requiring pre-authorized SSH keys.
  - Updated [README.md](README.md) badges with live GitHub Actions CI workflow status, direct license links, and catalog metric badges.

---

## [1.10.1] - 2026-11-17

### Security & Secret Leak Prevention
- **Repository-Wide `.gitignore` Hardening**:
  - Expanded `.gitignore` from 17 lines to 134 lines covering 6 critical security categories:
    - Cryptographic private keys and certificates (`*.pem`, `*.key`, `*.pk8`, `*.pfx`, `*.p12`, `*.csr`, `*.crt`).
    - SSH private and public keys (`id_rsa*`, `id_ecdsa*`, `id_ed25519*`, `known_hosts`, `authorized_keys`).
    - Environment and credential files (`*.env`, `.env.*`, `*.env.local`, `*.credential*`, `*.token*`, `*.secret*`).
    - Database dumps and sqlite data stores (`*.sql`, `*.sql.gz`, `*.sqlite`, `*.sqlite3`, `*.db`, `*.dump`).
    - Temporary, session, and cache files (`*.log`, `*.tmp`, `*.cache`, `sessions/`, `cookies.txt`).
    - Editor and IDE workspace metadata (`.vscode/`, `.idea/`, `.cursor/`, `*.swp`, `*.swo`).
- **Automated Secret Leakage Prevention Test Suite (`tests/08_secret_leak_prevention.t`)**:
  - Added 6 automated assertions executed during `./setup.sh test` and GitHub Actions CI:
    1. Verification of `.gitignore` existence.
    2. Coverage of all sensitive regex patterns in `.gitignore`.
    3. Traversal check on all `git ls-files` ensuring zero tracked sensitive extensions.
    4. Repository content scan ensuring zero private cryptographic key markers (`BEGIN ... PRIVATE KEY`).
    5. Content scan checking against known cloud/service token signatures (AWS, GitHub PAT/OAuth, GitLab, Google Cloud, Stripe Live, Slack).
    6. Exhaustive commit history audit (`git log --all --full-history`) ensuring no sensitive files were ever historically checked into git.
- **Test Suite Expansion**:
  - Expanded test suite from 1,035 to 1,041 automated unit, security, and PCI DSS compliance assertions across 8 test suites.

### Documentation
- **Catalog Reorganization in README.md**:
  - Replaced the flat unorganized table with a structured, 24-category catalog sorted alphabetically.
  - Added a high-level **Classification Directory** summary index with direct anchor jump links, app inventories, and category counts.
  - Organized all 69 applications into dedicated tables per classification with applications sorted alphabetically.

---

## [1.10.0] - 2026-11-17

### Security & PCI DSS Compliance
- **Path Traversal Defense (PCI DSS Req 6.5.8)**:
  - Integrated `VirtualminWebApps::Common::sanitize_path()` across all 52 directory-based web applications.
  - Strictly rejects `..` traversal sequences, poison null bytes (`\0`), backslashes, leading slashes, and shell metacharacters.
- **Cryptographically Secure PRNG (PCI DSS Req 8.3.6)**:
  - Replaced pseudo-random password generation across all installers with `VirtualminWebApps::Common::generate_random_key()`, reading from `/dev/urandom` with a minimum 16-character length and high-entropy mixed character pool.
- **Port Bounds & Injection Prevention (PCI DSS Req 6.5.1)**:
  - Enforced strict numeric validation (`1024-65535`) on all daemon and microservice ports via `VirtualminWebApps::Common::validate_port()`, blocking shell and SQL injection vectors.
- **Protection of Stored Authentication Data (PCI DSS Req 3.4)**:
  - Enforced restricted file permissions (`chmod 0600`) on all configuration files containing database passwords, encryption keys, and secrets (`.env`, `config.php`, `parameters.yml`).
- **HTTP Response Splitting & Header Injection Defense**:
  - `VirtualminWebApps::ProxyHelper` sanitizes proxy paths and rejects CRLF control characters.
- **Systemd Service Unit Sanitization**:
  - `VirtualminWebApps::SystemdHelper` strictly validates unit filenames against path traversal out of `/etc/systemd/system/`.

### Added
- **Automated Unit & Security Test Suite (1,035 Tests)**:
  - Created dedicated TAP test suite under `tests/`:
    - `tests/01_syntax.t`: Syntax verification across all 73 scripts and libraries.
    - `tests/02_common_lib.t`: 38 unit tests verifying `Common.pl` security and utility routines.
    - `tests/03_port_manager.t`: 8 unit tests verifying port detection and bounds safety.
    - `tests/04_systemd_helper.t`: 10 unit tests verifying service unit management and name sanitization.
    - `tests/05_proxy_helper.t`: 9 unit tests verifying Apache/Nginx proxy block generation and injection prevention.
    - `tests/06_app_metadata.t`: 690 unit tests verifying all metadata and lifecycle hooks across all 69 applications.
    - `tests/07_security_input_filtering.t`: 207 security tests fuzzing every application against path traversal, command injection, and invalid port inputs.
  - Integrated test suite directly into `./setup.sh test` and `.github/workflows/ci.yml`.

### Changed
- **Module Build Revision Bump**:
  - Incremented `script_<name>_release` from `1` to `2` across all 69 applications in adherence to the module versioning policy.

---

## [1.9.0] - 2026-11-17

### Added
- **GitHub Actions CI Workflow** (`.github/workflows/ci.yml`):
  - Automated continuous integration workflow executing on push and PR to `main` and `master`.
  - Performs syntax verification (`./setup.sh test`), catalog extraction (`./setup.sh list`), and symlink validation.
- **Installation Guide Expansion** (`docs/INSTALLATION.md`):
  - Thoroughly expanded Section 4 to reflect all 17 application categories across the entire 69-application suite.
- **Navidrome** (`apps/navidrome/`):
  - Modern Subsonic-compatible music streaming server and API backend in Go (v0.64.2).
  - Standalone compiled binary daemon with dynamic port allocation (`4533`), systemd service unit, and SSL reverse proxy.
- **FlatPress** (`apps/flatpress/`):
  - Classic lightweight flat-file blogging engine (v1.5.1) requiring zero SQL database.
  - Fast file-based storage, Smarty theming, RSS/Atom feeds, and automated setup wizard routing.
- **Monica PRM** (`apps/monica/`):
  - Personal Relationship Management (PRM) platform (v4.1.2) built on Laravel & PHP.
  - Automated MariaDB/MySQL database provisioning, `.env` generation, and security key generation.
- **Mattermost Team Edition** (`apps/mattermost/`):
  - High-performance team collaboration, messaging, and chat server in Go (v10.5.1).
  - Standalone daemon with systemd integration, dynamic port allocation (`8065`), MariaDB integration, and WebSocket reverse proxy.
- **Paperless-ngx** (`apps/paperless_ngx/`):
  - Community-driven document indexing, Optical Character Recognition (OCR), and archiving system (v3.5.0).
  - Isolated Podman/Docker container runtime, systemd service unit, dynamic port allocation (`8000`), and WebSocket reverse proxy.
- **Milestone 69**:
  - Suite expanded to 69 fully automated web application installers.
  - Syntax verification passed across all 73 Perl scripts and shared libraries.

---

## [1.8.0] - 2026-11-17

### Added
- **Chamilo LMS** (`apps/chamilo/`):
  - Enterprise-grade open-source Learning Management System (v3.0.2).
  - SCORM-compliant courses, skills management, automated testing, and virtual classrooms.
- **LinkStack** (`apps/linkstack/`):
  - Privacy-first open-source Linktree alternative (v4.8.8).
  - Customizable profile themes, privacy-preserving click stats, vCard sharing, and multi-user support.
- **Vikunja** (`apps/vikunja/`):
  - Modern cross-platform to-do list and task organizer (v2.8.0).
  - Standalone Go binary with embedded frontend, systemd service, and reverse proxy.
  - Kanban sprint boards, Gantt charts, subtasks, relations, and attachments.
- **Gotify** (`apps/gotify/`):
  - Self-hosted real-time push notification and messaging server (v3.1.1).
  - Standalone Go binary with WebSocket reverse proxying and official Android client support.
- **Miniflux** (`apps/miniflux/`):
  - Minimalist, fast, opinionated feed reader (v2.3.5).
  - Standalone Go binary with PostgreSQL database wiring, keyboard navigation, and Fever API support.
- **Microbin** (`apps/microbin/`):
  - Ultra-fast, lightweight encrypted pastebin and file sharer in Rust (v2.1.0).
  - Client-side encryption, burn-after-reading pastes, QR code sharing, and systemd service.
- **Milestone 64**:
  - Suite expanded to 64 fully automated web application installers.
  - Syntax verification passed across all 68 Perl scripts and shared libraries.

---

## [1.7.0] - 2026-11-17

### Added
- **DokuWiki** (`apps/dokuwiki/`):
  - Standards-compliant flat-file wiki (v2026-07-14c) requiring no SQL database.
  - Built-in ACL permissions, revision history, and extensive plugin support.
- **Adminer** (`apps/adminer/`):
  - Lightweight single-file database management tool (v4.8.1).
  - Multi-engine support (MySQL, MariaDB, PostgreSQL, SQLite) with instant deployment and zero overhead.
- **YOURLS** (`apps/yourls/`):
  - Self-hosted URL shortener (v1.10.6) with click tracking, geographic analytics, and developer REST API.
  - Automated configuration of database credentials and random cookie security salt.
- **EspoCRM** (`apps/espocrm/`):
  - Modern Single Page Application (SPA) CRM platform (v10.1.3).
  - Lead/opportunity pipelines, email sync, workflow automation, and mobile-optimized interface.
- **InvoicePlane** (`apps/invoiceplane/`):
  - Open-source invoicing, quotes, and client management platform (v1.6.1).
  - Multi-currency, tax rules, customizable PDF invoicing, and automated configuration.
- **Leantime** (`apps/leantime/`):
  - Strategic and agile project management system (v3.4.6).
  - Idea boards, Kanban boards, Gantt charts, milestone tracking, and integrated timesheets.
- **Milestone 58**:
  - Suite expanded to 58 fully automated web application installers.
  - Syntax verification passed across all 62 Perl scripts and shared libraries.

---

## [1.6.0] - 2026-11-17

### Added
- **SnappyMail** (`apps/snappymail/`):
  - Fast, modern, and lightweight webmail client (v3.0.1) engineered as an active fork of RainLoop.
  - Zero SQL database requirement; connects directly to local Virtualmin Dovecot/Postfix or remote IMAP/SMTP.
  - Built-in OpenPGP client-side encryption, Sieve filters, and dedicated administrator panel.
- **Piwigo** (`apps/piwigo/`):
  - Mature open-source photo gallery and digital asset management platform (v16.5.0).
  - Batch photo uploads, EXIF/IPTC metadata extraction, granular album permissions, and mobile sync support.
- **LimeSurvey** (`apps/limesurvey/`):
  - Leading open-source online statistical survey and questionnaire engine (v6.17.19).
  - 30+ advanced question types, conditional branching, participant tokens, and export to SPSS, R, CSV, and Excel.
- **MyBB** (`apps/mybb/`):
  - Full-featured community discussion board and forum system (v1.8.41).
  - Inline moderation, member reputation ratings, theme/plugin system, and automated unpack handling.
- **MantisBT** (`apps/mantisbt/`):
  - Web-based bug and issue tracking platform (v2.28.4).
  - Granular project access control, customizable issue states, email notifications, and REST/SOAP APIs.
- **Wallabag** (`apps/wallabag/`):
  - Self-hosted read-it-later article archiver (v2.6.17).
  - Distraction-free article extraction, offline e-reader export (EPUB/PDF/MOBI), and browser/mobile sync.
- **Milestone 52**:
  - Suite expanded to 52 fully automated web application installers.
  - Syntax verification passed across all 56 Perl scripts and shared libraries.

---

## [1.5.0] - 2026-11-17

### Added
- **FreshRSS** (`apps/freshrss/`):
  - Self-hosted RSS/Atom feed aggregator (v1.24.3) with multi-user accounts and mobile API support.
- **Shaarli** (`apps/shaarli/`):
  - Minimalist personal bookmarking and link-sharing service (v0.16.10) with flat-file storage.
- **Lychee** (`apps/lychee/`):
  - Modern self-hosted photo management system and album gallery (v7.13.0) with automated Laravel environment configuration.
- **Baikal** (`apps/baikal/`):
  - Lightweight CalDAV & CardDAV server (v0.13.0) for cross-device calendar and contacts synchronization.
- **Grav CMS** (`apps/grav/`):
  - High-speed flat-file CMS (v2.2.30) pre-packaged with the Grav Admin Panel.
- **Firefly III** (`apps/firefly_iii/`):
  - Free and open-source personal finances manager (v6.7.9) with automated encryption key and database provisioning.
- **Milestone 46**:
  - Suite expanded to 46 fully automated web application installers.
  - Updated `README.md`, `ROADMAP.md`, and `docs/APPLICATIONS.md`.

---

## [1.4.0] - 2026-11-17

### Added
- **Roundcube Webmail** (`apps/roundcube/`):
  - Browser-based multilingual IMAP webmail client (v1.6.9).
  - Automated MariaDB schema import, DES encryption key generation, and local Dovecot/Postfix integration.
- **phpMyAdmin** (`apps/phpmyadmin/`):
  - The premier web-based MySQL/MariaDB database administration tool (v5.2.1).
  - Automated Blowfish secret generation and dedicated template cache folder.
- **PrivateBin** (`apps/privatebin/`):
  - Zero-knowledge 256-bit AES-GCM encrypted pastebin (v2.1.1).
  - Client-side encryption ensures the server has zero visibility into pasted content.
- **Kanboard** (`apps/kanboard/`):
  - Minimalist visual Kanban project management tool (v1.2.40).
  - Zero-configuration SQLite backend by default or optional MariaDB.
- **Trilium Notes** (`apps/trilium/`):
  - Hierarchical personal knowledge base and note-taking server (v0.95.0).
  - Standalone bundled Node.js server binary with dedicated systemd service and reverse proxying with WebSockets.
- **Netdata Monitoring** (`apps/netdata/`):
  - Real-time infrastructure observability and metrics dashboard.
  - Isolated system daemon with automated Apache/Nginx reverse proxying to port 19999.
- **Documentation Expansion**:
  - Updated `README.md`, `ROADMAP.md`, and `docs/APPLICATIONS.md` to catalog all 40 applications.

---

## [1.3.0] - 2026-11-17

### Added
- **osCommerce Installer** (`apps/oscommerce/`):
  - Added support for osCommerce v4 Community Edition.
  - Configured database provisioning and permission hardening.
- **SuiteCRM Installer** (`apps/suitecrm/`):
  - Enterprise Customer Relationship Management (CRM) platform (version 8.10.2).
  - Open-source replacement for enterprise CRM offerings in Virtualmin Pro.
- **Moodle LMS Installer** (`apps/moodle/`):
  - World-leading Learning Management System (LMS) version 4.4.4.
  - Hardened automated data directory configuration (`$HOME/moodledata`) placed outside the public web root.
- **Passbolt Password Manager** (`apps/passbolt/`):
  - OpenPGP-based team password and credential manager version 5.18.0.
  - Automated permissions for CakePHP tmp/cache paths.
- **CyberChef Installer** (`apps/cyberchef/`):
  - GCHQ's "Cyber Swiss Army Knife" client-side security and data analysis web tool (version 11.5.0).
  - Client-side execution with zero backend/database dependencies.
- **IT-Tools Installer** (`apps/it_tools/`):
  - Useful suite of developer and sysadmin tools (token generators, regex testers, converters, formatters).
  - Client-side static assets with zero backend/database dependencies.
- **Updated Reference Manual**:
  - Expanded `docs/APPLICATIONS.md` to cover all 34 web applications.

---

## [1.2.0] - 2026-11-17

### Added
- **Invoice Ninja** (`apps/invoiceninja/`): Laravel-powered invoicing, payments, and expense tracking with cron task automation.
- **Ghost** (`apps/ghost/`): Node.js modern blogging and newsletter publishing engine with dedicated systemd service and reverse proxying.
- **Drupal** (`apps/drupal/`): Enterprise PHP/MariaDB content management system (v10.3.5) with automated hash salt generation.
- **Joomla!** (`apps/joomla/`): Mobile-ready content management system (v5.1.4).
- **phpBB** (`apps/phpbb/`): Classic community bulletin board forum (v3.3.13).
- **Umami Analytics** (`apps/umami/`): Modern privacy-friendly Google Analytics alternative with systemd service and reverse proxying.

---

## [1.1.0] - 2026-11-17

### Added
- **Core Priority 1**: Vaultwarden (Rust Bitwarden server with WebSocket synchronization and SSL reverse proxy).
- **Core Priority 2**: AdGuard Home (Go DNS ad/tracker blocker) and Pi-hole (DNS sinkhole).
- **Cloud Collaboration**: Nextcloud Hub and ownCloud Classic with automated `occ` setup.
- **E-Commerce Suite**:
  - WooCommerce (WordPress WP-CLI bundle)
  - OpenCart (CLI automated database setup)
  - PrestaShop & Thirty Bees (`index_cli.php` automation)
  - AbanteCart
  - FOSSBilling
  - Zen Cart
  - LiteCart
  - CubeCart
- **Wikis & Analytics**:
  - MediaWiki & BookStack
  - Matomo Analytics (Piwik)
  - Dolibarr ERP & CRM
  - Flarum Forum
  - Forgejo Git
  - File Browser lightweight web manager
  - Uptime Kuma monitoring dashboard
- **Shared Perl Helper Libraries**:
  - `lib/Common.pl`: Resilient downloads, multi-format extraction, ownership, arch detection.
  - `lib/PortManager.pl`: TCP port conflict detection and dynamic allocation.
  - `lib/SystemdHelper.pl`: Systemd unit templating, reloading, and lifecycle management.
  - `lib/ProxyHelper.pl`: Automated Apache & Nginx reverse proxy configuration with WebSocket support.
- **Management CLI (`setup.sh`)**:
  - Commands: `install`, `update`, `remove`, `status`, `list`, `test`.
  - Dynamic module parsing and formatting.

---

## [1.0.0] - 2026-11-17

### Initial Release
- Project monorepo architecture and Virtualmin custom script subsystem integration.
- Module Build Number revision tracking policy (`script_<name>_release`).
