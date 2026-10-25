# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\

$ExeName = "mouse_grid.exe"
$ScriptDir = $PSScriptRoot

# Ensure we're running from a location where the script can resolve its path
if ([string]::IsNullOrEmpty($ScriptDir)) {
    $ScriptDir = (Get-Location).Path
}

$ExePath = Join-Path $ScriptDir $ExeName

Write-Host "Looking for executable: $ExePath"

if (-Not (Test-Path $ExePath)) {
    Write-Host "Error: Could not find '$ExeName' or 'mouse_grid.exe' in the current directory." -ForegroundColor Red
    Write-Host "Please ensure both this script and the executable are placed in the same folder before running." -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$PathArray = $UserPath -split ';'

if ($PathArray -contains $ScriptDir) {
    Write-Host "The directory '$ScriptDir' is already in your User PATH." -ForegroundColor Cyan
} else {
    $NewPath = $UserPath + ";$ScriptDir"
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Host "Success! Added '$ScriptDir' to the current User's Environment PATH." -ForegroundColor Green
    Write-Host "Note: You will need to restart any open terminals for the new PATH to take effect." -ForegroundColor Yellow
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
