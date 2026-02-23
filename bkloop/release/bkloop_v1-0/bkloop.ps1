<#
.SYNOPSIS
bkloop - Backup Looper
"vatofichor - Sebastian Mass"

.DESCRIPTION
A continuous backup looper script designed to run in the background within an active shell.
It supports both custom 'pbackup' configurations and a standard 1-to-1 ZIP fallback.
NOTE: 'pbackup' utility is required from the vatofichor repository on GitHub.

.USAGE INSTRUCTIONS
1. Launch via the 'bkloop' bash launcher, OR run '.\bkloop.ps1' directly in PowerShell.
2. Enter the target working directory you wish to backup (defaults to current directory).
3. Select an interval frequency (15m, 30m, 1h, or a custom minutes value).
4. If a '.pbackup' file exists (either as a hidden extension or named file), it will prompt you to use it.
5. If no pbackup configuration is selected or exists, it falls back to a standard ZIP archive.
   - The fallback cleanly zips the target and stores it in THIS script's home directory.
6. Leave the shell open to persist the loop. Press Ctrl+C at any time to safely terminate.
#>

#Requires -Version 5.1

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

Write-Host "--- bkloop - Backup Looper ---" -ForegroundColor Cyan
Write-Host "Script origin: $ScriptDir"

# Ensure zip capability exists for fallback
if (-not (Get-Command Compress-Archive -ErrorAction SilentlyContinue)) {
    Write-Warning "Compress-Archive utility not found. Fallback filesystem backups will fail."
}

# 1. Prompt for Working Directory
$TargetDir = Read-Host "Enter the working directory to backup (default: current)"
if ([string]::IsNullOrWhiteSpace($TargetDir)) { $TargetDir = Get-Location }

try {
    $TargetDir = (Resolve-Path $TargetDir -ErrorAction Stop).ProviderPath
}
catch {
    Write-Host "Error: Path '$TargetDir' does not exist or cannot be resolved." -ForegroundColor Red
    exit 1
}

# 2. Prompt for Frequency
Write-Host "`nSelect Backup Frequency:"
Write-Host "1) 15 Minutes"
Write-Host "2) 30 Minutes"
Write-Host "3) 1 Hour"
Write-Host "4) Custom (minutes)"
$FreqChoice = Read-Host "Choice (1-4)"

[int]$IntervalSeconds = 0
switch ($FreqChoice) {
    "1" { $IntervalSeconds = 900 }
    "2" { $IntervalSeconds = 1800 }
    "3" { $IntervalSeconds = 3600 }
    "4" { 
        $CustomMin = Read-Host "Enter custom minutes"
        if ([int]::TryParse($CustomMin, [ref]$null) -and [int]$CustomMin -gt 0) {
            $IntervalSeconds = [int]$CustomMin * 60
        }
        else {
            Write-Host "Invalid input, defaulting to 15 minutes." -ForegroundColor Yellow
            $IntervalSeconds = 900
        }
    }
    default { 
        Write-Host "Unrecognized choice. Defaulting to 30 minutes." -ForegroundColor Yellow
        $IntervalSeconds = 1800 
    }
}

Write-Host "`nInterval set to $($IntervalSeconds/60) minutes ($IntervalSeconds seconds)." -ForegroundColor Green

# 3. pbackup Discovery & Pre-Loop Selection
$pbackupCmd = Get-Command pbackup -ErrorAction SilentlyContinue
$pbackupFiles = @(Get-ChildItem -Path $TargetDir -Filter "*.pbackup" -File -ErrorAction SilentlyContinue)
$GlobalSelectedPbackup = $null

if ($pbackupCmd -and $pbackupFiles.Count -gt 0) {
    if ($pbackupFiles.Count -eq 1) {
        $GlobalSelectedPbackup = $pbackupFiles[0].FullName
        $choice = Read-Host "`nFound $($pbackupFiles[0].Name). Use this configuration? (y/n)"
        if ($choice -ne 'y') { $GlobalSelectedPbackup = $null }
    }
    else {
        Write-Host "`nMultiple pbackup files found:"
        for ($i = 0; $i -lt $pbackupFiles.Count; $i++) {
            Write-Host "$($i+1)) $($pbackupFiles[$i].Name)"
        }
        $pChoice = Read-Host "Select file number (invalid defaults to first)"
        if ([int]::TryParse($pChoice, [ref]$null) -and [int]$pChoice -gt 0 -and [int]$pChoice -le $pbackupFiles.Count) {
            $GlobalSelectedPbackup = $pbackupFiles[[int]$pChoice - 1].FullName
        }
        else {
            $GlobalSelectedPbackup = $pbackupFiles[0].FullName
        }
    }
}
elseif ($pbackupCmd -and $pbackupFiles.Count -eq 0) {
    $initChoice = Read-Host "`nNo .pbackup found. Run 'pbackup init' now to create one? (y/n)"
    if ($initChoice -eq 'y') {
        try {
            Push-Location $TargetDir
            & pbackup init
            $GlobalSelectedPbackup = Join-Path $TargetDir ".pbackup"
            Pop-Location
        }
        catch {
            Write-Host "Error executing pbackup initialization: $_" -ForegroundColor Red
        }
    }
}

# 4. Core Backup Engine
function Invoke-BackupCycle {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Origin,

        [string]$SelectedPbackupFile
    )
    
    $pbackupScript = Join-Path $Origin "libs\pbackup.ps1"
    $hasPbackup = Test-Path $pbackupScript -PathType Leaf

    # Execute Explicit pbackup
    if ($hasPbackup -and $null -ne $SelectedPbackupFile -and (Test-Path $SelectedPbackupFile)) {
        $fileName = [System.IO.Path]::GetFileName($SelectedPbackupFile)
        $configName = ""

        if ($fileName -ne ".pbackup" -and $fileName -ne ".pbackup.pbackup") {
            $configName = [System.IO.Path]::GetFileNameWithoutExtension($SelectedPbackupFile)
        }
        
        $configNameDisplay = if ($configName) { $configName } else { "(default)" }
        Write-Host "Running imported pbackup with config: $configNameDisplay" -ForegroundColor Cyan
        
        try {
            if ($configName) {
                & $pbackupScript $configName
            }
            else {
                & $pbackupScript
            }
            return
        }
        catch {
            Write-Host "Error executing imported pbackup: $_" -ForegroundColor Red
            return
        }
    }

    # 4. Standard Zipper Fallback
    Write-Host "Utilizing standard zipper fallback..." -ForegroundColor Yellow
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $FolderName = (Get-Item $Path).Name
    $ZipName = "${FolderName}_${Timestamp}.zip"
    $Destination = Join-Path $Origin $ZipName
    
    try {
        if (-not (Get-Command Compress-Archive -ErrorAction SilentlyContinue)) {
            Write-Host "Error: Compress-Archive utility not found. Fallback backup failed." -ForegroundColor Red
            return
        }

        # ErrorAction Stop forces unhandled IO faults into the catch block
        Compress-Archive -Path "$Path\*" -DestinationPath $Destination -Force -ErrorAction Stop
        Write-Host "Backup created: $Destination" -ForegroundColor Green
    }
    catch {
        Write-Host "Zip compression failed: $_" -ForegroundColor Red
    }
}

# Main Event Loop
Write-Host "Backup loop started on $(Get-Date). Press Ctrl+C to stop." -ForegroundColor Magenta

try {
    while ($true) {
        # Refresh location to target for relative execution safety in tooling
        Push-Location $TargetDir
        try {
            Invoke-BackupCycle -Path $TargetDir -Origin $ScriptDir -SelectedPbackupFile $GlobalSelectedPbackup
        }
        finally {
            Pop-Location
        }
        
        Write-Host "Waiting $($IntervalSeconds/60) minutes for next backup... (Hit Ctrl+C to terminate)"
        Start-Sleep -Seconds $IntervalSeconds
    }
}
catch {
    Write-Host "`nBackup loop gracefully terminated." -ForegroundColor Cyan
}
