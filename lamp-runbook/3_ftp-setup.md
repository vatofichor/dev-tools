## Hardened FTPS Configuration (vsftpd + Virtual Users)## 1. Dependency Synchronization
Install the FTP daemon along with the PAM module for file-based authentication and Apache utilities for credential management.
```
sudo apt update
sudo apt install vsftpd openssl libpam-pwdfile apache2-utils -y
```
## 2. Global Service Hardening
Establish the secure environment for the chroot jail.

# Create the standard empty directory for secure chroot
```
sudo mkdir -p /var/run/vsftpd/empty
sudo chown root:root /var/run/vsftpd/empty
sudo chmod 555 /var/run/vsftpd/empty
````
## 3. Virtual User Management
We utilize virtual users to prevent FTP credentials from being used for SSH or other system services.
## A. Credential Store
The password file must be in a specific format (username:hash).
```
sudo mkdir -p /etc/vsftpd# Create the file and set permissions
sudo touch /etc/vsftpd/vsftpd.passwd
sudo chmod 600 /etc/vsftpd/vsftpd.passwd
```
## B. PAM Authentication Logic
Configure PAM to use the pwdfile module. On Ubuntu 24.04, you must use the absolute path to the .so file to avoid the "auth not found" error.
Edit /etc/pam.d/vsftpd:
```
# 1. Custom Virtual User Authentication
auth    required    /lib/x86_64-linux-gnu/security/pam_pwdfile.so pwdfile /etc/vsftpd/vsftpd.passwd
account required    pam_permit.so

# 2. Keep the deny list (prevents root from logging in via FTP)
auth    required    pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed

# 3. Disable these by adding a # in front (VERY IMPORTANT)
# @include common-account
# @include common-session
# @include common-auth
```
## C. Generate Encrypted Passwords
Generate a SHA-512 hash for your user and manually append it to the password file.
1. Generate the hash:
```
openssl passwd -6 example123
```
2. Add to the password file:
Open /etc/vsftpd/vsftpd.passwd and add the entry in user:hash format:
```
exampleadmin:$6$rounds=40960$examplehashstring123...
```
## D. Configure vsftpd for Virtual Users
Update /etc/vsftpd.conf to enable the virtual user engine and point it to the PAM service.
1. Update Identity & Guest Settings:

# Disable standard local system logins (unless needed)
```local_enable=YES```

# Enable virtual users
```
guest_enable=YES
guest_username=www-data
nopriv_user=www-data
```
# Point to the PAM service name defined in /etc/pam.d/vsftpd
```pam_service_name=vsftpd```

2. Configure Chroot & Paths:
```
chroot_local_user=YES
allow_writeable_chroot=YES
```
# Define where the virtual users' files will live
```
user_sub_token=$USER
local_root=/home/ftp/$USER
```
3. Initialize User Directory:
```
sudo mkdir -p /home/ftp/exampleadmin
sudo chown www-data:www-data /home/ftp/exampleadmin
sudo systemctl restart vsftpd
```
------------------------------
Section for managing the firewall and testing the passive connection to ensure your client doesn't hang at "Retrieving Directory Listing."

## 8. Firewall and Passive Connectivity

For FTPS to function, the firewall must allow the initial connection (Port 21) and the range of ports used for data transfer (Passive Ports).

**1. Configure UFW (Uncomplicated Firewall):**

Run these commands to open the control and data channels:

**Allow FTP Control Port**

```sudo ufw allow 21/tcp```

**Allow the Passive Port Range (matching vsftpd.conf)**

```sudo ufw allow 40000:40100/tcp```

**Reload to apply**

```sudo ufw reload```

**2. Verify the configuration:**

Ensure the rules are active:
```
sudo ufw status
```

**3. Troubleshooting Connectivity:**

If you can log in but cannot see files, the most common causes are:

* NAT/Cloud Firewalls: If you are on AWS, Azure, or DigitalOcean, you must also open ports 21 and 40000-40100 in their web-based security group settings.
* PASV Address: If your server is behind a NAT, add your public IP to /etc/vsftpd.conf:

```pasv_address=YOUR_PUBLIC_IP```


**4. Testing the login:**

You can test the authentication locally using the ftp command or from a remote machine using FileZilla (ensure you select "Require explicit FTP over TLS").

---

Because you are using **virtual users** managed by the `pam_pwdfile.so` module rather than standard Linux system accounts, the standard `passwd` command will not work. You must manually generate a new SHA-512 hash and update the `/etc/vsftpd/vsftpd.passwd` file.


## 1. Password Modification Procedure

### Step 1: Generate the New Encrypted Hash

Run the `openssl` utility to generate a secure SHA-512 hash of your new password. Replace `example123` with your desired credentials:

```bash
openssl passwd -6 example123

```

*Output example:*
`$6$rounds=40960$vG7z...$t8R9mXy7...`

Copy the entire output string exactly.

### Step 2: Edit the Credential Store

Open the virtual user password file with elevated privileges:

```bash
sudo nano /etc/vsftpd/vsftpd.passwd

```

### Step 3: Update the User Data Entry

Locate the line beginning with your username (`exampleadmin`). Replace everything after the colon (`:`) with your newly generated hash.

The format must follow this exact syntax without spaces:

```text
exampleadmin:$6$rounds=40960$vG7z...$t8R9mXy7...

```

Save and exit the file (`Ctrl+O`, `Enter`, `Ctrl+X`).

---

## 2. Configuration Verification

No service restart is required for credential changes. The `pam_pwdfile.so` module reads `/etc/vsftpd/vsftpd.passwd` dynamically upon every authentication request.

If authentication fails post-update, verify file format and security contexts:

| Checkpoint | Command | Expected State |
| --- | --- | --- |
| **No Syntax Bloat** | `sudo cat /etc/vsftpd/vsftpd.passwd` | Exactly one line per user. Format: `user:hash` |
| **Permissions** | `ls -l /etc/vsftpd/vsftpd.passwd` | `-rw------- (600)` owned by `root:root` |

### Test Connection via CLI

```bash
lftp -u exampleadmin localhost

```

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
