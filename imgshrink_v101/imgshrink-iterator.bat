@echo off
setlocal EnableDelayedExpansion

:: ========================================================
:: imgshrink-iterator - Directory Batch Image Optimizer
:: Copyright (c) 2026:
:: vatofichor - Sebastian Mass     [>_<]
:: & Assisted By Gemini Antigravity /|\
:: Licensed under the MIT License
:: ========================================================

title imgshrink-iterator - Directory Batch Image Optimizer

:: ========================================================
:: 1. Directory Input Resolution
:: ========================================================
set "TARGET_DIR=%~1"
if "%TARGET_DIR%"=="" (
    echo ========================================================
    echo  imgshrink-iterator - Directory Batch Image Optimizer
    echo ========================================================
    set /p "TARGET_DIR=Enter directory path (or drag and drop folder here): "
)

:: Strip enclosing quotes
set "TARGET_DIR=!TARGET_DIR:"=!"
:: Strip trailing backslash if present (prevents \" escaping issue in PowerShell CLI)
if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"

if not exist "!TARGET_DIR!\" (
    echo [ERROR] Target directory does not exist: "!TARGET_DIR!"
    if "%~1"=="" pause
    exit /b 1
)

:: ========================================================
:: 2. Max Size / Dimension Resolution
:: ========================================================
set "MAX_SIZE=%~2"
if "%MAX_SIZE%"=="" (
    set /p "MAX_SIZE=Enter max size in pixels [Press Enter for default: 2048]: "
)
if "!MAX_SIZE!"=="" set "MAX_SIZE=2048"

:: ========================================================
:: 3. Quality Resolution (50, 75, 90, 100)
:: ========================================================
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
echo Starting Batch Optimization
echo Target Directory : "!TARGET_DIR!"
echo Max Dimension    : !MAX_SIZE! px
echo Quality          : !QUALITY!%%
echo --------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0imgshrink-iterator.ps1" -Path "!TARGET_DIR!" -MaxWidth !MAX_SIZE! -Quality !QUALITY!

if "%~1"=="" (
    echo.
    echo Press any key to exit...
    pause >nul
)

endlocal
