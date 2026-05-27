# LAMP Stack Server Runbook

This directory contains production installation guides, system hardening runsheets, and reference documentation for the LAMP stack infrastructure environment.

## 1. Sequence of Setup Operations

| Order | Runbook File | Focus Area |
| --- | --- | --- |
| **0** | `0-server_setup-v1.md` | Core OS initialization and base hardening. |
| **1** | `1-composer-setup-and-dependency-management.md` | PHP dependency architecture and tools. |
| **2** | `2-setup-ssh-tunnel-for-development.md` | Secure remote access mechanics. |
| **3** | `3-ftp-setup.md` | Hardened FTPS deployment with PAM virtual users. |
| **4** | `4-subdomain-configuration.md` | Virtual host configurations. |
| **5** | `5-phpMyAdmin-setup.md` | Database control and security. |
| **6** | `6-ssl-tls-management.md` | Certificate Setup. |

---

## 2. Resources & System References (`RES_*`)

* **`RES_linux-sysadmin-cheatsheet.md`**: Commands and runtime metrics.
* **`RES_log-rotation.md`**: Log rotation storage policies (`logrotate`).
* **`RES_logs.md`**: Critical service log map filepaths.
* **`RES_mysql-users.md`**: Access control and privileges.
* **`RES_required-packages.md`**: Core manifest list.
* **`RES_sqlite3-setup.md`**: SQLite configuration.
