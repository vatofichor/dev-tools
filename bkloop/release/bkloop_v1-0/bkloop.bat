@echo off
rem bkloop launcher
rem "vatofichor - Sebastian Mass"

set "SCRIPT_DIR=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%bkloop.ps1" %*
