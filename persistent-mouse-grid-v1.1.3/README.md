# persistent-mouse-grid

A lightweight, zero-footprint, transparent screen overlay grid for Windows 11 designed for rapid voice navigation (e.g., Windows Voice Access) and precise coordinate referencing. Unlike default OS voice grids that disappear after clicking, this grid remains persistent, fully transparent, and non-intrusive until toggled.

**System Requirements**: Windows 10 / 11 (64-bit). Native Win32 / GDI+ execution with zero runtime dependencies.

## Key Features
- **True Pass-Through**: Clicks, keyboard input, scrolls, and hovers pass directly to underlying applications without lag or focus stealing (`WS_EX_TRANSPARENT | WS_EX_NOACTIVATE`).
- **Hierarchical Grid**: 9×9 primary cell grid with nested 3×3 subgrids and high-contrast numbered badges.
- **Multi-Monitor Support**: Automatically detects and renders native-resolution grids across all displays (`target_display: "all"`, `"primary"`, or monitor index) with dynamic `WM_DISPLAYCHANGE` hotplug handling.
- **Hot-Reloading Config**: Modifying `grid_config.json` automatically refreshes grid geometry, colors, opacities, and typography without restarting.
- **Global Hotkey & Tray**: Press `Ctrl+Shift+G` to instantly toggle visibility. Right-click the system tray icon to toggle, reload config, or exit.

## Quick Start & Usage

1. **Launch**:
   Run `mouse_grid.exe`. The grid overlay will appear on all configured displays and a system tray icon will appear in the taskbar.

2. **Toggle Visibility**:
   - Press **`Ctrl+Shift+G`** (default hotkey), or
   - Right-click the tray icon and select **Toggle Grid**.

3. **Configure**:
   Edit `grid_config.json` in the same directory to customize:
   - Line colors, thicknesses, and alpha transparencies.
   - Badge font family, size, text color, and background opacity.
   - Target displays (`"all"`, `"primary"`, `"1"`, `"2"`).
   - Global toggle hotkey combination.
   Changes apply automatically upon saving the file.

4. **Environment PATH Registration (Optional)**:
   - Run `register_path.ps1` to add the directory to your User `PATH` (enabling `mouse_grid` from any terminal or Run dialog).
   - Run `unregister_path.ps1` to remove it from `PATH`.

---
```
# Copyright (c) 2026:
# [>_<] vatofichor - Sebastian Mass
#  /|\  & Antigravity 🤖
```
