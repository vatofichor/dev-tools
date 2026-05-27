## Modular Subdomain Architecture (Standardized)## 1. Domain Service Resolution (DNS)
Before host configuration, ensure the network layer is prepared.

## A. Record Types

* Static: Create an A Record for sub1 pointing to <SERVER_IP>.
* Wildcard: Create a * record pointing to <SERVER_IP> for dynamic scaling (e.g., *.example.com).

## B. Local Resolution (Dev/Testing)

For development before DNS propagation, map subdomains to the server's public IP on your local workstation's hosts file (not the server's).

* Windows: C:\Windows\System32\drivers\etc\hosts
* Linux/Mac: /etc/hosts

<SERVER_IP> sub1.example.com
<SERVER_IP> sub2.example.com

------------------------------

## 2. Standardized File System Hierarchy

Organize subdomains under a primary parent directory to keep /var/www clean and manageable.

* Create directory structure

sudo mkdir -p /var/www/example.com/subdomains/sub1
sudo mkdir -p /var/www/example.com/subdomains/sub2

* Set ownership to the web user (www-data) so Apache and FTP can interact with files

sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R 755 /var/www/example.com

------------------------------

## 3. Virtual Host Logic (Apache)## A. Configuration

Create a separate config file for each subdomain. Use the FQDN (Fully Qualified Domain Name) for the filename.
sudo nano /etc/apache2/sites-available/sub1.example.com.conf

```
<VirtualHost *:80>
    ServerName sub1.example.com
    DocumentRoot /var/www/example.com/subdomains/sub1

    <Directory /var/www/example.com/subdomains/sub1>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Segregated Logging for Auditing
    ErrorLog ${APACHE_LOG_DIR}/sub1_example_error.log
    CustomLog ${APACHE_LOG_DIR}/sub1_example_access.log combined
</VirtualHost>
```

## B. Activation & Validation

* Enable the sites
sudo a2ensite sub1.example.com.conf

* Test for syntax errors (Critical: do not reload if this fails)
sudo apache2ctl configtest

* Graceful reload
sudo systemctl reload apache2

------------------------------
## 4. SSH Tunneling (For Hardened Servers)

If Apache is restricted to 127.0.0.1, use an SSH tunnel to view the site from your local browser.
On your local machine:

ssh -N -L 8080:127.0.0.1:80 exampleadmin@<SERVER_IP>

Access via: http://sub1.example.com:8080 (requires the local hosts file entry from Step 1B).
------------------------------
## 5. Maintenance & Diagnostics

| Operation | Command |
|---|---|
| Check Active VHosts | sudo apache2ctl -S |
| Disable Subdomain | sudo a2dissite sub1.example.com.conf && sudo systemctl reload apache2 |
| Tail Access Logs | sudo tail -f /var/log/apache2/sub1_example_access.log |
| Tail Error Logs | sudo tail -f /var/log/apache2/sub1_example_error.log |

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
