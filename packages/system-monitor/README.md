# system-monitor

A lightweight, universal hardware and system monitor built for Arch Linux and Linux devices, with dedicated support for the **Xiaomi Pad 5 (`nabu`)** as well as standard PCs, laptops, and ARM single-board computers.

Most Linux system monitors do not expose Adreno GPU frequency/thermals, per-process DRM GPU render loads, or SoC big.LITTLE core metrics. This tool hooks directly into kernel `devfreq`, DRM `fdinfo`, and hardware thermal zones to give you instant hardware telemetry without unnecessary CPU overhead.

---

## Features

- **Universal GPU Telemetry**:
  - Qualcomm Adreno: tracks devfreq clock frequencies, scaling governors, and `gpu-top-thermal`.
  - AMD, Intel, Mali, Panfrost, Apple Silicon: monitors active GPU clients and memory via DRM `fdinfo`.
  - Real-time per-process GPU utilization and VRAM breakdown from `/proc/<pid>/fdinfo`.
- **Dynamic CPU Metrics**:
  - Auto-detects core counts dynamically across any machine (4, 8, 16, 32+ cores).
  - On Xiaomi Pad 5 (Snapdragon 855/860): identifies Kryo 485 Silver, Gold, and Gold Prime clusters with individual core thermal sensors.
  - On other PCs/SBCs: tracks per-core frequencies, usage bars, and CPU package thermals.
- **Memory & ZRAM**:
  - RAM usage, available headroom, cache/buffers breakdown.
  - Compressed ZRAM swap usage on `/dev/zram0` (or standard swap).
  - Top memory-consuming processes.
- **Device & Power**:
  - Battery percentage, charge status, charging rate in Watts, and battery temperature (supports `qcom-battery`, `BAT0`, `BAT1`).
  - Automatically identifies AC wall power on desktop systems without batteries.
  - Disk storage utilization.
  - Real-time upload and download speeds on the active network interface.
- **System Info**:
  - Live desktop environment detection (GNOME, KDE Plasma, XFCE, Cinnamon, Hyprland, Sway, etc.).
  - Kernel release, architecture, uptime, and load averages.
- **Diagnostic Logging**:
  - In-app **Export Log** button to save instant diagnostic snapshots to `~/Documents`.
  - CLI diagnostic mode via `--log` or `-l` for fast terminal dumps.

---

## Desktop Environment Support

Built with GTK4 and Libadwaita to adhere to modern FreeDesktop standards:
- **GNOME**: Native adaptive layout, header bar, and smooth view switcher.
- **KDE Plasma**: Auto-switches dark/light mode following the FreeDesktop appearance portal (`org.freedesktop.appearance.color-scheme`). Correct window grouping and launcher icon via `StartupWMClass`.
- **XFCE / Other DEs**: Standard window decorations, dual-installed icons in both `hicolor` and `/usr/share/pixmaps`.
- **Wayland & X11**: Works out of the box on both session types.

---

## Installation

Build and install using `makepkg`:

```bash
cd packages/system-monitor
makepkg -si
```

### Dependencies
- `python`
- `python-gobject`
- `libadwaita`
- `gtk4`
- `hicolor-icon-theme`

---

## Usage

Launch it from your desktop app drawer (**"System Monitor"**) or from terminal:

```bash
# Full command
system-monitor

# Short aliases
sysmon
nabu-system-monitor
```

### CLI Diagnostics

Dump diagnostic logs directly to stdout without launching the GUI:

```bash
# Print GPU stats
system-monitor --log gpu

# Print CPU per-core info
system-monitor --log cpu

# Dump full system diagnostics to a file
system-monitor --log all > ~/system-report.txt
```

---

## License & Copyright

Licensed under the **MIT License**.  
Copyright (c) 2026 Kumar-Jy and nabu-pkgs contributors. See [LICENSE](LICENSE) for details.
