# Developer Guide: Creating Web App Modules for Virtualmin

This guide describes how to author new web application installers for the **Virtualmin Web Apps Suite**.

---

## 1. Directory Structure

Each web application must be created as an independent, self-contained directory under `apps/<app_name>/`:

```text
apps/<app_name>/
├── <app_name>.pl            # Mandatory: Virtualmin install script lifecycle module
├── <app_name>.service       # Optional: Systemd unit template (if daemon-based)
└── README.md                # Mandatory: Application overview, ports, and documentation
```

---

## 2. Module Build vs. Upstream Versioning Policy

Every installer module in this repository tracks two distinct version numbers:
1. **App Version (`script_<app_name>_versions`)**: The upstream software version being installed (e.g. Nextcloud `30.0.6`, OpenCart `4.0.2.3`, PrestaShop `8.1.7`).
2. **Module Build Number (`script_<app_name>_release`)**: An integer representing the revision of our Virtualmin installer module itself.

> **CRITICAL RULE**: Whenever you make **ANY** modification, fix, security tweak, or enhancement to an application's script (`<app_name>.pl`) or associated service template, you **MUST** increment its `script_<app_name>_release` integer by 1 (e.g., from `1` to `2`).
>
> This allows server administrators to immediately determine whether an installer is up-to-date by running `./setup.sh list` or inspecting Virtualmin's script manager.

---

## 3. Virtualmin Script Lifecycle API

Virtualmin's installer engine loads `<app_name>.pl` and invokes standard lifecycle subroutines prefixed with `script_<app_name>_`.

### Required Metadata Hooks

```perl
# Description shown in Virtualmin Web Apps list
sub script_my_app_desc
{
    return "My Awesome App";
}

# Features required from the virtual server (e.g. php, mysql, postgres, ssl, proxy)
sub script_my_app_uses
{
    return ( "php", "mysql" );
}

# Category under which the script appears (e.g. Commerce, Cloud, Security, System, CMS)
sub script_my_app_category
{
    return "Commerce";
}

# Author or project maintainer
sub script_my_app_author
{
    return "App Community";
}

# Official project website
sub script_my_app_site
{
    return "https://example.com";
}

# Supported version strings
sub script_my_app_versions
{
    return ( "1.2.0", "1.1.0" );
}

# Script release revision (Module Build Number)
# MANDATORY: Increment this integer every time changes/fixes are made to this module!
sub script_my_app_release
{
    return 1;
}

# Password handling mode:
# 0 = Virtualmin passes plain password to install hook
# 1 = Encrypted / MD5 hash
# 2 = Web app manages accounts internally
sub script_my_app_passmode
{
    return 0;
}
```

---

### Installation UI & Parameter Hooks

#### `script_<app_name>_params(&domain)`
Returns HTML table rows (`<tr>...</tr>`) to render custom installation options in the Virtualmin interface.
```perl
sub script_my_app_params
{
    my ($d) = @_;
    my $html = "";
    $html .= "<tr> <td><b>Install Directory</b></td> <td>";
    $html .= "<input name=\"my_app_dir\" size=\"20\" value=\"shop\"></td> </tr>";
    return $html;
}
```

#### `script_<app_name>_parse(&domain, &in)`
Validates the user's form inputs. Returns an error string if invalid, or a reference to a hash of clean options.
```perl
sub script_my_app_parse
{
    my ($d, $in) = @_;
    my $dir = $in->{'my_app_dir'} || '';
    $dir =~ s/^\///;
    $dir =~ s/\/$//;
    return { 'dir' => $dir };
}
```

#### `script_<app_name>_check(&domain, $version, $dbtype, $dir)`
Runs pre-flight requirement checks (RAM, architecture, PHP version, open ports). Returns an error message string if checks fail, or `undef` on success.

---

### Execution Hooks

#### `script_<app_name>_install(&domain, $version, $options, $defs, $setup)`
Executes the installation.
* `$d`: Domain metadata reference (`$d->{'dom'}`, `$d->{'home'}`, `$d->{'user'}`, `$d->{'ssl'}`).
* `$ver`: Chosen version string.
* `$opts`: Options parsed from `script_<app_name>_parse`.
* `$defs`: Database credentials allocated by Virtualmin (`$defs->{'db'}`, `$defs->{'user'}`, `$defs->{'pass'}`, `$defs->{'host'}`).
* `$setup`: Execution mode flags.

**Return value on success:**
```perl
return (1, $access_url, $status_description_message);
```
**Return value on failure:**
```perl
return (0, $error_message);
```

#### `script_<app_name>_uninstall(&domain, $version, $options)`
Handles clean removal of files, systemd services, cron jobs, or reverse proxy rules.

#### `script_<app_name>_upgrade(&domain, $version, $options)`
Performs automated version upgrades when a newer version is selected in the UI.

---

## 3. Using Shared Helper Libraries

Always include the shared libraries at the top of your script:

```perl
use strict;
use warnings;
use File::Basename;

BEGIN {
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib" if -d "$dir/lib";
    unshift @INC, "$dir/../../lib" if -d "$dir/../../lib";
    unshift @INC, "$dir/../lib" if -d "$dir/../lib";
}

require "Common.pl";
require "PortManager.pl";
require "SystemdHelper.pl";
require "ProxyHelper.pl";
```

### Key Shared Routines:
* `VirtualminWebApps::Common::download_url($url, $destination, [$timeout])`
* `VirtualminWebApps::Common::extract_archive($archive, $dest_dir, [$strip_components])`
* `VirtualminWebApps::Common::set_ownership_recursive($path, $user, $group)`
* `VirtualminWebApps::Common::get_arch()` (returns `amd64`, `arm64`, or `armv7`)
* `VirtualminWebApps::PortManager::find_free_port($start, $max)`
* `VirtualminWebApps::SystemdHelper::create_service_unit($service_name, $content)`
* `VirtualminWebApps::SystemdHelper::remove_service_unit($service_name)`
* `VirtualminWebApps::ProxyHelper::setup_reverse_proxy($d, $app_name, $port, $websocket, $path)`
* `VirtualminWebApps::ProxyHelper::remove_reverse_proxy($d, $app_name)`

---

## 4. Verification & Testing

Always test your new application script with the suite testing tool before committing:
```bash
./setup.sh test
```
To verify that your app displays correctly in the inventory table:
```bash
./setup.sh list
```
