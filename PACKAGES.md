# Packages Directory

This document lists all packages available in the `[nabu]` Arch Linux ARM repository for the **Xiaomi Pad 5 (nabu)** in a tabular format, including package names, install commands, and descriptions of what each package is for.

---

## Adding the Repository

Before installing any packages, ensure the `[nabu]` repository is configured in `/etc/pacman.conf`:

```ini
[nabu]
SigLevel = Never
Server = https://github.com/Kumar-Jy/nabu-pkgs/releases/download/repo
```

Synchronize the package database:

```bash
sudo pacman -Syu
```

---

## 1. System & Display Managers

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`sddm-nabu`** | `sudo pacman -S sddm-nabu` | Patched SDDM display manager for Xiaomi Pad 5. Fixes the black screen on "Switch User" after autologin by preventing VT 1 TTY allocation collision (`STRINGIFY` fix) and allowing session reuse for `sddm-autologin`. Provides and replaces upstream `sddm`. |
| **`upower-nncc`** | `sudo pacman -S upower-nncc` | Patched UPower power management daemon for Xiaomi Pad 5. Corrects battery capacity, charging status, and power metrics from the PM8150B fuel gauge PMIC. Replaces upstream `upower`. |

---

## 2. Hardware Video Acceleration & Media

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`iris-vaapi`** | `sudo pacman -S iris-vaapi` | VA-API hardware video decode driver for the Qualcomm Snapdragon 860 (SM8150) Iris VPU (H.264, HEVC 10-bit, VP9). Pinned to Fluster test-validated builds. |
| **`ffmpeg-iris`** | `sudo pacman -S ffmpeg-iris` | Self-contained FFmpeg build with Qualcomm Iris V4L2 mem2mem + DRM-Prime P010 (10-bit) hardware decoding. Isolated in `/usr/lib/iris-ffmpeg` with `ffmpeg-iris` and `ffprobe-iris` companion wrappers so it never conflicts with system FFmpeg. |
| **`mpv-iris`** | `sudo pacman -S mpv-iris` | Dedicated MPV launcher configured for Qualcomm Iris hardware video decode via `--hwdec=v4l2m2m` and `--vo=dmabuf-wayland` using the `ffmpeg-iris` libraries. |
| **`vlc-nabu`** | `sudo pacman -S vlc-nabu` | Hardware-accelerated VLC player launcher and dependencies for Xiaomi Pad 5. Configures VLC with Qualcomm Iris VA-API hardware decoding and installs a ready-to-use desktop application shortcut. |

---

## 3. Audio & Device Firmware

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`alsa-ucm-conf-xiaomi-nabu`** | `sudo pacman -S alsa-ucm-conf-xiaomi-nabu` | Custom ALSA Use Case Manager (UCM) profile for Xiaomi Pad 5. Configures 4-channel surround playback across all 4 speakers (Cirrus CS35L41 amplifiers) and disables broken internal mic capture to prevent PipeWire/WirePlumber sound card initialization errors. |
| **`linux-firmware-xiaomi-nabu`** | `sudo pacman -S linux-firmware-xiaomi-nabu` | Complete hardware firmware package for Xiaomi Pad 5 (Qualcomm DSP, ADSP, SLPI sensor island, Adreno 640 GPU, Bluetooth, and Wi-Fi blobs). |

---

## 4. Qualcomm Subsystems & Sensors

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`hexagonrpcd`** | `sudo pacman -S hexagonrpcd` | FastRPC reverse-listener service connecting Linux userspace to the Snapdragon SLPI (Sensor Low Power Island) filesystem. Required for hardware accelerometer, ambient light, and gyroscope sensors. |
| **`qrtr`** | `sudo pacman -S qrtr` | Qualcomm IPC Router userspace routing daemon managing `AF_QIPCRTR` communication with modem and DSP coprocessors. |
| **`rmtfs`** | `sudo pacman -S rmtfs` | Qualcomm Remote Filesystem daemon managing modem and DSP access to storage partition sectors and EFS calibration files. |
| **`tqftpserv`** | `sudo pacman -S tqftpserv` | Qualcomm TFTP server over QRTR/QMI for firmware and memory configuration transfers to DSP subsystems. |
| **`nabu-pmac`** | `sudo pacman -S nabu-pmac` | Generates a persistent, deterministic Wi-Fi MAC address derived from the tablet's unique motherboard serial number to prevent randomized MACs on boot. |
| **`nabu-tablet-mode`** | `sudo pacman -S nabu-tablet-mode` | Tablet mode helper daemon and post-suspend resume hook for GNOME and KDE Plasma to restore orientation and sensor tracking upon waking from sleep. |

---

## 5. Display & External Monitors

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`displaylink`** | `sudo pacman -S displaylink` | DisplayLink Manager userspace driver for USB external video adapters, docking stations, and multi-monitor setups. |
| **`evdi-dkms`** | `sudo pacman -S evdi-dkms` | Extensible Virtual Display Interface (EVDI) DKMS kernel module required by DisplayLink for rendering and routing external displays. |

---

## 6. Kernel & Drivers

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`linux-nabu-614`** | `sudo pacman -S linux-nabu-614 linux-nabu-614-headers` | Mainline Linux 6.14 kernel for Xiaomi Pad 5 (SM8150). Features DTS, Novatek NT36523 touchscreen + stylus pen, quad CS35L41 speaker routing, PM8150B charging, and Iris VPU suspend fixes. |
| **`linux-nabu-616`** | `sudo pacman -S linux-nabu-616 linux-nabu-616-headers` | Mainline Linux 6.16 series development kernel for Xiaomi Pad 5. |
| **`linux-nabu-618`** | `sudo pacman -S linux-nabu-618 linux-nabu-618-headers` | Mainline Linux 6.18 series testing kernel for Xiaomi Pad 5. |

---

## 7. Desktop Utilities & Applications

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`oskb`** | `sudo pacman -S oskb` | Responsive on-screen touch keyboard designed for touch Linux devices and KDE Plasma / GNOME. Features auto-adapt portrait/landscape layouts, navigation/arrow keys, function keys, key size scaling (S, M, L), font scaling, and floating/docked positioning. |
| **`nabu-autobrightness`** | `sudo pacman -S nabu-autobrightness` | Ambient light sensor auto-brightness daemon for Xiaomi Pad 5. Uses a calibrated logarithmic curve with hysteresis to prevent screen flicker; includes a desktop toggle and launcher. |
| **`camera-studio`** | `sudo pacman -S camera-studio` | GTK4/Libadwaita camera application featuring real-time tablet orientation tracking, VCM autofocus control (tap-to-focus, slider, presets), manual exposure and gain adjustment, color presets, and built-in photo gallery. |
| **`system-monitor`** | `sudo pacman -S system-monitor` | Universal hardware telemetry and system monitor for Linux displaying real-time CPU, Adreno 640 GPU usage, RAM, Running Applications / Processes (with search, filter, and task termination), battery charging power (W), and sensor statuses. Features an adaptive responsive UI with edge resizing. |
| **`nabu-torch`** | `sudo pacman -S nabu-torch` | Rear dual-LED flashlight controller for Xiaomi Pad 5 with interactive slider GUI, desktop toggle launcher, and CLI command (`torch on`, `torch off`, `torch set <val>`). |

---

## 8. Browsers & Development Tools

| Package | Install Command | What is this for? |
| :--- | :--- | :--- |
| **`google-chrome`** | `sudo pacman -S google-chrome` | Official Google Chrome Stable browser repackaged for Arch Linux ARM64 with Qualcomm Iris hardware video decoding support. |
| **`brave-bin`** | `sudo pacman -S brave-bin` | Brave privacy browser binary package for ARM64 with built-in ad and tracker blocking. |
| **`code`** | `sudo pacman -S code` | Visual Studio Code (Code - OSS) binary release for ARM64 with full desktop integration. |
| **`widevine`** | `sudo pacman -S widevine` | Widevine Content Decryption Module (CDM) for ARM64, enabling protected DRM content playback (Netflix, Spotify, Prime Video, Disney+) in web browsers. |
| **`bootc`** | `sudo pacman -S bootc` | Transactional boot and update controller for bootable container-based operating system images. |
| **`python2`** | `sudo pacman -S python2` | Legacy Python 2.7 runtime for compatibility with older tools and embedded device utilities. |
| **`edk2-aarch64`** | `sudo pacman -S edk2-aarch64` | UEFI firmware images for ARM64 virtual machines running under QEMU and KVM. |
