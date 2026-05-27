# Hardened Linux Systems Administration Cheatsheet

A high-density reference guide tailored for Ubuntu LTS environments, separating critical administrative tasks into structured command tables.

---

## 1. System, Hardware & Storage Diagnostics

Commands for pulling hardware configurations, OS kernel details, and storage boundary footprints.

| Target Action | CLI Command | Systems Administration Utility / Context |
| :--- | :--- | :--- |
| **Complete System Diagnostics** | `uname -a` | Displays system architecture, kernel release, and hostname. |
| **Kernel Release Version** | `uname -r` | Isolates active operating kernel release information. |
| **OS Distribution Details** | `cat /etc/os-release` | Discovers specific distribution release version and name. |
| **Uptime & Load Average** | `uptime` | Shows host uptime, current active users, and system load. |
| **Active Local Hostname** | `hostname` | Inspects system hostname settings. |
| **Local IP Address List** | `hostname -I` | Pulls all assigned network IP interfaces. |
| **Boot Audit History** | `last reboot` | Lists reboot occurrences and system shut-down states. |
| **Active System Date** | `date` | Inspects current system-wide clock date and timezone. |
| **Hardware BIOS Profile** | `sudo dmidecode` | Decodes SMBIOS tables directly from the system hardware. |
| **Current User Identifier** | `whoami` | Identifies active shell session username. |
| **Kernel Output Buffer** | `sudo dmesg -w` | Real-time tailing of kernel ring buffer (diagnoses hardware faults). |
| **Processor Profile** | `cat /proc/cpuinfo` | Audits detailed processor cores, speeds, and flags. |
| **Low-level Memory Info** | `cat /proc/meminfo` | Inspects kernel memory allocation status. |
| **RAM Footprint Overview** | `free -h` | Displays free/used RAM and swap margins in human-readable units. |
| **PCI Hardware Tree** | `lspci -tv` | Visualizes PCI slot layouts and attached controllers. |
| **USB Device Bus Tree** | `lsusb -tv` | Inspects all USB buses and connected hardware profiles. |
| **File System Space** | `df -h` | Evaluates mounted storage capacity and usage percentages. |
| **Inode Allocation Audit** | `df -i` | Assures inode boundaries are not exhausted (prevents file writes failure). |
| **Block Partition Table** | `sudo fdisk -l` | Audits physical block disk configurations and partition formats. |
| **Target Directory Weight** | `du -sh /path` | Measures cumulative space used by a directory. |

---

## 2. Performance Monitoring, Logs & Auditing

Utilities for real-time monitoring of CPU, memory, storage I/O, process lists, and audit events.

| Diagnostic Goal | CLI Command | Administrative Rationale |
| :--- | :--- | :--- |
| **System Process Monitor** | `htop` *(or `top`)* | Interactive process manager for checking CPU/RAM consumption. |
| **CPU Context Statistics** | `mpstat 1` | Monitors individual processor core loads (requires `sysstat`). |
| **Virtual Memory Activity** | `vmstat 1` | Audits system paging, context switching, and block IO metrics. |
| **Storage Channel I/O** | `iostat 1` | Analyzes device read/write throughput rates. |
| **File Access Audit** | `sudo lsof` | Discovers all open file descriptors and active sockets. |
| **User File Descriptors** | `sudo lsof -u <user>` | Isolates resources occupied by a specific administrative user. |
| **Continuous Directory Watch**| `watch -n 1 df -h` | Executes standard commands at periodic intervals for tracking. |
| **System Event Log Audit** | `sudo tail -n 100 /var/log/syslog` | Inspects standard operating system events on Debian/Ubuntu. |
| **Perimeter Packet Trace** | `sudo tcpdump -i <interface>`| Captures packet handshakes on selected local interfaces. |
| **Web Endpoint Monitor** | `sudo tcpdump -i eth0 'port 80'`| Sniffs web interface ports to audit HTTP connection requests. |
| **Systemd Log Stream** | `sudo journalctl` | Inspects central systemd binary log vault. |
| **Service Specific Logs** | `sudo journalctl -u <service>` | Follows output events for a target systemd service. |

---

## 3. IAM, Security & Permissions Hardening

Controls for managing administrative identity, enforcing standard permissions, and maintaining system access walls.

| System Action | CLI Command | Core Objective & Context |
| :--- | :--- | :--- |
| **Current User Credentials** | `id` | Displays active UID, GID, and assigned security groups. |
| **Authentication Logs** | `last` | Tracks all historic logins and terminal session durations. |
| **Interactive Terminal Audit** | `w` *(or `who`)* | Identifies currently active shell logins and active processes. |
| **Administrative Group Creation**| `sudo groupadd <group>` | Initializes a new administrative user security group. |
| **Secure System User Creation**| `sudo useradd -c "Name" -m <user>`| Spawns non-privileged user account with proper `/home` directory. |
| **User Deletion & Purging** | `sudo userdel -r <user>` | Drops user access and recursively deletes corresponding home directory. |
| **Group Association Adjustment**| `sudo usermod -aG <group> <user>`| Appends specific non-primary security groups to a target user. |
| **Standard File Read/Write** | `chmod 644 <file>` | Sets user read/write, group/world read-only permissions (Standard HTML). |
| **Standard Folder Traversal** | `chmod 755 <dir>` | Restricts directory updates to user, grants group/world traversal. |
| **Chroot/Restricted Traversal**| `chmod 775 <dir>` | Shared group workspace permissions (Standard web roots). |
| **Change Session Password** | `passwd` | Updates active user authentication credentials. |
| **Root Shell Escalation** | `sudo -i` | Elevates to root user complete environment session. |
| **Non-Login Root Shell** | `sudo -s` | Runs active shell engine with root administrative access. |
| **Auditing Escalation Rules** | `sudo -l` | Lists active sudo configuration permissions for user. |
| **Safe Sudoers Configuration** | `sudo visudo` | Edits `/etc/sudoers` safety bounds using syntax checking. |

---

## 4. File Operations & Directory Navigation

Standard tools for locating patterns, copying trees, and executing safe folder actions.

| Operation Target | CLI Command | Key Arguments & Systems Safety |
| :--- | :--- | :--- |
| **Standard Directory List** | `ls -la` | Displays hidden directories and file permission matrices. |
| **Present Path Resolution** | `pwd` | Verifies full absolute working path of active terminal. |
| **Folder Hierarchy Path** | `mkdir -p <dir>` | Creates a multi-nested directory tree without failing. |
| **Recursive Tree Deletion** | `rm -rf <dir>` | **Dangerous**: Forcefully drops folders and nested resources. |
| **Recursive Tree Copy** | `cp -r <src> <dest>` | Duplicates full folder hierarchies to target directories. |
| **Symbolic Link Binding** | `ln -s /real/path <link>` | Creates virtual routing pathways to centralized files. |
| **Touch Update File** | `touch <file>` | Creates empty mockups or forces mod-time update. |
| **Streamlined Text Reading** | `less <file>` | Opens text files within interactive pagination engine. |
| **Incremental File Tracking** | `tail -f <file>` | Follows live logs as entries write to disk. |
| **Active Pattern Matching** | `grep -rn "<pattern>" <dir>`| Traverses recursively to isolate specific string occurrences. |
| **Locate Path by Pattern** | `find <path> -name "*pattern*"`| Finds directory files mapping directly to glob wildcards. |
| **Filter by Storage Weight** | `find /var -size +100M` | Detects heavy log files bypassing standard rotation thresholds. |
| **Parent Traversal** | `cd ..` | Escapes to parent directory node. |
| **Home Escape** | `cd` | Bypasses path directly to root `$HOME`. |

---

## 5. Network Perimeter, SSH & Transfers

Protocols for managing remote interfaces, tunnel configuration, and secure packet transmissions.

| Transfer Type | CLI Command | Context & Systems Administration Safety |
| :--- | :--- | :--- |
| **Network Interface Status** | `ip a` | Discovers status and configurations of all adapters. |
| **Adapter Hardware Status** | `sudo ethtool eth0` | Queries physical connection status, speeds, and properties. |
| **ICMP Perimeter Audit** | `ping <host>` | Validates network-level round-trip reachability. |
| **Whois Directory Query** | `whois <domain>` | Inspects registration details and nameservers. |
| **Standard DNS Dig** | `dig <domain>` | Queries DNS namespace for records propagation (A, CNAME, etc.). |
| **Reverse DNS Query** | `dig -x <ip>` | Performs reverse mapping lookup of external IP. |
| **Port Socket Inventory** | `sudo netstat -nutlp` *(or `ss`)*| Audits all active listeners, ports, and associated process IDs. |
| **Secure Terminal Session** | `ssh -p <port> <user>@<host>`| Connects cryptographically via custom SSH gateway interfaces. |
| **Automated SSH Persistence** | `autossh -f -N -L <port>:<target>:<target_port> <user>@<host>`| Launches monitored, self-healing background tunnels. |
| **Secure Isolated Copy** | `scp <file> <user>@<host>:/tmp`| Transmits files over secure cryptographic channels. |
| **Remote Web Resource Download**| `wget -O <dest> <url>` | Fetches raw remote packages to target server directory. |
| **High-Performance Sync** | `rsync -avz --progress <src> <dest>`| Minimizes network transmission overhead by syncing diffs. |

---

## 6. Compression Archives & Package Maintenance

Techniques for compiling system configurations and executing clean Ubuntu/Debian (`apt`) software lifecycle actions.

| Task Category | CLI Command | Package Management / Compression Strategy |
| :--- | :--- | :--- |
| **Standard Tar Compile** | `tar cf archive.tar <dir>` | Binds full directories into a single file without compression. |
| **Tar Extraction** | `tar xf archive.tar` | Extracts standard archive collections to active directory path. |
| **Gzip Compressed Archive** | `tar czf archive.tar.gz <dir>`| High-speed standard Gzip compression. |
| **Gzip Extraction** | `tar xzf archive.tar.gz` | Extracts Gzip archives cleanly. |
| **Bzip2 Compressed Archive** | `tar cjf archive.tar.bz2 <dir>`| Maximum ratio Bzip2 compression (best for database backups). |
| **Bzip2 Extraction** | `tar xjf archive.tar.bz2` | Extracts Bzip2 archives cleanly. |
| **Update Package Index** | `sudo apt update` | Synchronizes active packages catalog from upstream sources. |
| **Hardened System Upgrade** | `sudo apt upgrade -y` | Performs non-disruptive upgrades of stable service packages. |
| **APT Catalog Search** | `apt search <keyword>` | Searches system repositories for software solutions. |
| **Install Secure Package** | `sudo apt install <package> -y`| Pulls, validates, and installs verified software packages. |
| **Purge Unused Packages** | `sudo apt purge --autoremove <package>`| Uninstalls packages and purges configuration traces (keeps server clean). |
| **Compile from Source** | `./configure && make && sudo make install`| Configures, compiles, and installs raw upstream target source code. |

---

## 7. System Initialization, Scheduling & Cleanup

Commands for ensuring stable boot sequences, automating routine jobs, and maintaining storage hygiene.

| Task Category | CLI Command | Workflow & System Stability Logic |
| :--- | :--- | :--- |
| **Verify System State** | `systemctl status <service>` | Checks daemon health and service lifecycle (e.g., `systemctl status apache2`). |
| **Service Restart/Reload** | `sudo systemctl restart <service>` | Triggers clean shutdown and immediate process resumption (e.g., `sudo systemctl restart mysql`). |
| **Service Activation** | `sudo systemctl enable <service>` | Ensures daemon initializes automatically upon system boot. |
| **Service Suspension** | `sudo systemctl disable <service>` | Prevents automatic startup on future boots. |
| **Scheduled Job Creation** | `sudo crontab -e` | Opens user-specific cron editor to define recurring tasks by time pattern. |
| **Root Scheduled Jobs** | `sudo crontab -e` | Accesses root-level cron table for system maintenance scripts. |
| **Task Execution Log** | `grep CRON /var/log/syslog` | Filters terminal logs to trace past automated task completions. |
| **Disk Usage Audit** | `df -h` | Displays mounted filesystems and current storage saturation percentages. |
| **Storage Space Scan** | `sudo du -sh /var/log/*` | Scans directory weight to identify files consuming excessive disk space. |
| **Targeted Cleanup** | `sudo journalctl --vacuum-time=7d` | Triggers journald compaction by removing logs older than 7 days (clean Debian/Ubuntu practice). |
| **Safe Package Purge** | `sudo apt autoremove --purge` | Eliminates unused dependencies and their residual configuration files. |
| **Safe Upgrade Cycle** | `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y` | The "Holy Trinity" of Ubuntu maintenance: updates index, upgrades packages, cleans debris. |
| **System Time Sync** | `sudo timedatectl set-ntp true` | Activates NTP synchronization to maintain accurate server timestamps (crucial for SSL/logs). |

---

**System Administrator's Note**: Regular execution of commands from Sections 6 and 7 is critical for preventing disk overflow, maintaining package integrity, and ensuring the server remains secure and stable over time.

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
