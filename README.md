# Virtualmin Web Apps Suite

A modular, extensible repository of modern open-source web application installers for [Virtualmin](https://www.virtualmin.com/) ("Manage Web Apps" / Install Scripts).

This suite provides a collection of 1-click web applications that run directly on Virtualmin servers, including:
1. **Self-hosted Daemons & Microservices** (Vaultwarden, AdGuard Home, Pi-hole) running as isolated systemd services behind automated Apache/Nginx reverse proxies.
2. **Cloud & Collaboration Hubs** (Nextcloud, ownCloud Classic).
3. **E-Commerce & Shopping Carts** (OpenCart, PrestaShop, Thirty Bees, AbanteCart - with full PlugnPay compatibility).
4. **Virtualmin Pro Replacements** providing enterprise FOSS alternatives without requiring commercial licenses.

---

## Quick Start: Adding to your Virtualmin Server

On your Virtualmin server, clone this repository and run the setup script as root:

```bash
git clone https://github.com/<your-username>/virtualminWebApps.git /opt/virtualminWebApps
cd /opt/virtualminWebApps
sudo ./setup.sh install
```

That's it! The CLI will:
1. Configure `custom_scripts_dir` in `/etc/webmin/virtual-server/config`.
2. Synchronize all application scripts and shared libraries into the active scripts path.
3. Automatically restart Webmin so the new applications appear immediately in the Virtualmin interface.

Once installed, log into your Virtualmin admin dashboard and navigate to:
**Virtualmin -> [Select Virtual Server] -> Manage Web Apps / Install Scripts**
You will see the new applications available under their respective categories.

---

## CLI Management (`./setup.sh`)

The repository includes a management CLI (`setup.sh`) for server management:

| Command | Action |
| :--- | :--- |
| `sudo ./setup.sh install` | Registers and connects the suite into Virtualmin's custom scripts directory. |
| `sudo ./setup.sh update` | Pulls latest Git commits, regenerates script links, and reloads Webmin. |
| `sudo ./setup.sh remove` | Safely unhooks the suite from Virtualmin configuration. |
| `./setup.sh list` | Displays a table of all available web applications, categories, and versions. |
| `./setup.sh status` | Checks Webmin/Virtualmin installation status and active script paths. |
| `./setup.sh test` | Runs Perl syntax and integrity checks (`perl -cw`) across all scripts and libraries. |

---

## Current Applications

Run `./setup.sh list` to view installed modules:

```text
APPLICATION          CATEGORY        VERSION      DESCRIPTION                             
------------------------------------------------------------------------------------------------
vaultwarden          Security        1.32.7       Vaultwarden Password Manager            
adguard_home         System          0.107.80     AdGuard Home DNS & Ad Blocker           
pihole               System          latest       Pi-hole Network-wide Ad Blocker         
nextcloud            Cloud           30.0.6       Nextcloud Cloud & Collaboration Hub     
owncloud             Cloud           10.13.4      ownCloud Classic Cloud Platform         
opencart             Commerce        4.0.2.3      OpenCart E-Commerce Platform            
prestashop           Commerce        8.1.7        PrestaShop E-Commerce Platform          
thirtybees           Commerce        1.7.0        Thirty Bees High-Performance E-Commerce 
abantecart           Commerce        1.4.1        AbanteCart E-Commerce Platform          
```

---

## Architecture & How It Works

### Application Structure
Each application is self-contained in its own directory under `apps/<app_name>/`:
```text
apps/<app_name>/
├── <app_name>.pl       # Virtualmin lifecycle hooks (desc, params, check, install, uninstall)
├── <app_name>.service  # (Optional) Systemd service unit template for daemons
└── README.md           # Application-specific documentation and defaults
```

### Shared Helper Libraries (`lib/`)
Shared modules ensure consistency and avoid duplicate code:
* `Common.pl`: Network downloads (curl/wget), archive unpacking (tar/zip), file permissions, and architecture detection.
* `PortManager.pl`: Dynamic discovery and allocation of available TCP ports (preventing port collisions on multi-tenant servers).
* `SystemdHelper.pl`: Automated creation, daemon-reload, enablement, and lifecycle control for systemd services.
* `ProxyHelper.pl`: Dynamic Apache and Nginx reverse proxy configuration, supporting HTTP forwarding, SSL certificates, and WebSocket upgrades (`/notifications/hub`).

---

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the complete list of upcoming applications across CMS, Wikis, Forums, Analytics, and developer tools.
