# CyberChef Virtualmin Installer

**CyberChef** is the "Cyber Swiss Army Knife" — a simple, intuitive web app for carrying out all manner of "cyber" operations within a web browser, including encoding, decoding, encryption, decryption, parsing data formats, regex, decompression, and hashing.

## Architecture
- **Language**: Pure client-side HTML5 & JavaScript (WebAssembly)
- **Database**: None required
- **Requirements**: Any web server (Apache or Nginx) serving static assets. Zero server-side compute.

## Installation
Installed via Virtualmin Webmin GUI under **Server Configuration -> Manage Web Apps -> CyberChef** or using the CLI:
```bash
./setup.sh install
```
Default installation directory: `/cyberchef` or document root.
