@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0pbackup.ps1" %*
endlocal
