# Log Diagnostic Matrix



|Layer|Component|Log File / Command Path|Primary Diagnostic Purpose|
|-|-|-|-|
|**Web (HTTP)**|Apache Global|`/var/log/apache2/error.log`|Critical PHP errors, 500-level crashes, module failures.|
||Apache Traffic|`/var/log/apache2/access.log`|Incoming request tracking, HTTP status codes, user agents.|
||Subdomain Error|`/var/log/apache2/sub1\_error.log`|Troubleshooting specific site failures in a multi-tenant setup.|
||Subdomain Access|`/var/log/apache2/sub1\_access.log`|Monitoring traffic volume and sources for specific subdomains.|
||Apache Syntax|`sudo apache2ctl configtest`|Validating `.conf` files before applying service reloads.|
|**Database**|MySQL Error|`/var/log/mysql/error.log`|Database connection timeouts, permission denials, service crashes.|
||MySQL Performance|`/var/log/mysql/mysql-slow.log`|Identifying inefficient queries causing high CPU load.|
|**Access/SSH**|SSH Service|`sudo journalctl -u ssh`|Real-time SSH daemon activity and connection handshakes.|
||Global Auth|`/var/log/auth.log`|Monitoring all login attempts, `sudo` usage, and SSH key validation.|
|**File Transfer**|vsftpd Protocol|`/var/log/vsftpd.log`|Tracking virtual user logins, uploads, and download activity.|
||vsftpd Xfer|`/var/log/xferlog`|Standardized FTP data transfer logging (if dual logging is enabled).|
|**Security**|Firewall (UFW)|`/var/log/ufw.log`|Inspecting packets blocked or allowed at the network perimeter.|
||Intrusion (F2B)|`/var/log/fail2ban.log`|Identifying IPs jailed due to detected brute-force attacks.|
|**Infrastructure**|System (Syslog)|`/var/log/syslog`|Catch-all for general system messages and non-specific service errors.|
||Kernel Buffer|`sudo dmesg -w`|Diagnosing hardware resource exhaustion (e.g., OOM Killers).|
||Dependencies|`\~/.composer/logs`|Reviewing failures during PHP package resolution and installation.|

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
