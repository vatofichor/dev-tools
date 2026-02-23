# tinygit

A lightweight, local version control system designed for solo developers. `tinygit` streamlines your workflow by using `pbackup` for project archival, eliminating the need for remote servers or complex branching models.

**System Requirements**: Windows 10 or later (PowerShell 5.1+).

## Key Features
- **Init**: Initialize a new local repository configuration in the current directory.
- **Stage**: Create a timestamped zip archive of your project using `pbackup` in the staging directory.
- **Push**: Move (or copy) the staged zip archive to your defined destination directory.
- **Clean**: Clear the staging directory of previous zip archives.
- **Conn**: Verify connectivity to the configured push destination.
- **Fetch**: Copy a specific zip file from the destination back to your working directory.
- **List**: List all zip files currently in the destination directory.
- **Clone**: Download and extract a specific zip file from the destination into a `pull_results` folder.

## Documentation & Help
To view the full list of available commands and detailed usage instructions, run:
```bat
tinygit help
```

## Troubleshooting
For debugging and activity history, refer to the `tinygit-log.txt` file located within your designated staging directory.

---
```
# Copyright (c) 2026:
# [>_<] vatofichor - Sebastian Mass
#  /|\  & Antigravity 🤖
```
