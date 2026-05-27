# Secure SSH Tunneling \& Service Isolation (Standardized)



### 1\. Service Isolation (Host-Side)

To ensure the web server is truly private, reconfigure it to ignore public network interfaces entirely.



##### A. Modify Apache Binding

Edit `/etc/apache2/ports.conf` and change the `Listen` directive:

```apache
# Original: Listen 80
Listen 127.0.0.1:80
```



Update your VirtualHost files (`/etc/apache2/sites-available/\*.conf`) accordingly:

```apache
# Original: <VirtualHost \*:80>
<VirtualHost 127.0.0.1:80>
```



**Apply Changes:**

```bash
sudo systemctl restart apache2
```



##### B. Verify Perimeter Lockdown

Ensure no public listeners exist on port 80.



```bash
sudo ss -tulpn | grep :80
# Expected: LISTEN 127.0.0.1:80 (No 0.0.0.0:80)
```



### 2\. Establishing the Secure Tunnel (Client-Side)



##### A. Standard Persistent Command

Use `autossh` to manage the connection. This requires the `autossh` package on your local machine.



```bash
# -f: Background execution
# -N: Do not execute remote command (Forwarding only)
# -L: \[Local Port]:\[Remote Target]:\[Remote Port]
autossh -f -N -L 8080:127.0.0.1:80 sysadmin@<SERVER\_IP>
```



##### B. Advanced SSH Configuration (`\~/.ssh/config`)

Automate the tunnel by adding this entry to your local SSH config file. This replaces long commands with a simple `ssh dev-tunnel`.



```text
Host dev-tunnel
    HostName <SERVER\_IP>
    User sysadmin
    IdentityFile \~/.ssh/id\_ed25519
    LocalForward 8080 127.0.0.1:80
    ExitOnForwardFailure yes
    ServerAliveInterval 60
```



### 3\. Restricted Tunnel-Only User (Hardening)

For maximum security, create a user that *only* has permission to tunnel, with no interactive shell access.



```bash
# On the Server:
sudo adduser --shell /usr/sbin/nologin tunneluser
```



Add the following block to the **end** of `/etc/ssh/sshd\_config`:

```text
Match User tunneluser
    AllowTcpForwarding yes
    X11Forwarding no
    PermitTTY no
    ForceCommand echo "This account is for tunneling only."
```



### 4\. Troubleshooting \& Diagnostics

|Symptom|Probable Cause|Diagnostic Command|
|-|-|-|
|**Connection Refused**|Local port 8080 is in use.|`lsof -i :8080`|
|**Channel Opening Fail**|SSHD `AllowTcpForwarding` is `no`.|`grep AllowTcpForwarding /etc/ssh/sshd\_config`|
|**Timeout**|Firewall blocking port 22.|`sudo ufw status`|
|**Broken Pipe**|Inactive session timeout.|Check `ServerAliveInterval` in config.|

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
