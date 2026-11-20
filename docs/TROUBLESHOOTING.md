# Troubleshooting & Operational Guide

This document covers common questions, edge cases, and troubleshooting steps for applications managed by the **Virtualmin Web Apps Suite**.

---

## 1. Webmin Not Showing Custom Scripts

### Symptoms
After running `sudo ./setup.sh install`, the new applications do not appear under **Manage Web Apps / Install Scripts**.

### Solution
1. **Verify the Custom Scripts Directory**:
   Virtualmin natively discovers custom third-party scripts from `/etc/webmin/virtual-server/scripts/`. Verify that the symlinks exist:
   ```bash
   ls -la /etc/webmin/virtual-server/scripts/
   ```
   Ensure both the `.pl` files and the `lib` directory symlink are present.

2. **Verify with the Virtualmin CLI**:
   Run the native Virtualmin script audit:
   ```bash
   virtualmin list-available-scripts --source custom
   ```
   All 87 applications should be displayed as available.

3. **Check the Available Scripts Tab in the Web GUI**:
   In the Virtualmin Web GUI:
   - Select your virtual server (domain).
   - Go to **Manage Web Apps** (or **Install Scripts**).
   - Click the **Available Scripts** (or **Install Script**) tab. *(Note: If any application is already installed on the virtual server, Virtualmin opens to the "Installed Scripts" tab by default).*

4. **Check for Default-Deny Policies**:
   If your server restricts script availability globally:
   ```bash
   grep "denydefault" /etc/webmin/virtual-server/scriptsunavail
   ```
   If set to `1`, ensure scripts are enabled under **Virtualmin -> System Settings -> Script Installers** or re-run `sudo ./setup.sh install` which automatically whitelists them.

5. **Restart Webmin**:
   ```bash
   sudo systemctl restart webmin
   ```
6. Clear your browser cache or log out and back in to Webmin to refresh the cached navigation tree.

---

## 2. Reverse Proxy & Port Conflicts

### Symptoms
Daemon-based applications (Vaultwarden, AdGuard Home, Pi-hole) fail to start or display `502 Bad Gateway`.

### Diagnostics & Solution
1. Check the status of the application's systemd unit:
   ```bash
   sudo systemctl status <app_name>-<domain>.service
   # Example:
   sudo systemctl status vaultwarden-example.com.service
   ```
2. Check if the configured local port is already bound by another process:
   ```bash
   sudo ss -tulpn | grep :<port>
   ```
3. Check the web server error logs:
   * **Apache**: `/var/log/httpd/error_log` or `/var/log/apache2/error.log`
   * **Nginx**: `/var/log/nginx/error.log`
   * **Per-Domain**: `/home/<domain>/logs/error_log`

---

## 3. SELinux Restrictions (RHEL / Rocky / AlmaLinux / Fedora)

### Symptoms
Apache or Nginx returns `503 Service Unavailable` or `13: Permission denied` when attempting to proxy connections to local ports.

### Solution
On Red Hat enterprise systems, SELinux by default prevents web servers from connecting to external or local network sockets. Enable the network connect boolean:

```bash
sudo setsebool -P httpd_can_network_connect 1
```

If the service binds to custom non-standard ports:
```bash
sudo semanage port -a -t http_port_t -p tcp <port>
```

---

## 4. Bitwarden / Vaultwarden Web Crypto Error

### Symptoms
The Vaultwarden web interface opens, but shows an error:
> *"This browser requires HTTPS to perform cryptographic operations."*

### Cause & Solution
Bitwarden and Vaultwarden rely on the browser's native `window.crypto.subtle` API. Modern web browsers strictly disable cryptographic operations on unencrypted plain HTTP connections.
* **Fix**: You must generate an SSL/TLS certificate for the virtual server. In Virtualmin, navigate to **Server Configuration -> SSL Certificate -> Let's Encrypt** and request a free Let's Encrypt certificate.

---

## 5. DNS Port 53 Conflicts (AdGuard Home / Pi-hole)

### Symptoms
AdGuard Home or Pi-hole fails to bind port 53 because `systemd-resolved` or `named` (BIND) is already listening on `0.0.0.0:53`.

### Solutions
* **Option A**: If BIND DNS is running on the Virtualmin host for hosting DNS records, configure AdGuard Home / Pi-hole to listen on a secondary IP address or alternate port.
* **Option B**: If `systemd-resolved` is holding port 53 on Ubuntu/Debian:
  1. Edit `/etc/systemd/resolved.conf`:
     ```ini
     [Resolve]
     DNSStubListener=no
     ```
  2. Restart resolved:
     ```bash
     sudo systemctl restart systemd-resolved
     ```
