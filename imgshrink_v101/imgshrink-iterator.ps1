<#
.SYNOPSIS
    imgshrink-iterator - Directory image batch optimizer with resilient error logging.
.DESCRIPTION
    Scans a specified directory (recursively) for image files and delegates each file
    to imgshrink.ps1. Unprocessable or corrupted files are caught, skipped, and logged
    to 'imgshrink_errors.log' in the target directory without interrupting the batch.
.PARAMETER Path
    Directory to scan. Defaults to current directory.
.PARAMETER MaxWidth
    Maximum width/height dimension in pixels. Defaults to 2048.
.PARAMETER Quality
    JPEG quality level (1-100). Defaults to 90.
.PARAMETER LogName
    Error log filename created in the target directory. Defaults to 'imgshrink_errors.log'.
.NOTES
    Copyright (c) 2026:
    vatofichor - Sebastian Mass     [>_<]
    & Assisted By Gemini Antigravity /|\
    Licensed under the MIT License.
#>

param(
    [Alias("Target", "Dir", "Directory")]
    [string]$Path = ".",
    [int]$MaxWidth = 2048,
    [int]$Quality = 90,
    [string]$LogName = "imgshrink_errors.log"
)

# Resolve target directory
$targetDir = $Path.Trim('"')
if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
    Write-Host "[ERROR] Directory not found: $targetDir" -ForegroundColor Red
    Exit 1
}

$resolvedDir = (Get-Item -LiteralPath $targetDir).FullName
$logFile = Join-Path -Path $resolvedDir -ChildPath $LogName
$engineScript = Join-Path -Path $PSScriptRoot -ChildPath "imgshrink.ps1"

if (-not (Test-Path -LiteralPath $engineScript -PathType Leaf)) {
    Write-Host "[ERROR] Core engine not found at: $engineScript" -ForegroundColor Red
    Exit 1
}

Write-Host "========================================================"
Write-Host "imgshrink-iterator"
Write-Host "Directory     : $resolvedDir"
Write-Host "Max Dimension : $MaxWidth px"
Write-Host "JPEG Quality  : $Quality%"
Write-Host "Error Log     : $logFile"
Write-Host "========================================================"

# Scan for supported images strictly
$imageRegex = '^\.(jpe?g|png|bmp)$'
$files = @(Get-ChildItem -LiteralPath $resolvedDir -Recurse -File | Where-Object { $_.Extension -match $imageRegex })

if ($files.Count -eq 0) {
    Write-Host "No matching image files (*.jpg, *.jpeg, *.png, *.bmp) found in: $resolvedDir"
    Exit 0
}

Write-Host "Found $($files.Count) image file(s) to process.`n"

$successCount = 0
$errorCount = 0
$index = 0

foreach ($imgFile in $files) {
    $index++
    $relPath = $imgFile.FullName.Substring($resolvedDir.Length).TrimStart('\', '/')
    Write-Host "`n[$index/$($files.Count)] >>> $relPath"
    
    try {
        # Delegate single-file optimization to imgshrink.ps1
        & $engineScript -File $imgFile.FullName -MaxWidth $MaxWidth -Quality $Quality -ErrorAction Stop
        $successCount++
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Host "   [SKIPPED] Failed: $errorMsg" -ForegroundColor Yellow
        $errorCount++
        
        # Log error to target directory log file
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $logEntry = "[$timestamp] [SKIPPED] File: `"$($imgFile.FullName)`" | Error: $errorMsg"
        Add-Content -LiteralPath $logFile -Value $logEntry -Encoding UTF8
    }
}

Write-Host "`n========================================================"
Write-Host "Batch Processing Summary"
Write-Host "  Total Files Scanned   : $($files.Count)"
Write-Host "  Successfully Processed: $successCount"
Write-Host "  Skipped / Failures    : $errorCount"
if ($errorCount -gt 0) {
    Write-Host "`n[!] $errorCount failure(s) logged to: $logFile" -ForegroundColor Yellow
} else {
    Write-Host "  All files processed cleanly." -ForegroundColor Green
}
Write-Host "========================================================"
