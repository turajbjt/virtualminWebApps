# IT-Tools Virtualmin Installer

**IT-Tools** is a collection of handy online tools for developers and system administrators, including token generators, hash checkers, UUID generators, regex testers, JSON formatters, Base64 converters, and network calculators.

## Architecture
- **Language**: Pure client-side HTML5 & Vue.js / Vite build
- **Database**: None required
- **Requirements**: Any web server (Apache or Nginx) serving static assets. Zero server-side compute.

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> IT-Tools** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/it-tools` or document root.
