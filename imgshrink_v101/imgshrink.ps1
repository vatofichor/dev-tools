<#
.SYNOPSIS
    imgshrink - Automated image downscaling and compression for web & social publishing.
.DESCRIPTION
    Loads images, resizes them to a specified maximum dimension (maintaining aspect ratio),
    and saves them while strictly preserving native format (PNG stays PNG, JPG stays JPG at specified quality).
.PARAMETER Path
    The directory or single image path to scan and process. Defaults to current directory.
.PARAMETER File
    Specific single file path to process.
.PARAMETER MaxWidth
    The maximum dimension allowed (width or height). Defaults to 2048.
.PARAMETER Quality
    The JPEG compression quality (1-100). Defaults to 90.
.NOTES
    Copyright (c) 2026:
    vatofichor - Sebastian Mass     [>_<]
    & Assisted By Gemini Antigravity /|\
    Licensed under the MIT License.
#>

param(
    [Alias("Target", "InputPath")]
    [string]$Path = "",
    [string]$File = "",
    [int]$MaxWidth = 2048,
    [int]$Quality = 90
)

# Set TLS protocol and Load System.Drawing
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing

$targetInput = if (-not [string]::IsNullOrWhiteSpace($File)) {
    $File.Trim('"')
} elseif (-not [string]::IsNullOrWhiteSpace($Path)) {
    $Path.Trim('"')
} else {
    "."
}

$files = @()

if (Test-Path -Path $targetInput -PathType Leaf) {
    $files = @(Get-Item -LiteralPath $targetInput)
} elseif (Test-Path -Path $targetInput -PathType Container) {
    Write-Host "Scanning directory: $targetInput for image files..."
    $files = @(Get-ChildItem -LiteralPath $targetInput -Recurse -File | Where-Object { $_.Extension -match '^\.(jpe?g|png|bmp)$' })
} else {
    Write-Host "Specified path or file not found: $targetInput" -ForegroundColor Red
    Exit 1
}

if ($files.Count -eq 0) {
    Write-Host "No image files found to optimize."
    Exit 0
}

Write-Host "Found $($files.Count) image(s) to optimize."

foreach ($imgFile in $files) {
    $oldSize = $imgFile.Length
    Write-Host "--------------------------------------------------"
    Write-Host "Optimizing: $($imgFile.Name) (Current size: [$(($oldSize/1KB).ToString('F2')) KB])"
    
    $srcImage = $null
    $newBitmap = $null
    $g = $null
    $tempPath = $imgFile.FullName + ".tmp"
    
    try {
        # Load image via absolute FullName
        $srcImage = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        # Auto-rotate based on EXIF orientation (tag 0x0112)
        if ($srcImage.PropertyIdList -contains 0x0112) {
            try {
                $orientation = [BitConverter]::ToUInt16($srcImage.GetPropertyItem(0x0112).Value, 0)
                switch ($orientation) {
                    2 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX) }
                    3 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
                    4 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipX) }
                    5 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipX) }
                    6 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
                    7 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipX) }
                    8 { $srcImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
                }
            } catch {
                # Fallback gracefully if EXIF item is unreadable
            }
        }
        
        $srcWidth = $srcImage.Width
        $srcHeight = $srcImage.Height
        $ext = $imgFile.Extension.ToLower()
        
        # Calculate new dimensions preserving aspect ratio
        if ($srcWidth -gt $MaxWidth -or $srcHeight -gt $MaxWidth) {
            $ratio = [math]::Min($MaxWidth / $srcWidth, $MaxWidth / $srcHeight)
            $newWidth = [math]::Max(1, [math]::Round($srcWidth * $ratio))
            $newHeight = [math]::Max(1, [math]::Round($srcHeight * $ratio))
            Write-Host "-> Resizing from ${srcWidth}x${srcHeight} to ${newWidth}x${newHeight}"
        }
        else {
            $newWidth = $srcWidth
            $newHeight = $srcHeight
            Write-Host "-> Keeping original resolution ${srcWidth}x${srcHeight}"
        }
        
        # Create new bitmap
        $newBitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $g = [System.Drawing.Graphics]::FromImage($newBitmap)
        
        # Set high quality rendering options
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        
        # Draw image
        $g.DrawImage($srcImage, 0, 0, $newWidth, $newHeight)
        
        # Release graphics and original image to allow overwrite
        $g.Dispose()
        $g = $null
        $srcImage.Dispose()
        $srcImage = $null
        
        # Save keeping NATIVE format (PNG -> PNG, BMP -> BMP, JPG -> JPG)
        if ($ext -eq ".png") {
            Write-Host "-> Saving as lossless/optimized PNG (format preserved)"
            $newBitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } elseif ($ext -eq ".bmp") {
            Write-Host "-> Saving as standard BMP (format preserved)"
            $newBitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
        } else {
            Write-Host "-> Saving as high-quality JPEG (Quality: $Quality%)"
            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)
            $newBitmap.Save($tempPath, $jpegCodec, $encoderParams)
        }
        
        $newBitmap.Dispose()
        $newBitmap = $null
        
        # Check size before replacing
        $tempSize = (Get-Item -LiteralPath $tempPath).Length
        
        # If temp image is smaller or resized, atomically replace original
        if ($tempSize -lt $oldSize -or $srcWidth -gt $MaxWidth -or $srcHeight -gt $MaxWidth) {
            $bakPath = $imgFile.FullName + ".bak"
            try {
                [System.IO.File]::Replace($tempPath, $imgFile.FullName, $bakPath)
                if (Test-Path -LiteralPath $bakPath) {
                    Remove-Item -LiteralPath $bakPath -Force -ErrorAction SilentlyContinue
                }
            } catch {
                # Fallback to Move-Item if atomic Win32 replace encounters a lock or permission issue
                Move-Item -LiteralPath $tempPath -Destination $imgFile.FullName -Force
            }
            $newSize = (Get-Item -LiteralPath $imgFile.FullName).Length
            $reduction = if ($oldSize -gt 0) { (1 - ($newSize / $oldSize)) * 100 } else { 0 }
            Write-Host "-> Optimization completed."
            Write-Host "-> New size: [$(($newSize/1KB).ToString('F2')) KB] (Reduced by $($reduction.ToString('F1'))%)"
        } else {
            Remove-Item -LiteralPath $tempPath -Force
            Write-Host "-> Original file is already optimally compressed [$(($oldSize/1KB).ToString('F2')) KB]. Retained original file."
        }
    }
    catch {
        Write-Host "Error processing $($imgFile.Name): $_" -ForegroundColor Red
        if ($null -ne $g) { $g.Dispose(); $g = $null }
        if ($null -ne $srcImage) { $srcImage.Dispose(); $srcImage = $null }
        if ($null -ne $newBitmap) { $newBitmap.Dispose(); $newBitmap = $null }
        if (Test-Path -LiteralPath $tempPath) {
            Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath ($imgFile.FullName + ".bak")) {
            Move-Item -LiteralPath ($imgFile.FullName + ".bak") -Destination $imgFile.FullName -Force -ErrorAction SilentlyContinue
        }
        throw $_
    }
}
Write-Host "=================================================="
Write-Host "Image optimization task complete!"
