# MySQL User Management



For a systems administrator, managing MySQL (or MariaDB) users requires a shift from using the "root" account for application tasks to a model of **Granular Privileges**. This ensures that if a web application is compromised, the attacker’s database access is restricted to a single schema.



\---



## 1\. Administrative Access

In modern Ubuntu LTS environments, the MySQL `root` user often uses the `auth\_socket` plugin, allowing you to log in via `sudo` without a password.



```bash
sudo mysql
```

## 2\. User Creation \& Authentication

Avoid using generic names. Define users based on the application or service they support.



### The Logic of Host Constraints

MySQL users are defined as `'username'@'host'`.

* `'user'@'localhost'`: Access only from the same machine (standard for LAMP).
* `'user'@'%'`: Access from any IP (highly insecure for production).
* `'user'@'10.0.0.5'`: Access only from a specific private IP (best for decoupled app/DB servers).



```sql
-- Create a dedicated application user
CREATE USER 'app\_user'@'localhost' IDENTIFIED BY 'STRONG\_GENERATED\_PASSWORD';
```



## 3\. Privilege Management (The Principle of Least Privilege)

Never grant `ALL PRIVILEGES` unless the user is a secondary administrator. For a standard web app (e.g., WordPress, Laravel, or a custom PHP tool), the user only needs access to a specific database.



##### Common Privilege Sets

|Level|Command|Use Case|
|-|-|-|
|**Data Only**|`SELECT, INSERT, UPDATE, DELETE`|Standard app runtime.|
|**Structure**|`CREATE, DROP, ALTER, INDEX`|Necessary for migrations/updates.|
|**Administrative**|`ALL PRIVILEGES`|Database owner/admin.|

##### 

##### Implementation Flow

```sql
-- 1. Create the database
CREATE DATABASE example\_db;

-- 2. Grant permissions (Data + Structure for migrations)
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX 
ON example\_db.\* TO 'app\_user'@'localhost';

-- 3. Apply changes
FLUSH PRIVILEGES;
```



## 4\. User Auditing \& Maintenance

Periodic audits are necessary to remove "ghost" accounts or outdated permissions.



```sql
-- List all users and their auth plugins
SELECT user, host, plugin FROM mysql.user;

-- Check specific permissions for a user
SHOW GRANTS FOR 'app\_user'@'localhost';

-- Change a password
ALTER USER 'app\_user'@'localhost' IDENTIFIED BY 'NEW\_SECURE\_PASSWORD';

-- Remove a user
DROP USER 'app\_user'@'localhost';
```



\---



## 5\. Security Hardening Checklist

* **Disable Remote Root:** Ensure `mysql\_secure\_installation` was run to prevent root logins from outside `localhost`.
* **Unique Users:** One database = One unique user. Never share credentials across different projects.
* **Configuration:** If you require remote access, do not open port `3306` to the world. Use an **SSH Tunnel** or restrict the firewall (`ufw`) to specific trusted IPs.

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
