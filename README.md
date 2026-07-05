# Atlas Bootstrap

Atlas Bootstrap provisions Atlas Linux systems from a clean operating system installation.

Its purpose is to provide a repeatable, documented, and maintainable baseline for Project Atlas machines.

Atlas Bootstrap answers one question:

> How do I turn a fresh Debian installation into an Atlas node?

---

# Scope

Atlas Bootstrap is responsible for:

- installing baseline packages
- configuring shell defaults
- configuring SSH access
- configuring Tailscale
- installing Atlas helper commands
- preparing common system services

Atlas Bootstrap is not the primary documentation repository for Project Atlas.

Project philosophy, architecture, standards, and engineering history live in the atlas-handbook repository.

---

# Supported Platforms

Primary targets include:

- Debian 13
- Raspberry Pi OS (Debian-based)

Additional platforms may be supported as Project Atlas evolves.

---

# Repository Structure

```text
atlas-bootstrap/
├── bin/
├── config/
│   └── packages/
│       └── base.txt
├── scripts/
├── shell/
├── systemd/
├── templates/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

# Current Status

Atlas Bootstrap is in early development.

The initial milestone is Bootstrap v0.1: a simple, reliable provisioning workflow for a fresh Debian installation.

---

# Planned Usage

```bash
git clone <repository-url>
cd atlas-bootstrap
./scripts/bootstrap.sh
```
