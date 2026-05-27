# Web Server Provisioning & Hardening Guide (Ubuntu LTS)

The following document represents a refined, hardened, and host-agnostic standard for initial web server provisioning.



## 1. Initial System Updates

Before service deployment, ensure the local package index and installed binaries are at the current stable release.



```bash
sudo apt update && sudo apt upgrade -y
```



## 2. Identity and Access Management (IAM)

Standardize administrative access using a non-privileged user with `sudo` escalation. Replace `sysadmin` with your designated administrative handle.



```bash
# Create user and assign to sudo group
sudo adduser sysadmin
sudo usermod -aG sudo sysadmin
```



## 3. SSH Hardening

Implement key-based authentication and disable insecure entry vectors.



* **A. Key Deployment (Client-Side)

Generate a high-entropy Ed25519 key pair and transmit the public key to the host.



```bash
# Generate key
ssh-keygen -t ed25519 -C "admin@example.com"

# Deploy to host Linux
ssh-copy-id -i ~/.ssh/id_ed25519.pub sysadmin@<SERVER_IP>
```

```
# Windows
# If you cannot pipe commands through PowerShell, you can do it manually in two distinct steps.

# Step 1: Copy your Public Key on Windows
# You need the text of your public key. Open PowerShell or Command Prompt and run:

type $env:USERPROFILE.ssh\id_ed25519.pub

# Highlight the text that starts with ssh-rsa and ends with your computer name, then Copy it.

# Step 2: Manually Prepare the Server
# Log into your remote server via SSH (using your password) and run these commands one by one:

#   1. Create the directory:
   
   mkdir -p ~/.ssh
   
#   2. Set directory permissions:
   
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   
#   3. Open the key file:

   nano ~/.ssh/authorized_keys
   
#   4. Paste your key:
#   Right-click (or use Ctrl+V) to paste the string you copied in Step 1 into the editor.
   
#   5. Save and Exit:
#   Press Ctrl+O, then Enter to save. Press Ctrl+X to exit.
   
#   6. Set file permissions:
   
   chmod 600 ~/.ssh/authorized_keys
   
```



* **B. Service Hardening (Host-Side)

Modify `/etc/ssh/sshd_config` to enforce the following logic:

* `PermitRootLogin no`: Restricts direct root access.
* `PasswordAuthentication no`: Disables credential-based brute forcing.
* `PubkeyAuthentication yes`: Mandates cryptographic identity.



```bash
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl reload ssh
```



## 4. Network Perimeter (Firewall)

**Sequence Logic:** Define rules *before* enabling the stateful firewall to prevent administrative lockout.



```bash
# Define Allow Rules
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Enable Firewall
sudo ufw enable
sudo ufw status verbose
```



## 5. LAMP Stack Deployment

* **A. Service Installation

Install the stack components. Use `php-fpm` for improved process management if high performance is required; otherwise, the standard Apache module suffices for basic implementations.



```bash
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y
```



* **B. Database Security

Execute the security script to remove default anonymous users and the test database.



```bash
sudo mysql_secure_installation
```



## 6. PHP Configuration & Hardening

Standardize the environment and suppress information leakage. Note: Replace `8.x` with the active version detected via `php -v`.



```bash
# Suppress PHP version in HTTP headers (Apache module & PHP-FPM)
sudo sed -i 's/expose_php = On/expose_php = Off/' /etc/php/8.x/apache2/php.ini
# If using PHP-FPM, also apply to:
# sudo sed -i 's/expose_php = On/expose_php = Off/' /etc/php/8.x/fpm/php.ini
```

**Supress Apache version**
Creates a custom security config, enables it in Apache, and restarts the service to hide server version info from hackers.

**1. Create the custom config file**

```
echo -e "ServerTokens Prod\nServerSignature Off" | sudo tee /etc/apache2/conf-available/security-hardening.conf
```

**2. Enable it**

```sudo a2enconf security-hardening```

**3. Test and Restart**

```sudo apache2ctl configtest && sudo systemctl restart apache2```

**Setup ServerName**

```echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf && sudo a2enconf servername && sudo systemctl restart apache2```

**Common production tunables**
```
# memory_limit = 256M
# upload_max_filesize = 64M
```

```
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.x/apache2/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/8.x/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 72M/' /etc/php/8.x/apache2/php.ini
```

**Restart Apache**

```
sudo systemctl restart apache2
```

## 7. Virtual Host Architecture
Decouple site configurations and establish a modular directory structure.

**Finds your PHP version (e.g., 8.2) and stores it in a variable:**

```PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f 1-2 -d ".") && echo "Your PHP version is: $PHP_VER"```

**Step A: Directory Structure**
Run these commands to create the actual folders for your site and set proper ownership:

```
sudo mkdir -p /var/www/example.com
sudo chown -R www-data:www-data /var/www/example.com
```

**Step B: Configuration Logic**
Create the configuration file at /etc/apache2/sites-available/example.com.conf. This setup uses ServerAlias to cover both the root and www versions of your domain:

```
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com

    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/example.com_error.log
    CustomLog ${APACHE_LOG_DIR}/example.com_access.log combined
</VirtualHost>
```

**Step C: Activation**
Disable the default placeholder site, enable your new domain configuration, and restart the service:

```
sudo a2dissite 000-default.conf
sudo a2ensite example.com.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
```

## 8. TLS Termination (Let's Encrypt)

Automate certificate issuance and renewal via Certbot.

Install Certbot and the Apache plugin:

```
sudo apt update
sudo apt install certbot python3-certbot-apache -y
```

Generate the SSL certificate:
This command automatically updates your Virtual Host configuration to handle HTTPS and redirects all HTTP traffic to the secure version. Replace example.com with your actual domain:

```
sudo certbot --apache -d example.com -d www.example.com
```

Verify the auto-renewal timer:
Let's Encrypt certificates expire every 90 days. Ubuntu automatically sets up a background timer to handle renewals, which you can verify with:

```
sudo systemctl status certbot.timer
```

* Note: Ensure your DNS records (both @ and www) are pointing to your server's IP address before running the certbot command, or the validation will fail.

---

## The "403 Forbidden" error on Apache/2.4.58 (Ubuntu)

Usually means the web server doesn't have permission to read the files in your web directory or the configuration is explicitly blocking access. [1, 2] 
Here are the most common ways to fix it:

**1. Check Directory and File Permissions**

The user www-data (Apache's default user on Ubuntu) must have permission to read your website's files and execute its directories. 

* Set directory permissions to 755:

```find /var/www/example.com -type d -exec chmod 755 {} \;```

* Set file permissions to 644:

```find /var/www/example.com -type f -exec chmod 644 {} \;```

* Set the correct ownership: Ensure the files are owned by the www-data group.

```sudo chown -R $USER:www-data /var/www/example.com```


**2. Verify Apache Virtual Host Configuration**

If your virtual host file isn't configured to allow access, Apache will block it by default.

Open your config file
```sudo nano /etc/apache2/sites-available/example.com.conf```
and ensure the <Directory> block looks like this:

```
<Directory /var/www/example.com>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

After making changes, restart Apache: sudo systemctl restart apache2.

**3. Check for a Missing Index Page**

If your directory doesn't contain an index.html or index.php file and "Indexes" is disabled in your configuration, 
Apache will show a 403 error because it isn't allowed to list the files.

**4. Inspect the Error Log**

If the above steps don't work, the exact reason for the block is recorded in the error log.

Run this command to see the latest errors:

```sudo tail -f /var/log/apache2/error.log```

---

## Default Configuration File not found

If Apache still defaulting to the standard 000-default.conf configuration file rather than your specific example.com configuration. 
This usually happens because the new configuration hasn't been "enabled" (linked to Apache's active sites) or because the default site is taking priority

**1. Disable the Default Site and Enable Yours**

Run these commands to tell Apache to stop using the default directory and start using your domain's folder:

* **Disable the default Ubuntu welcome site**
sudo a2dissite 000-default.conf

* **Enable your specific site configuration# (Replace 'example.com.conf' with your actual filename in sites-available)**
sudo a2ensite example.com.conf

* **Restart Apache to apply the changes**
sudo systemctl restart apache2

**2. Verify the Virtual Host is Loaded*

To see which configuration Apache is currently using and where its "DocumentRoot" is pointing, run: 

```sudo apache2ctl -S```

Look for example.com in the output. If it still says Main DocumentRoot: "/var/www/html", Apache isn't recognizing your custom config file yet.

** 3. Check for a Missing ServerName**

Open your configuration file at /etc/apache2/sites-available/example.com.conf and ensure it has these two lines:

```
ServerName example.com
DocumentRoot /var/www/example.com
```

Without the ServerName, Apache doesn't know that requests for your domain should go to your new folder and will fall back to the default 
```/var/www/html```.

**4. Fix Permissions for the New Folder**

If Apache is now pointing to the right place but still giving a 403 Forbidden, it likely can't "see" inside the new folder. Set the owner to the Apache user: 

```
sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R 755 /var/www/example.com
```

### 1. The "Parent Directory" Trap

```ls -ld /var/www```

If it doesn't show drwxr-xr-x

```sudo chmod 755 /var/www```

**2. Confirm the internal DocumentRoot**

```
grep -i "DocumentRoot" /etc/apache2/sites-enabled/example.com.conf
```

If that points to /var/www/example.com, make sure that directory actually exists and has an index file:

```
ls -la /var/www/example.com
```

**3. Check for a Global Block**

```
sudo nano /etc/apache2/apache2.conf
```

Scroll down to the <Directory /var/www/> section. It should look like this:

```
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
```

If it says Require all denied, change it to granted and restart Apache.

**4. Catch the specific error**

```
sudo tail -n 20 /var/log/apache2/error.log```

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
