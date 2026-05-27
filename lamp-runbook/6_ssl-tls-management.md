# SSL/TLS Certificate Provisioning & Hardening (Let's Encrypt)

Modern web server infrastructure mandates that all HTTP traffic is encrypted. This guide details how to secure your apex domain, the `www` alias, and multiple subdomains using Let's Encrypt and Certbot.

---

## 1. Prerequisites & DNS Preparation

Before requesting an SSL certificate, ensure your DNS records are fully configured and propagated. Certbot must verify domain ownership via a cryptographic challenge.

* **For Single Domain SSL (HTTP-01 Challenge):**
  Ensure your A records for `example.com` and `www.example.com` point to your `<SERVER_IP>`.
* **For Wildcard Subdomain SSL (DNS-01 Challenge):**
  Ensure your DNS provider is managed by a provider with API support (like DigitalOcean, Cloudflare, etc.). A wildcard `*` A record should point to `<SERVER_IP>`.

---

## 2. Option A: Apex & www Domain SSL (Standard Setup)

If you only need to secure `example.com` and `www.example.com`, use the simple Apache HTTP-01 challenge.

### Step 1: Install Certbot & Apache Plugin
```bash
sudo apt update
sudo apt install certbot python3-certbot-apache -y
```

### Step 2: Request & Deploy Certificates
This command automatically negotiates the certificate and updates your Apache Virtual Host configuration `/etc/apache2/sites-available/example.com.conf` to serve HTTPS on port `443` and redirect HTTP traffic.
```bash
sudo certbot --apache -d example.com -d www.example.com
```

---

## 3. Option B: Wildcard Subdomain SSL (Advanced Setup)

To secure `example.com` and any subdomain (e.g., `sub1.example.com`, `sub2.example.com`) using a single certificate, you must use the **DNS-01 Challenge** via your DNS provider's API.

### Step 1: Install the DNS Certbot Plugin
*(Using DigitalOcean as the standard example)*
```bash
sudo apt update
sudo apt install certbot python3-certbot-dns-digitalocean -y
```

### Step 2: Configure API Credentials
Create a secured credentials file at `/etc/letsencrypt/digitalocean.ini`:
```bash
sudo mkdir -p /etc/letsencrypt
sudo nano /etc/letsencrypt/digitalocean.ini
```

Paste your API token:
```ini
dns_digitalocean_token = YOUR_API_TOKEN_HERE
```

Lock down the file permissions (Critical Security Hardening):
```bash
sudo chmod 600 /etc/letsencrypt/digitalocean.ini
```

### Step 3: Request the Wildcard Certificate
```bash
sudo certbot certonly \
  --dns-digitalocean \
  --dns-digitalocean-credentials /etc/letsencrypt/digitalocean.ini \
  -d example.com \
  -d "*.example.com"
```

---

## 4. Standardized Apache SSL Virtual Host Configuration

For subdomains utilizing the wildcard certificate, reference the unified certificate paths directly in their virtual host configurations.

### Template: `/etc/apache2/sites-available/sub1.example.com.conf`
```apache
<VirtualHost *:443>
    ServerName sub1.example.com
    DocumentRoot /var/www/example.com/subdomains/sub1

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem

    <Directory /var/www/example.com/subdomains/sub1>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Force HSTS (HTTP Strict Transport Security)
    Header always set Strict-Transport-Security "max-age=63072000"

    ErrorLog ${APACHE_LOG_DIR}/sub1_example_error.log
    CustomLog ${APACHE_LOG_DIR}/sub1_example_access.log combined
</VirtualHost>
```

Activate the SSL Virtual Host:
```bash
sudo a2ensite sub1.example.com.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

---

## 5. Automation, Renewal, & Verification

Let's Encrypt certificates expire every 90 days. The renewal process is automated by systemd.

| Operation | Command | Purpose |
| :--- | :--- | :--- |
| **Check Expiry Status** | `sudo certbot certificates` | Lists active certificates, domains covered, and days remaining. |
| **Test Auto-Renewal** | `sudo certbot renew --dry-run` | Simulates the renewal process to verify credentials/network configuration. |
| **Verify systemd Timer** | `sudo systemctl status certbot.timer` | Assures the daily automated background check is operational. |

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
