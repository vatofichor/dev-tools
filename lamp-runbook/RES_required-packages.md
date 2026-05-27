# Required Packages & Modules

Below is the consolidated database of all required packages, runtime extensions, and core utilities referenced across the server setup, automation, and diagnostics documentation.

| Category | Package Name | Core Service / Target |
| :--- | :--- | :--- |
| **Core Web & DB** | `apache2` | Apache HTTP Web Server |
| | `mysql-server` | MySQL Relational Database Engine |
| | `php` | PHP Hypertext Preprocessor Core |
| **PHP Extensions** | `libapache2-mod-php` | Apache PHP integration module |
| | `php-cli` | Command-line interface for PHP administrative tasks |
| | `php-mysql` | MySQL driver linkage for database connections |
| | `php-mbstring` | Multi-byte character handling (required for frameworks / phpMyAdmin) |
| | `php-xml` | XML parsing and SOAP service support |
| | `php-curl` | HTTP network request/response APIs |
| | `php-zip` | Zip file compression extraction engine support |
| | `php-intl` | Internationalization parsing frameworks support |
| | `php-bcmath` | Arbitrary precision mathematics package |
| | `php-gd` | Image generation and processing library |
| | `php-sqlite3` | SQLite3 database driver |
| | `phpmyadmin` | Web-based MySQL administration interface database tool |
| **Security & IAM** | `openssh-server` | Secure Remote Shell Daemon & tunneling services |
| | `ufw` | Uncomplicated Firewall (Host Network Perimeter) |
| | `fail2ban` | Intrusion prevention framework (scans logs & bans brute-forcers) |
| | `openssl` | TLS/SSL Cryptographic Toolkit |
| | `libpam-pwdfile` | PAM Module for virtual user password file authentication |
| | `apache2-utils` | Apache administration utilities (contains `htpasswd`) |
| **SSL Automation** | `certbot` | Let's Encrypt automated TLS certificate manager |
| | `python3-certbot-apache` | Apache plugin for Certbot (automated vhost rewrites) |
| | `python3-certbot-dns-digitalocean` | DigitalOcean DNS plugin for DNS-01 challenges (Wildcard certificates) |
| **File Management** | `vsftpd` | Very Secure FTP Daemon |
| | `sqlite3` | SQLite3 command-line interface & engine |
| | `unzip` | Standard decompression zip utility |
| | `curl` | Command-line HTTP transfer client |
| **Diagnostics** | `htop` | Interactive real-time process system monitor |
| | `net-tools` | Traditional network utilities (includes `netstat`) |
| | `dnsutils` | DNS testing tools (includes `dig`, `nslookup`) |
| | `autossh` | Automated SSH session persistence & tunnel monitoring |

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
