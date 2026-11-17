## Description

Brief summary of the changes introduced by this pull request.

## Type of Change

- [ ] New Web Application Installer (under `apps/<name>/`)
- [ ] Bug fix in existing application or helper library
- [ ] New feature / enhancement in `setup.sh` CLI or `lib/`
- [ ] Security fix / PCI DSS compliance hardening
- [ ] Documentation update

## Checklist

- [ ] My code adheres to the coding and security standards outlined in [CONTRIBUTING.md](CONTRIBUTING.md).
- [ ] If modifying an existing application, I have incremented its `script_<name>_release` module build number.
- [ ] If adding a new application, I have created `apps/<name>/<name>.pl`, `apps/<name>/README.md`, and any necessary `.service` templates.
- [ ] I have run `./setup.sh update` to regenerate script symlinks.
- [ ] I have run `./setup.sh test` and all unit, security, and syntax tests pass with zero failures.
- [ ] I have verified that no sensitive credentials, API keys, or private keys are committed (`08_secret_leak_prevention.t`).
- [ ] I have updated [CHANGELOG.md](CHANGELOG.md) to document these changes.
