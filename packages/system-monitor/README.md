# system-monitor

A lightweight, universal hardware and system monitor built for Arch Linux and Linux devices, with dedicated support for the **Xiaomi Pad 5 (`nabu`)** as well as standard PCs, laptops, and ARM single-board computers.

Most Linux system monitors do not expose Adreno GPU clock/thermals, per-process DRM GPU render loads, Qualcomm PMIC thermals, battery charge rate in Watts, or big.LITTLE core metrics. This tool hooks directly into kernel `devfreq`, DRM `fdinfo`, `power_supply`, and hardware thermal zones to give you real-time hardware telemetry without CPU overhead.

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
- **Battery & Charging Monitor**:
  - State of charge with live visual level gauge.
  - Real-time charging / discharging power rate in Watts ($V \times I$).
  - High-precision voltage ($V$) and current ($mA$) telemetry.
  - Battery capacity and design energy (8,720 mAh / 33.6 Wh on Pad 5).
  - Cell temperature and battery health condition.
  - Runtime remaining and time-to-full estimation.
  - Charger connection status, hardware controller (`PM8150B Charger IC`), and protocol detection (`USB-PD PPS Fast Charge`, `DCP`, `CDP`, `SDP`).
  - Charger input voltage, current limits, and charger IC temperature.
- **Comprehensive Sensor & Thermal Monitor**:
  - Dynamic grouping of 28+ SoC and board thermal sensors:
    - **CPU & Compute**: Silver Little cores (0-3), Gold Big cores (4-6 Top/Bottom), Gold Prime Super core (7 Top/Bottom), Silicon Clusters, AI Compute DSP & Hexagon HVX.
    - **Graphics & Multimedia**: Adreno 640 GPU, Iris Video Processor (VPU), CamSS ISP Camera Subsystem.
    - **PMIC & System**: PM8150 Master PMIC, PM8150B Charger PMIC, PM8150L Secondary PMIC, DRAM Memory, Wi-Fi WLAN, Cellular Modem, Always-On Subsystem (AOSS).
    - **Hardware State**: Tablet Mode switch sensor, 3.5mm Headset Jack detection, PMIC ADC channels.
  - Universal fallback for generic Linux PCs/laptops scanning all `/sys/class/thermal` and `/sys/class/hwmon` nodes.
  - Visual color-coded temperature badges (🟢 Cool, 🔵 Normal, 🟡 Warm, 🔴 Hot).
- **Device & Storage**:
  - Storage telemetry for root (`/`) and EFI system partition (`/boot/efi`).
  - Real-time network throughput (upload and download speeds) on the active interface.
  - Input hardware detection (Touchscreen, Stylus pen, Keyboard dock).
- **System Information & Diagnostics**:
  - Desktop environment detection (GNOME, KDE Plasma, XFCE, Cinnamon, Hyprland, Sway, etc.).
  - Kernel release, architecture, uptime, and load averages.
  - One-click and CLI export for full diagnostics or category-specific reports (`~/Documents/sysmon-*-log-*.txt`).

---

## Installation

### From Arch Linux Package (`nabu-pkgs` repository)

```bash
cd packages/system-monitor
makepkg -si
```

### CLI Symlinks Provided

The package provides the following symlinks:
- `system-monitor`
- `sysmon`
- `nabu-system-monitor`
- `nabu-gpu-monitor`

---

## Command-Line Interface (Diagnostics)

Generate instant diagnostic text reports from the terminal:

```bash
# Print complete system diagnostic report
sysmon --log all

# Print battery and charging telemetry
sysmon --log power

# Print all thermal zones and hardware sensors
sysmon --log sensors

# Print GPU clocks, temperatures, and active DRM clients
sysmon --log gpu

# Print CPU load and per-core frequencies
sysmon --log cpu

# Print memory and swap allocation
sysmon --log memory
```

---

## License

MIT License &copy; 2026 Kumar-Jy.
