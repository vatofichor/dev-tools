# ⚡ lserve

> Instant local PHP development servers at your fingertips on Windows.

`lserve` is an ultra-lightweight, zero-overhead command-line utility that streamlines launching the local PHP built-in web server. Say goodbye to typing out verbose command-line options—simply type `lserve` and your port, and start coding.

---

## ✨ Features

- **⚡ Zero Configuration:** Instantly spin up a local PHP server on any port.
- **📁 Document Root Filtering:** Includes `ltserve` to launch a server targeting a dedicated `/public` directory (ideal for modern MVC routers like Laravel, Symfony, etc.).
- **🔒 Secure Execution:** Automatically runs using a clean PowerShell execution policy bypass, ensuring it runs seamlessly on modern Windows systems.
- **🛠️ Minimal Footprint:** Written entirely in native Batch and PowerShell—no external dependencies, node_modules, or complicated setups required.

---

## 🚀 Quick Start & Installation

### 1. Requirements
Ensure you have **PHP** installed on your system and added to your system's `PATH`.

To verify PHP is accessible:
```bash
php -v
```

### 2. Installation
1. Clone or download this repository to a directory of your choice (e.g., `D:\dev-tools\lserve`).
2. Add the installation folder to your Windows user/system `PATH` environment variables.
3. Open a new terminal window (Cmd, PowerShell, or Windows Terminal).

---

## 📖 Usage Guide

`lserve` comes with two utility scripts tailored to different folder structures.

### Standard Server (`lserve`)
Ideal for serving a flat directory or simple multi-page HTML/PHP sites directly from the current working directory.

```bash
lserve 8080
```
This instantly spins up:
`Starting PHP server on http://localhost:8080 ...`
Serving files from your current directory.

### Framework-Ready Server (`ltserve`)
Perfect for framework structures or single-page applications where static assets and the front controller (`index.php`) reside in a `/public` subfolder.

```bash
ltserve 8000
```
This mounts the server with the `-t public` document root option, directing all initial traffic securely to the `public/` directory.

---

## 🛠️ Script Architecture

### Core Files
- [lserve.bat](file:///d:/Dev/dev-tools/lserve/lserve.bat): Transparent wrapper that routes command line execution cleanly to PowerShell.
- [lserve.ps1](file:///d:/Dev/dev-tools/lserve/lserve.ps1): The engine driving the standard PHP server execution, enforcing clean CLI feedback.
- [ltserve.bat](file:///d:/Dev/dev-tools/lserve/ltserve.bat): Fast-path batch file pointing directly to the `/public` root.

---

## License
This project is licensed under the **MIT License**.

### Attribution
* **Author:** Sebastian Mass
* **GitHub:** [vatofichor](https://github.com/vatofichor)
* **Requirement:** The copyright notice and license must remain with the software in its parts or whole. This is a non-viral license; it does not apply to your entire product, only to the code sourced from this repository.

---

# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\  