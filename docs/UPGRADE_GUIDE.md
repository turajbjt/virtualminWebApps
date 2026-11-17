# Upgrades & Maintenance Guide

This document describes how to update the **Virtualmin Web Apps Suite** installer catalog and how to upgrade web applications already deployed on your virtual servers.

---

## 1. Overview of the Two Upgrade Tiers

When managing web apps on Virtualmin, upgrades occur at two distinct levels:

1. **Installer Suite Level**: Updating the repository on your server so Virtualmin knows about new applications, bug fixes, and incremented module **Build** numbers.
2. **Domain Application Level**: Upgrading software that has already been installed on an active domain (e.g. Nextcloud, Vaultwarden, PrestaShop).

```
[ GitHub Repo ] ──( setup.sh update )──> [ Virtualmin Host Catalog ] ──( Upgrade Now )──> [ Domain Web App ]
```

---

## 2. Tier 1: Updating the Installer Suite (`setup.sh update`)

To update the installer catalog on your server, run **a single command**:

```bash
sudo /opt/virtualminWebApps/setup.sh update
```

### What `setup.sh update` Does Under the Hood:
1. **Pulls Latest Commits**: Automatically executes `git pull --rebase` to fetch any new or updated files from GitHub.
2. **Synchronizes Scripts**: Detects any newly added applications in `apps/` and regenerates the symlinks inside the active `scripts/` directory.
3. **Refreshes Virtualmin**: Restarts the Webmin daemon so the Virtualmin interface immediately registers the updated app versions and incremented build numbers.

### Verifying the Update
Run `./setup.sh list` from the repository root:
```bash
/opt/virtualminWebApps/setup.sh list
```
The table will display the current **VERSION** and **BUILD** number for every installed script.

---

## 3. Tier 2: Upgrading Applications on Your Virtual Servers

Once Virtualmin has loaded the updated scripts, Virtualmin's script manager automatically compares installed instances against the catalog and identifies available updates.

### Method A: Via the Virtualmin Web GUI (Recommended)

1. Log into your Virtualmin dashboard (`https://your-server:10000`).
2. Select the target Virtual Server from the dropdown menu.
3. In the left navigation, click **Manage Web Apps** (or **Install Scripts**).
4. Click on the **Installed Scripts** tab at the top.
5. Virtualmin displays a table of all applications installed on this domain.
   * If a new version or installer build is available, Virtualmin marks it with an **Upgrade available** notice.
6. Click on the application name, review the upgrade notes, and click **Upgrade Now**.
7. Virtualmin will execute the script's `script_<name>_upgrade` hook to pull the latest images/files, update configs, and run database migrations.

---

### Method B: Via the Virtualmin Command Line (Batch Upgrades)

Virtualmin provides native command-line tools to upgrade installed scripts without logging into the web interface.

#### Upgrade an application on a specific domain:
```bash
virtualmin upgrade-script --domain example.com --script vaultwarden
```

#### Upgrade all installed web apps across all domains in one shot:
```bash
virtualmin upgrade-script --all-domains --all-scripts
```

#### Check which domains have upgrades pending:
```bash
virtualmin list-scripts --all-domains
```

---

## 4. Automated Recurring Updates (Cron)

If you want your Virtualmin server to automatically pull the latest installer builds every week, configure a root cron job:

```bash
sudo crontab -e
```

Add the following entry (runs weekly on Sunday at 3:00 AM):
```cron
0 3 * * 0 /opt/virtualminWebApps/setup.sh update >/dev/null 2>&1
```

With this cron job active, your Virtualmin catalog stays permanently fresh, and you will see upgrade notifications appear automatically in your Virtualmin interface whenever new application versions or module builds are released.
