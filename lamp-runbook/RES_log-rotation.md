# Log Rotation with logrotate



## 1. The `logrotate` Utility

In Ubuntu, `logrotate` is the standard system utility for managing the automatic rotation, compression, removal, and mailing of log files. It is typically executed daily by a `cron` job.


## 2. Implementation for `vsftpd`

We will create a specific configuration file in `/etc/logrotate.d/`. This ensures our custom rules for the FTP daemon are modular and survive system updates.


```bash
sudo nano /etc/logrotate.d/vsftpd
```


Paste the following configuration:


```text
/var/log/vsftpd.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 640 root adm
    postrotate
        /usr/bin/systemctl reload vsftpd > /dev/null 2>&1 || true
    endscript
}
```

### Directive Breakdown

* **`daily`**: Rotates the log every 24 hours.
* **`rotate 14`**: Retains 14 days of history before deleting the oldest file.
* **`compress`**: Uses gzip to reduce the footprint of archived logs.
* **`delaycompress`**: Delays compression until the *next* rotation cycle, ensuring the previous log is still readable if a process is still writing to it.
* **`notifempty`**: Does not rotate the log if it is currently 0 bytes.
* **`postrotate`**: Executes a command after rotation; here, we signal `vsftpd` to release the old file handle and start writing to the new one.

---

## 3. Log Analysis & Monitoring (Admin Mode)

Monitoring logs is the primary way to detect unauthorized access attempts or configuration errors.

**A. Real-time Tailing**

To watch FTP traffic as it happens (useful during development):


```bash
sudo tail -f /var/log/vsftpd.log
```


**B. Searching for Anomalies**

To identify failed login attempts from a specific IP:


```bash
sudo grep "FAIL LOGIN" /var/log/vsftpd.log
```



## 4. Systems Thinking Checklist: The Bigger Picture

To ensure this LAMP environment remains lean and "vanilla," consider these three final maintenance tasks:


* **Log Stewardship:** Apply similar rotation rules to Apache (`/var/log/apache2/*.log`) and MySQL (`/var/log/mysql/*.log`) if they are not already managed by default.
* **Disk Usage Audit:** Use `du -sh /var/log` periodically to ensure no service has bypassed rotation logic.
* **Automated Cleanup:** For the `tmp` or `upload` directories within your web root, a system administrator would set up a simple `cron` task to purge files older than X days.

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
