# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\

$Version = "v1.1.2"
$ExeName = "mouse_grid.exe"
$ScriptDir = $PSScriptRoot

# Ensure we're running from a location where the script can resolve its path
if ([string]::IsNullOrEmpty($ScriptDir)) {
    $ScriptDir = (Get-Location).Path
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$PathArray = $UserPath -split ';'

# Check if the directory actually exists in the PATH
if ($PathArray -contains $ScriptDir) {
    Write-Host "Found '$ScriptDir' in User PATH. Removing..."
    
    # Filter out the script's directory and any empty entries
    $NewPathArray = $PathArray | Where-Object { $_ -ne $ScriptDir -and $_ -ne "" }
    $NewPath = $NewPathArray -join ';'
    
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Host "Success! Removed '$ScriptDir' from the current User's Environment PATH." -ForegroundColor Green
    Write-Host "Note: You will need to restart any open terminals for the new PATH to take effect." -ForegroundColor Yellow
} else {
    Write-Host "The directory '$ScriptDir' is not currently in your User PATH. Nothing to remove." -ForegroundColor Cyan
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

