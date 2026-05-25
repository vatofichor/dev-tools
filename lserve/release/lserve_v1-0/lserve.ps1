# lserve.ps1
#
# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\  
#
# Licensed under the MIT License. See LICENSE file in the project root for full license text.
#
param(
    [Parameter(Mandatory=$true)]
    [int]$Port
)

Write-Host "Starting PHP server on http://localhost:$Port ..."
php -S localhost:$Port