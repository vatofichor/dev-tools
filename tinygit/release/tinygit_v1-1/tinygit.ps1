<#
.SYNOPSIS
    tinygit - A simplified local git version control system.

Copyright (c) 2026:
[>_<] vatofichor - Sebastian Mass
 /|\  & Antigravity 🤖
#>

param (
    [Parameter(Position = 0)]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$Option
)

$ConfigPath = Join-Path (Get-Location) ".tinygit"
$RuntimePath = Join-Path (Get-Location) ".tinygit-runtime"

function Get-Config {
    if (Test-Path $ConfigPath) {
        $config = @{}
        Get-Content $ConfigPath | ForEach-Object {
            if ($_ -match "(.+): (.+)") {
                $config[$Matches[1].Trim()] = $Matches[2].Trim()
            }
        }
        return $config
    }
    return $null
}

function Save-Config($configData) {
    if (!$configData -or $configData.Count -eq 0) { return }
    $content = ""
    foreach ($key in $configData.Keys) {
        $content += "$key : $($configData[$key])`n"
    }
    Set-Content $ConfigPath $content.Trim()
}

function Get-Runtime {
    if (Test-Path $RuntimePath) {
        $runtime = @{}
        Get-Content $RuntimePath | ForEach-Object {
            if ($_ -match "(.+): (.+)") {
                $runtime[$Matches[1].Trim()] = $Matches[2].Trim()
            }
        }
        return $runtime
    }
    return @{}
}

function Save-Runtime($runtimeData) {
    if (!$runtimeData) { return }
    $content = ""
    foreach ($key in $runtimeData.Keys) {
        $content += "$key : $($runtimeData[$key])`n"
    }
    Set-Content $RuntimePath $content.Trim()
}

function Write-Log($Message) {
    $config = Get-Config
    if ($config -and $config["stage_destination"]) {
        $logPath = Join-Path $config["stage_destination"] "tinygit-log.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] $Message" | Out-File -FilePath $logPath -Append
    }
}

switch ($Command) {
    "init" {
        $embeddedPbackup = Join-Path $PSScriptRoot "pbackup.ps1"
        if (!(Test-Path $embeddedPbackup)) {
            Write-Host "[ERROR] Embedded pbackup.ps1 not found in script directory ($PSScriptRoot)." -ForegroundColor Red
            exit
        }

        Write-Host "Initializing tinygit in $(Get-Location)..."
        
        $pbackupFile = Read-Host "Enter pbackup file name (default: .pbackup)"
        if ([string]::IsNullOrWhiteSpace($pbackupFile)) { $pbackupFile = ".pbackup" }
        if ($pbackupFile -notmatch "\.pbackup$") { $pbackupFile += ".pbackup" }

        $stageDest = Read-Host "Enter stage destination directory"
        while (!(Test-Path $stageDest)) {
            $create = Read-Host "Path does not exist. Create it? (y/n)"
            if ($create -match "^(y|yes|1)$") {
                New-Item -ItemType Directory -Path $stageDest -Force | Out-Null
                break
            }
            $stageDest = Read-Host "Enter stage destination directory"
        }

        $pushDest = Read-Host "Enter push destination directory (default: CWD)"
        if ([string]::IsNullOrWhiteSpace($pushDest) -or $pushDest -eq "./" -or $pushDest -eq "/") {
            $pushDest = (Get-Location).Path
        }
        
        while (!(Test-Path $pushDest)) {
            Write-Host "[WARNING] Push destination not reachable." -ForegroundColor Yellow
            $pushDest = Read-Host "Enter push destination directory (or press Enter for CWD)"
            if ([string]::IsNullOrWhiteSpace($pushDest) -or $pushDest -eq "./" -or $pushDest -eq "/") { 
                $pushDest = (Get-Location).Path
                break 
            }
        }

        $keepStagedPrompt = Read-Host "Keep staged files after push? (y/n)"
        $keepStaged = if ($keepStagedPrompt -match "^(y|yes|1)$") { "1" } else { "0" }

        $resolvedStage = if (![string]::IsNullOrWhiteSpace($stageDest)) { Convert-Path $stageDest } else { "" }
        $resolvedPush = if (![string]::IsNullOrWhiteSpace($pushDest)) { Convert-Path $pushDest } else { "" }

        $config = @{
            "working_directory"    = (Get-Location).Path
            "staging_pbackup_file" = $pbackupFile
            "push_destination"     = $resolvedPush
            "stage_destination"    = $resolvedStage
            "keep_staged"          = $keepStaged
        }
        Save-Config $config

        $logPath = Join-Path $stageDest "tinygit-log.txt"
        "Initializing tinygit-log.txt" | Out-File $logPath
        Write-Log "tinygit initialized."

        $pbackupPath = Join-Path (Get-Location) $pbackupFile
        if (!(Test-Path $pbackupPath)) {
            Write-Host "pbackup file not found. Running 'pbackup init'..."
            & $embeddedPbackup init $stageDest
            
            # pbackup init always creates '.pbackup'. If user requested a different name, rename it.
            if ($pbackupFile -ne ".pbackup" -and (Test-Path ".pbackup")) {
                Move-Item ".pbackup" $pbackupFile -Force
                Write-Host "Renamed .pbackup to $pbackupFile"
            }
        }

        Write-Host "tinygit initialized successfully." -ForegroundColor Green
    }

    "stage" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }

        $pbackupFile = $config["staging_pbackup_file"]
        $stageDest = $config["stage_destination"]

        $embeddedPbackup = Join-Path $PSScriptRoot "pbackup.ps1"
        if (!(Test-Path $embeddedPbackup)) {
            Write-Host "[ERROR] Embedded pbackup.ps1 not found." -ForegroundColor Red
            exit
        }

        Write-Host "Staging project using $pbackupFile..."
        
        if ($pbackupFile -eq ".pbackup") {
            & $embeddedPbackup
        }
        else {
            $configName = $pbackupFile -replace "\.pbackup$", ""
            & $embeddedPbackup $configName
        }
        
        $recentZip = Get-ChildItem -Path $stageDest -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if ($recentZip) {
            $finalPath = $recentZip.FullName
            
            $runtime = Get-Runtime
            $runtime["last_staged"] = $finalPath
            Save-Runtime $runtime
            
            Write-Log "Staged: $($recentZip.Name)"
            Write-Host "Successfully staged to $($recentZip.FullName)" -ForegroundColor Green
        }
        else {
            Write-Host "[ERROR] Could not find staged zip file in $stageDest." -ForegroundColor Red
        }
    }

    "push" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }

        $runtime = Get-Runtime
        $lastStaged = $runtime["last_staged"]
        $pushDest = $config["push_destination"]
        $keepStaged = ($config["keep_staged"] -eq "1") -or ($Option -eq "-ks")

        if ([string]::IsNullOrWhiteSpace($pushDest)) {
            Write-Host "[ERROR] Push destination not configured. Run 'tinygit init' or set it in .tinygit." -ForegroundColor Red
            exit
        }

        if ($lastStaged -and (Test-Path $lastStaged)) {
            if (Test-Path $pushDest) {
                if ($keepStaged) {
                    Copy-Item $lastStaged $pushDest
                }
                else {
                    Move-Item $lastStaged $pushDest
                }
                Write-Log "Pushed $lastStaged to $pushDest"
                Write-Host "Push successful." -ForegroundColor Green
            }
            else {
                Write-Host "[ERROR] Push destination $pushDest not reachable." -ForegroundColor Red
            }
        }
        else {
            Write-Host "[ERROR] No staged file found to push." -ForegroundColor Red
        }
    }

    "clean" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        $stageDest = $config["stage_destination"]

        if ($Option -eq "-ls") {
            $runtime = Get-Runtime
            $lastStaged = $runtime["last_staged"]
            if ($lastStaged -and (Test-Path $lastStaged)) {
                Remove-Item $lastStaged -Force
                Write-Log "Cleaned last staged: $lastStaged"
                Write-Host "Deleted last staged file."
            }
        }
        else {
            $confirm = Read-Host "Are you sure you want to clear $stageDest? (y/n)"
            if ($confirm -match "^(y|yes|1)$") {
                Remove-Item (Join-Path $stageDest "*.zip") -Force
                Write-Log "Staging cleared."
                Write-Host "Staging directory cleared."
            }
        }
    }

    "conn" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        $pushDest = $config["push_destination"]
        
        if ([string]::IsNullOrWhiteSpace($pushDest)) {
            Write-Host "Push destination not configured." -ForegroundColor Yellow
            $status = $false
        }
        else {
            $status = Test-Path $pushDest
        }
        
        $runtime = Get-Runtime
        $runtime["conn_status"] = [bool]$status
        Save-Runtime $runtime
        
        if ($status) {
            Write-Host "Push destination is available." -ForegroundColor Green
        }
        else {
            Write-Host "Push destination is NOT available." -ForegroundColor Red
        }
    }

    "list" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        
        $target = $config["stage_destination"]
        $label = "Staging"
        
        if ($Option -eq "-p") {
            $target = $config["push_destination"]
            $label = "Push Destination"
            
            if ([string]::IsNullOrWhiteSpace($target)) {
                Write-Host "[ERROR] Push destination not configured." -ForegroundColor Red
                exit
            }
        }
        
        if (Test-Path $target) {
            Write-Host "Listing files in $label ($target):" -ForegroundColor Cyan
            Get-ChildItem $target | Select-Object Name, Length, LastWriteTime
        }
        else {
            Write-Host "[ERROR] $label not found or unreachable ($target)." -ForegroundColor Red
        }
    }

    "fetch" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        $pushDest = $config["push_destination"]
        
        if ([string]::IsNullOrWhiteSpace($pushDest)) {
            Write-Host "[ERROR] Push destination not configured." -ForegroundColor Red
            exit
        }

        $filename = $Option
        if (!$filename) { Write-Host "Specify filename to fetch." -ForegroundColor Red; exit }
        
        $src = Join-Path $pushDest $filename
        $dest = Join-Path (Get-Location) $filename

        if (Test-Path $src) {
            Copy-Item $src $dest
            $runtime = Get-Runtime
            $runtime["last_fetched"] = $dest
            $runtime["fetch_status"] = "True"
            Save-Runtime $runtime
            Write-Host "Fetched $filename to working directory."
        }
        else {
            $runtime = Get-Runtime
            $runtime["fetch_status"] = "False"
            Save-Runtime $runtime
            Write-Host "File not found at destination." -ForegroundColor Red
        }
    }

    "clone" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        $pushDest = $config["push_destination"]
        
        if ([string]::IsNullOrWhiteSpace($pushDest)) {
            Write-Host "[ERROR] Push destination not configured." -ForegroundColor Red
            exit
        }

        $filename = $Option
        if (!$filename) { Write-Host "Specify filename to clone." -ForegroundColor Red; exit }

        $src = Join-Path $pushDest $filename
        $pullDest = Join-Path (Get-Location) "pull_results"
        if (!(Test-Path $pullDest)) { New-Item -ItemType Directory -Path $pullDest | Out-Null }

        if (Test-Path $src) {
            $localZip = Join-Path $pullDest $filename
            Copy-Item $src $localZip
            
            Expand-Archive -Path $localZip -DestinationPath $pullDest -Force
            
            $runtime = Get-Runtime
            $runtime["last_pull"] = $localZip
            $runtime["pull_status"] = "True"
            Save-Runtime $runtime
            Write-Host "Successfully cloned $filename to pull_results." -ForegroundColor Green
        }
        else {
            $runtime = Get-Runtime
            $runtime["pull_status"] = "False"
            Save-Runtime $runtime
            Write-Host "File not found at destination." -ForegroundColor Red
        }
    }

    "log" {
        $config = Get-Config
        if (!$config) { Write-Host "Not initialized. Run 'tinygit init'." -ForegroundColor Red; exit }
        $logPath = Join-Path $config["stage_destination"] "tinygit-log.txt"
        
        if (Test-Path $logPath) {
            Write-Host "--- tinygit Activity Log ---" -ForegroundColor Cyan
            Get-Content $logPath
        }
        else {
            Write-Host "Log file not found at $logPath" -ForegroundColor Yellow
        }
    }

    "help" {
        Write-Host "tinygit - A simplified local git version control system" -ForegroundColor Cyan
        Write-Host "Usage: tinygit [command] [option]"
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Yellow
        Write-Host "  init    : Initialize tinygit in the current directory."
        Write-Host "  stage   : Stage the project using pbackup (creates timestamped zip)."
        Write-Host "  push    : Push the staged zip to the destination."
        Write-Host "            Options: -ks (Keep Staged files after push)"
        Write-Host "  clean   : Clear the staging directory."
        Write-Host "            Options: -ls (Delete only the last staged file)"
        Write-Host "  conn    : Check connection to the push destination."
        Write-Host "  list    : List files in the staging directory (default)."
        Write-Host "            Options: -p (List files in the push destination instead)"
        Write-Host "  fetch   : Copy a specific zip from destination to working dir."
        Write-Host "            Usage: tinygit fetch [filename]"
        Write-Host "  clone   : Download and extract a zip to 'pull_results'."
        Write-Host "            Usage: tinygit clone [filename]"
        Write-Host "  log     : Display the contents of the activity log."
        Write-Host "  help    : Show this help message."
        Write-Host ""
    }

    default {
        Write-Host "Unknown command '$Command'." -ForegroundColor Red
        Write-Host "Usage: tinygit [init|stage|push|clean|conn|list|log|fetch|clone|help] [option]"
        Write-Host "Run 'tinygit help' for more details."
    }
}
