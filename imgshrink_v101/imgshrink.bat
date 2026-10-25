@echo off
setlocal EnableDelayedExpansion

:: ========================================================
:: imgshrink - Automated Web & Social Asset Optimizer
:: Copyright (c) 2026:
:: vatofichor - Sebastian Mass     [>_<]
:: & Assisted By Gemini Antigravity /|\
:: Licensed under the MIT License
:: ========================================================

title imgshrink - Image Optimization Utility

:: 1. File Path Resolution
set "TARGET_FILE=%~1"
if "%TARGET_FILE%"=="" (
    echo ========================================================
    echo  imgshrink - Web ^& Social Asset Optimizer
    echo ========================================================
    set /p "TARGET_FILE=Enter image file path (or drag and drop file here): "
)

:: Strip enclosing quotes
set "TARGET_FILE=!TARGET_FILE:"=!"
:: Strip trailing backslash if present (prevents \" escaping issue in PowerShell CLI)
if "!TARGET_FILE:~-1!"=="\" set "TARGET_FILE=!TARGET_FILE:~0,-1!"

if not exist "!TARGET_FILE!" (
    echo [ERROR] Target file does not exist: "!TARGET_FILE!"
    if "%~1"=="" pause
    exit /b 1
)

:: 2. Max Width Resolution
set "MAX_WIDTH=%~2"
if "%MAX_WIDTH%"=="" (
    set /p "MAX_WIDTH=Enter max width in pixels [Press Enter for default: 2048]: "
)
if "!MAX_WIDTH!"=="" set "MAX_WIDTH=2048"

:: 3. Quality Resolution (50, 75, 90, 100)
set "RAW_QUALITY=%~3"

:check_quality
if "!RAW_QUALITY!"=="1" set "RAW_QUALITY=50"
if "!RAW_QUALITY!"=="2" set "RAW_QUALITY=75"
if "!RAW_QUALITY!"=="3" set "RAW_QUALITY=90"
if "!RAW_QUALITY!"=="4" set "RAW_QUALITY=100"

if "!RAW_QUALITY!"=="50" goto quality_ok
if "!RAW_QUALITY!"=="75" goto quality_ok
if "!RAW_QUALITY!"=="90" goto quality_ok
if "!RAW_QUALITY!"=="100" goto quality_ok

echo.
echo Select JPEG Quality:
echo   [1] 50  - High Compression (Smaller file size)
echo   [2] 75  - Balanced
echo   [3] 90  - High Quality (Default)
echo   [4] 100 - Maximum / Minimal Compression
echo.
set /p "RAW_QUALITY=Enter choice [1-4 or 50/75/90/100, default: 90]: "
if "!RAW_QUALITY!"=="" set "RAW_QUALITY=90"
goto check_quality

:quality_ok
set "QUALITY=!RAW_QUALITY!"

echo.
echo --------------------------------------------------------
echo Processing: "!TARGET_FILE!"
echo Max Width : !MAX_WIDTH! px
echo Quality   : !QUALITY!%%
echo --------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0imgshrink.ps1" -File "!TARGET_FILE!" -MaxWidth !MAX_WIDTH! -Quality !QUALITY!

if "%~1"=="" (
    echo.
    echo Press any key to exit...
    pause >nul
)

endlocal
