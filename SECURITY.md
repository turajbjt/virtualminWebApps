# Security Policy

The **Virtualmin Web Apps Suite** is built with strict adherence to security best practices, safe systems programming, and PCI DSS v4.0 standards. Because this software automates the deployment of web applications, systemd services, web server reverse proxies, and database credentials with root administrative privileges, security is treated with the highest priority.

---

## Supported Versions

Only the latest release and the current `main` branch receive active security patches.

| Version | Supported | Notes |
| :--- | :---: | :--- |
| `1.11.x` | :white_check_mark: | Current stable public release |
| `1.10.x` | :white_check_mark: | PCI DSS compliance & secret scanning milestone |
| `< 1.10.0` | :x: | Legacy development builds (upgrade recommended) |

---

## Reporting a Vulnerability

If you discover a potential security vulnerability within this repository, its shared libraries (`lib/`), CLI tools (`setup.sh`), or any of the 69 application installer scripts (`apps/`), please report it responsibly.

### Responsible Disclosure Process

1. **Private GitHub Security Advisory (Preferred)**:
   * Navigate to the **Security** tab of the repository on GitHub: [Security Advisories](https://github.com/turajbjt/virtualminWebApps/security/advisories).
   * Click **Report a vulnerability** to submit a private report directly to the maintainers.

2. **Email Disclosure**:
   * If you cannot use GitHub Security Advisories, send an encrypted or direct email to the repository owner with the subject line: `[SECURITY] Virtualmin Web Apps Suite Vulnerability Report`.

### Please Include in Your Report:
* A detailed description of the vulnerability and attack vector.
* The affected component (`setup.sh`, `lib/Common.pl`, `apps/<name>/`, etc.).
* Step-by-step reproduction instructions or a minimal proof of concept (PoC).
* Potential impact (e.g., privilege escalation, path traversal, arbitrary command execution, credential leakage).
* Any proposed mitigations or fixes if available.

### What NOT to Do:
* **Do NOT open a public GitHub issue** for undisclosed vulnerabilities.
* **Do NOT publicly disclose** or discuss details of the vulnerability until a fix has been released.

---

## Response Commitments & SLA

* **Initial Acknowledgment**: Within **48 hours** of report receipt.
* **Triage & Severity Assessment**: Within **5 business days**, including CVSS scoring.
* **Remediation & Patch**: Target delivery of a security fix within **14 business days** for high or critical vulnerabilities.
* **Public Disclosure & Credit**: We will publish a GitHub Security Advisory crediting the finder once a patch is tested and merged.

---

## Architecture & PCI DSS Security Controls

The codebase enforces the following programmatic defenses across all installers:

1. **Strict Path Traversal Defense (PCI DSS Req 6.5.8)**:
   * All installation paths are validated with `VirtualminWebApps::Common::sanitize_path()`, rejecting directory traversal (`..`), poison null bytes (`\0`), leading slashes, and shell metacharacters.
2. **Cryptographically Secure Random Generation (PCI DSS Req 8.3.6)**:
   * Secret keys and passwords are generated using `VirtualminWebApps::Common::generate_random_key()` reading directly from `/dev/urandom` with a minimum 16-character length and high-entropy character space.
3. **Protection of Stored Authentication Data (PCI DSS Req 3.4)**:
   * Configuration files containing database passwords, encryption keys, and secrets are locked to `0600` permissions (`u=rw,go=`) under the domain owner.
4. **Port Bounds & Injection Prevention (PCI DSS Req 6.5.1)**:
   * All microservice and daemon ports are strictly validated within the non-privileged numeric range (`1024-65535`).
5. **Zero Secret Leakage Policy**:
   * Automated CI secret scanning (`tests/08_secret_leak_prevention.t`) and a comprehensive `.gitignore` prevent tracking of keys, certificates, dumps, or tokens.
