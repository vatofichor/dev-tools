# lserve

Instant local PHP development servers at your fingertips on Windows.

`lserve` is an ultra-lightweight, zero-overhead command-line utility that streamlines launching the local PHP built-in web server.

**System Requirements**: Windows 10 or later (PowerShell 5.1+), PHP installed and in your system's `PATH`.

## Key Features
- **Zero Configuration**: Instantly spin up a local PHP server on any port.
- **Document Root Filtering**: Includes `ltserve` to launch a server targeting a dedicated `/public` directory.
- **Secure Execution**: Runs using a clean PowerShell execution policy bypass.
- **Minimal Footprint**: Native Batch and PowerShell scripts with no external dependencies.

## Installation
1. Clone or download this repository (e.g., `D:\Dev\dev-tools\lserve`).
2. Add the installation directory to your user or system `PATH` environment variable.

## Usage
`lserve` comes with two utility scripts for different folder structures:

### Standard Server (`lserve`)
Serves the current working directory directly:
```bat
lserve 8080
```

### Framework-Ready Server (`ltserve`)
Directs initial traffic to a `public/` directory (ideal for MVC frameworks like Laravel or Symfony):
```bat
ltserve 8000
```

## Project Architecture
- [lserve.bat](file:///d:/Dev/dev-tools/lserve/lserve.bat): Wrapper that routes execution to PowerShell.
- [lserve.ps1](file:///d:/Dev/dev-tools/lserve/lserve.ps1): Engine driving the standard PHP server.
- [ltserve.bat](file:///d:/Dev/dev-tools/lserve/ltserve.bat): Direct utility for launching in the `/public` root.

## License
This project is licensed under the **MIT License**.

### Attribution
* **Author:** Sebastian Mass
* **GitHub:** [vatofichor](https://github.com/vatofichor)
* **Requirement:** The copyright notice and license must remain with the software in its parts or whole. This is a non-viral license; it does not apply to your entire product, only to the code sourced from this repository.

---
```
# Copyright (c) 2026:
# [>_<] vatofichor - Sebastian Mass
#  /|\  & Antigravity 🤖
```
