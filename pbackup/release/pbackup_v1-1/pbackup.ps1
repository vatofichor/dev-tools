# pbackup.ps1 - Windows-native PowerShell implementation of pbackup
# Signature: vatofichor - Sebastian Mass & Antigravity @ 2026


# Always exclude these patterns
$AlwaysExclude = @(
    # --- Original User Patterns ---
    ".pbackup", 
    ".*", 
    "AI-NOACCESS.txt", 
    "AI-ACCESSIBLE.txt", 
    "ai_persistent_files", 
    "skip-ai-persistence.txt", 
    "*.code-workspace",

    # --- Language & System Bloatware ---
    "node_modules",      # Node.js dependencies
    "venv", ".venv",     # Python virtual environments
    "__pycache__",       # Python bytecode
    "vendor",            # PHP/Composer dependencies
    "dist", "build",     # Compiled artifacts
    "bin", "obj",        # .NET/General build output
    "*.log",             # Log files
    "Thumbs.db"          # Windows system metadata
)

function Get-PBackupConfig($configName) {
    if ([string]::IsNullOrWhiteSpace($configName)) {
        $configFileName = ".pbackup"
    }
    else {
        $configFileName = "$configName.pbackup"
    }
    
    $configFile = Join-Path (Get-Location) $configFileName
    if (-not (Test-Path $configFile)) {
        Write-Error "Config file $configFileName not found."
        exit 1
    }
    
    $content = Get-Content $configFile -Raw
    $config = @{
        destination       = "."
        force_destination = "0"
        flatten           = "0"
        transform         = "scal"
        keep_empty_dirs   = "0"
        paths             = @("*")
        exclude           = @()
        _config_file      = $configFileName
    }
    
    $lines = $content -split "`r?`n"
    $currentKey = $null
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) { continue }
        
        if ($trimmed -match "^([\w-]+)\s*:\s*(.*)$") {
            $key = $Matches[1].Replace("-", "_")
            $val = $Matches[2].Trim()
            $currentKey = $key
            
            if ($val -ne "") {
                if ($key -eq "paths" -or $key -eq "exclude") {
                    if ($val -eq "*" -or $val -eq "*/*") {
                        $config[$key] = $val
                    }
                    else {
                        $config[$key] = @($val)
                    }
                }
                else {
                    $config[$key] = $val
                }
            }
            else {
                $config[$key] = @()
            }
        }
        elseif ($trimmed -match "^-\s*(.*)$") {
            $val = $Matches[1].Trim()
            if ($currentKey -and $config[$currentKey] -is [array]) {
                $config[$currentKey] += $val
            }
        }
    }
    return $config
}

function Invoke-PBackupInit {
    $dest = Read-Host "destination"
    $forceDest = Read-Host "force-destination (0/1)"
    
    $paths = @()
    Write-Host "Enter paths (file/dir/*. Type '@done' to finish)."
    while ($true) {
        $p = Read-Host "path"
        if ($p -eq "@done") { break }
        if (-not [string]::IsNullOrWhiteSpace($p)) {
            $paths += $p
        }
    }
    if ($paths.Count -eq 0) { $paths = @("*") }
    
    $excludes = @()
    Write-Host "Enter exclusions (file/dir/wildcard. Type '@done' to finish)."
    Write-Host "Note: Include '@defaults' to use the standard exclusion list."
    while ($true) {
        $e = Read-Host "exclude"
        if ($e -eq "@done") { break }
        if (-not [string]::IsNullOrWhiteSpace($e)) {
            $excludes += $e
        }
    }
    
    $flatten = Read-Host "flatten (0/1)"
    $transform = Read-Host "transform (scal/mult)"
    if ($flatten -eq "0" -and [string]::IsNullOrWhiteSpace($transform)) {
        $transform = "scal"
    }
    $keepEmpty = Read-Host "keep-empty-dirs (0/1)"
    if ([string]::IsNullOrWhiteSpace($keepEmpty)) { $keepEmpty = "0" }
    
    $yaml = "destination: $dest`n"
    $yaml += "force-destination: $forceDest`n"
    
    if ($paths.Count -eq 1 -and ($paths[0] -eq "*" -or $paths[0] -eq "*/*")) {
        $yaml += "paths: $($paths[0])`n"
    }
    else {
        $yaml += "paths:`n"
        foreach ($p in $paths) { $yaml += "  - $p`n" }
    }
    
    if ($excludes.Count -gt 0) {
        $yaml += "exclude:`n"
        foreach ($e in $excludes) { $yaml += "  - $e`n" }
    }
    
    $yaml += "flatten: $flatten`n"
    $yaml += "transform: $transform`n"
    $yaml += "keep-empty-dirs: $keepEmpty`n"
    
    $yaml | Out-File ".pbackup" -Encoding utf8
    if ($excludes -notcontains "@defaults") {
        Write-Host "Note: Standard excludes skipped. Use '@defaults' in config to include them."
    }
    Write-Host ".pbackup created (YAML format)."
}

function Test-IsExcluded($path, $excludes, $configFileName) {
    if ($path -eq $configFileName) {
        return $true
    }
    
    $fullExcludeList = @()
    if ($excludes -contains "@defaults") {
        $fullExcludeList += $AlwaysExclude
        $fullExcludeList += ($excludes | Where-Object { $_ -ne "@defaults" })
    }
    else {
        $fullExcludeList = $excludes
    }
    
    $normalizedPath = $path.Replace("\", "/")
    $parts = $normalizedPath.Split("/")
    $currentRel = ""
    
    foreach ($part in $parts) {
        if ($currentRel -eq "") { $currentRel = $part } else { $currentRel = "$currentRel/$part" }
        $base = $part
        
        foreach ($exc in $fullExcludeList) {
            if ($exc.Contains("*")) {
                $pattern = "^" + [regex]::Escape($exc).Replace('\*', '.*') + "$"
                if ($currentRel -match $pattern -or $base -match $pattern) { return $true }
            }
            else {
                if ($currentRel -eq $exc -or $base -eq $exc) { return $true }
            }
        }
    }
    return $false
}

function Invoke-PBackup($configName) {
    $config = Get-PBackupConfig $configName
    
    $targetDir = $config.destination
    
    if ([string]::IsNullOrEmpty($targetDir)) { $targetDir = "." }
    
    if (-not (Test-Path $targetDir)) {
        if ($config.force_destination -eq "1") {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        else {
            Write-Error "Destination $targetDir missing."
            exit 1
        }
    }
    
    $projectName = (Get-Item .).Name
    if (![string]::IsNullOrEmpty($configName)) {
        $projectName = "$projectName-$configName"
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $zipName = "$projectName`_$timestamp.zip"
    $zipPath = Join-Path $targetDir $zipName
    
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    
    Write-Host "Backing up to $zipPath using $($config._config_file)..."
    
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    $itemsToZip = @()
    $allFiles = Get-ChildItem -Path . -File -Recurse
    foreach ($f in $allFiles) {
        $rel = Resolve-Path $f.FullName -Relative
        if ($rel.StartsWith(".\")) { $rel = $rel.Substring(2) }
        
        if (-not (Test-IsExcluded $rel $config.exclude $config._config_file)) {
            $included = $false
            if ($config.paths -is [string] -and ($config.paths -eq "*" -or $config.paths -eq "*/*")) {
                $included = $true
            }
            else {
                foreach ($p in $config.paths) {
                    if ($rel.StartsWith($p.TrimEnd("/\"))) { $included = $true; break }
                }
            }
            if ($included) {
                $itemsToZip += @{ FullPath = $f.FullName; RelativePath = $rel; IsDir = $false }
            }
        }
    }
    
    if ($config.keep_empty_dirs -eq "1") {
        $allDirs = Get-ChildItem -Path . -Directory -Recurse
        foreach ($d in $allDirs) {
            $rel = Resolve-Path $d.FullName -Relative
            if ($rel.StartsWith(".\")) { $rel = $rel.Substring(2) }
            
            if (-not (Test-IsExcluded $rel $config.exclude $config._config_file)) {
                $included = $false
                if ($config.paths -is [string] -and ($config.paths -eq "*" -or $config.paths -eq "*/*")) {
                    $included = $true
                }
                else {
                    foreach ($p in $config.paths) {
                        if ($rel.StartsWith($p.TrimEnd("/\"))) { $included = $true; break }
                    }
                }
                if ($included) {
                    $itemsToZip += @{ FullPath = $d.FullName; RelativePath = $rel; IsDir = $true }
                }
            }
        }
    }
    
    if ($itemsToZip.Count -eq 0) {
        Write-Host "No files to backup."
        Remove-Item $tempDir -Recurse
        return
    }
    
    foreach ($item in $itemsToZip) {
        if ($item.IsDir) {
            if ($config.flatten -ne "1") {
                $target = Join-Path $tempDir $item.RelativePath
                if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
            }
        }
        else {
            if ($config.flatten -eq "1") {
                $base = [System.IO.Path]::GetFileName($item.RelativePath)
                $target = Join-Path $tempDir $base
                if ($config.transform -eq "mult" -and (Test-Path $target)) {
                    $n = 1
                    $namePart = [System.IO.Path]::GetFileNameWithoutExtension($base)
                    $extPart = [System.IO.Path]::GetExtension($base)
                    while (Test-Path $target) {
                        $target = Join-Path $tempDir "$namePart-$n$extPart"
                        $n++
                    }
                }
                Copy-Item $item.FullPath $target
            }
            else {
                $target = Join-Path $tempDir $item.RelativePath
                $parent = Split-Path $target
                if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
                Copy-Item $item.FullPath $target
            }
        }
    }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
    Remove-Item $tempDir -Recurse
    Write-Host "Backup complete: $zipPath"
}

$arg = $args[0]
if ($arg -eq "help" -or $arg -eq "-h" -or $arg -eq "--help" -or $arg -eq "/?") {
    Write-Host "pbackup - Project Backup Utility"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  pbackup [command] [arguments]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  (default)      Run the backup using the default configuration file (.pbackup)."
    Write-Host "  <config_name>  Run the backup using a specific configuration file (<config_name>.pbackup)."
    Write-Host "  init           Interactively create a new .pbackup configuration file."
    Write-Host "  help           Show this help message."
    Write-Host ""
    Write-Host "Configuration (.pbackup):"
    Write-Host "  The configuration file is a simple YAML-like file with the following keys:"
    Write-Host "  - destination: Target directory for the backup."
    Write-Host "  - force_destination: 1 to create the destination if it doesn't exist."
    Write-Host "  - paths: List of files or directories to include (default: *)."
    Write-Host "  - exclude: List of patterns to exclude."
    Write-Host "  - flatten: 1 to flatten the directory structure in the zip."
    Write-Host "  - transform: 'scal' (scalar) or 'mult' (multiple) for handling name collisions when flattening."
    Write-Host "  - keep_empty_dirs: 1 to include empty directories in the backup."
}
elseif ($arg -eq "init") {
    Invoke-PBackupInit
}
else {
    Invoke-PBackup $arg
}
