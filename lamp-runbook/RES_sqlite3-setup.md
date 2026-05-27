To add SQLite3 to a standard LAMP (Linux, Apache, MySQL, PHP) stack, you primarily need to install the SQLite engine and the PHP-SQLite driver.

**1. Install SQLite3 and PHP Driver**

Open your terminal and run:

```
sudo apt update
sudo apt install sqlite3 php-sqlite3
```

**2. Restart Apache**

For PHP to recognize the new SQLite extension, you must restart the web server:

```sudo systemctl restart apache2```

**3. Verify the Installation**

Create a test file in your web root to confirm PHP can talk to SQLite:

```echo "<?php phpinfo(); ?>" | sudo tee /var/www/example.com/test.php```


* Visit http://your-server-ip/test.php in your browser.
* Search (Ctrl+F) for "sqlite3". If you see a section for it, it’s working.
* Security Tip: Delete this file after checking: sudo rm /var/www/example.com/test.php

**4. Set Permissions (Crucial Step)**

Unlike MySQL, SQLite is just a file. Apache needs permission to write to the folder containing the database:

**Navigate to your project folder:**

```
sudo chown -R www-data:www-data /var/www/example.com/your-project-folder
sudo chmod -R 775 /var/www/example.com/your-project-folder
```

**5. Quick Usage Example

You can now connect via PHP:

```
<?php
$db = new SQLite3('my_database.db');
$db->exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)");
echo "SQLite is running!";
?>
```

---

*Disclaimer: The contents of this document are AI-generated and derived from a multiplicity of free, open, and public online sources.*
