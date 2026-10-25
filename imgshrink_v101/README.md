# imgshrink

Lightweight image downscaler and optimizer for Windows. Easily resize and compress images for web and social media while preserving visual quality and native file formats.

Built using native Windows .NET libraries with **zero external dependencies** or software installations required.

---

## Quick Start (Drag & Drop)

- **Single Image**: Drag and drop any image onto **`imgshrink.bat`**.
- **Whole Folder**: Drag and drop any folder onto **`imgshrink-iterator.bat`**.

Follow the on-screen prompts for size and quality, or press **Enter** to accept the recommended defaults.

---

## Tools

### 1. `imgshrink.bat` (Single Image)
Optimizes a single image file.

- **Interactive**: Double-click `imgshrink.bat` or drag and drop a file onto it.
- **Command Line**:
  ```cmd
  imgshrink.bat "path\to\image.png" [max_size] [quality]
  ```
- **Options**:
  - **Max Size**: Maximum width or height in pixels (Default: `2048`px).
  - **Quality**: Choose `50` (compact), `75` (balanced), `90` (high quality, default), or `100` (maximum).

### 2. `imgshrink-iterator.bat` (Folder Batch)
Scans an entire folder and its subfolders for images (`.jpg`, `.jpeg`, `.png`, `.bmp`) and processes them one by one.

- **Interactive**: Double-click `imgshrink-iterator.bat` or drag and drop a folder onto it.
- **Command Line**:
  ```cmd
  imgshrink-iterator.bat "path\to\images" [max_size] [quality]
  ```
- **Fault Tolerant**: If any image cannot be processed (corrupt file, 0-byte file, locked handle), it **skips the file automatically** and writes an entry to **`imgshrink_errors.log`** inside that folder without interrupting the rest of the batch.

---

## Developer Reference (CLI & PowerShell)

Both batch files are thin wrappers around standalone PowerShell scripts that can be called directly in terminal pipelines:

```powershell
# Optimize a single file
powershell -ExecutionPolicy Bypass -File imgshrink.ps1 -File "assets\banner.png" -MaxWidth 1920 -Quality 85

# Optimize an entire folder
powershell -ExecutionPolicy Bypass -File imgshrink-iterator.ps1 -Path "content\images" -MaxWidth 1200 -Quality 75
```

### Script Parameters
| Parameter | Default | Description |
| :--- | :--- | :--- |
| `-File` | *None* | Path to a single image file to optimize. |
| `-Path` | `.` | Target folder to process recursively. |
| `-MaxWidth` | `2048` | Maximum pixel dimension (width or height) allowed before resizing. |
| `-Quality` | `90` | JPEG compression quality level (1–100). |

---

## How It Works
- **Format Preservation**: PNGs stay PNGs with transparency intact; JPEGs are compressed using high-bicubic interpolation.
- **Safe Replacement**: Files are only overwritten if the new image is actually smaller in size or downscaled. If the original is already optimal, it is left untouched.
- **No Dependencies**: Uses Windows PowerShell 5.1+ and .NET `System.Drawing`.

---

## License
MIT License.

---
```
# Copyright (c) 2026:
# vatofichor - Sebastian Mass     [>_<]
# & Assisted By Gemini Antigravity /|\
```
