# Packages Directory

This document lists all packages available in the `[nabu]` Arch Linux ARM repository for the **Xiaomi Pad 5 (nabu)**, including installation commands and descriptions of what each package is for.

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

## Categories

- [System & Display Managers](#system--display-managers)
- [Hardware Video Acceleration & Media](#hardware-video-acceleration--media)
- [Audio & Device Firmware](#audio--device-firmware)
- [Qualcomm Subsystems & Sensors](#qualcomm-subsystems--sensors)
- [Display & External Monitors](#display--external-monitors)
- [Kernel & Headers](#kernel--headers)
- [Desktop Utilities & Applications](#desktop-utilities--applications)
- [Browsers & Development Tools](#browsers--development-tools)

---

## System & Display Managers

### `sddm-nabu`
* **Install:**
  ```bash
  sudo pacman -S sddm-nabu
  ```
* **Description:**
  Patched build of SDDM (Simple Desktop Display Manager) specifically designed for the Xiaomi Pad 5.
  * Fixes the black screen bug on "Switch User" when autologin is enabled by fixing TTY stringification and preventing VT 1 allocation collisions with active Wayland sessions.
  * Adds autologin session reuse (`sddm-autologin`) to prevent DRM master contention.
  * Drop-in replacement that provides, conflicts with, and replaces upstream `sddm`.

### `upower-nncc`
* **Install:**
  ```bash
  sudo pacman -S upower-nncc
  ```
* **Description:**
  Patched UPower power management abstraction daemon for the Xiaomi Pad 5.
  * Corrects battery reporting, charging detection, and capacity metrics from the PM8150B PMIC fuel gauge.
  * Replaces upstream `upower` to prevent erroneous low-battery warnings and sleep triggers.

---

## Hardware Video Acceleration & Media

### `iris-vaapi`
* **Install:**
  ```bash
  sudo pacman -S iris-vaapi
  ```
* **Description:**
  VA-API hardware video acceleration driver for the Qualcomm Snapdragon 860 (SM8150) Iris VPU.
  * Enables hardware decoding for H.264, HEVC (H.265), and VP9 videos in supported media players and browsers.
  * Pinned to verified Fluster-passing builds.

### `ffmpeg-iris`
* **Install:**
  ```bash
  sudo pacman -S ffmpeg-iris
  ```
* **Description:**
  Companion FFmpeg build patched with Qualcomm Iris V4L2 mem2mem and DRM-Prime P010 (10-bit) hardware decoding.
  * Installed in an isolated private directory (`/usr/lib/iris-ffmpeg`) with `ffmpeg-iris` and `ffprobe-iris` wrapper commands so it never conflicts with the system FFmpeg.

### `mpv-iris`
* **Install:**
  ```bash
  sudo pacman -S mpv-iris
  ```
* **Description:**
  Hardware-accelerated MPV player launcher configured to use `ffmpeg-iris`.
  * Pre-configured with `--hwdec=v4l2m2m` and `--vo=dmabuf-wayland` for smooth, low-power video playback on Wayland.

---

## Audio & Device Firmware

### `alsa-ucm-conf-xiaomi-nabu`
* **Install:**
  ```bash
  sudo pacman -S alsa-ucm-conf-xiaomi-nabu
  ```
* **Description:**
  Custom ALSA Use Case Manager (UCM) profile for the Xiaomi Pad 5 audio subsystem.
  * Enables 4-channel surround sound routing across all 4 physical speakers (Cirrus CS35L41 amplifiers).
  * Disables non-functional microphone capture endpoints to prevent PipeWire and WirePlumber initialization rejections.

### `linux-firmware-xiaomi-nabu`
* **Install:**
  ```bash
  sudo pacman -S linux-firmware-xiaomi-nabu
  ```
* **Description:**
  Complete hardware firmware package extracted and packaged for the Xiaomi Pad 5.
  * Includes Qualcomm DSP, ADSP, SLPI sensor island, Adreno 640 GPU, Bluetooth, and Wi-Fi firmware files.

---

## Qualcomm Subsystems & Sensors

### `hexagonrpcd`
* **Install:**
  ```bash
  sudo pacman -S hexagonrpcd
  ```
* **Description:**
  Qualcomm FastRPC reverse-listener daemon exposing the SLPI (Sensor Low Power Island) filesystem.
  * Required for communication with onboard hardware sensors (accelerometer, ambient light sensor, gyroscope).

### `qrtr`
* **Install:**
  ```bash
  sudo pacman -S qrtr
  ```
* **Description:**
  Userspace router daemon for the Qualcomm IPC Router (QRTR) protocol (`AF_QIPCRTR`), enabling messaging between the kernel and Qualcomm DSP coprocessors.

### `rmtfs`
* **Install:**
  ```bash
  sudo pacman -S rmtfs
  ```
* **Description:**
  Remote Filesystem service for Qualcomm modems and DSPs, handling access to partition sectors and EFS calibration files.

### `tqftpserv`
* **Install:**
  ```bash
  sudo pacman -S tqftpserv
  ```
* **Description:**
  Trivial File Transfer Protocol (TFTP) server running over QRTR/QMI, allowing Qualcomm remote processors to read configuration and firmware assets.

### `nabu-pmac`
* **Install:**
  ```bash
  sudo pacman -S nabu-pmac
  ```
* **Description:**
  Persistent MAC address generator service for the tablet's Wi-Fi interface.
  * Derives a consistent, static MAC address from the tablet's motherboard serial number to avoid random MAC addresses across reboots.

### `nabu-tablet-mode`
* **Install:**
  ```bash
  sudo pacman -S nabu-tablet-mode
  ```
* **Description:**
  Tablet mode state helper and systemd sensor resume hook for GNOME and KDE Plasma.
  * Re-initializes sensor daemons and accelerometer orientation tracking upon waking up from suspend/sleep.

---

## Display & External Monitors

### `displaylink`
* **Install:**
  ```bash
  sudo pacman -S displaylink
  ```
* **Description:**
  DisplayLink Manager userspace driver for USB external monitors, docks, and video adapters on Linux.

### `evdi-dkms`
* **Install:**
  ```bash
  sudo pacman -S evdi-dkms
  ```
* **Description:**
  Extensible Virtual Display Interface (EVDI) kernel module required by DisplayLink to manage and route multiple external screens.

---

## Kernel & Headers

### `linux-nabu-614`
* **Install:**
  ```bash
  sudo pacman -S linux-nabu-614 linux-nabu-614-headers
  ```
* **Description:**
  Mainline Linux 6.14 kernel package customized for Xiaomi Pad 5 (SM8150).
  * Includes Xiaomi Pad 5 Device Tree (DTS), Novatek NT36523 touchscreen and Xiaomi Smart Pen stylus driver, quad-speaker routing, PM8150B charger support, and Iris VPU suspend fixes.

### `linux-nabu-616`
* **Install:**
  ```bash
  sudo pacman -S linux-nabu-616 linux-nabu-616-headers
  ```
* **Description:**
  Mainline Linux 6.16 series development kernel for Xiaomi Pad 5.

### `linux-nabu-618`
* **Install:**
  ```bash
  sudo pacman -S linux-nabu-618 linux-nabu-618-headers
  ```
* **Description:**
  Mainline Linux 6.18 series testing kernel for Xiaomi Pad 5.

---

## Desktop Utilities & Applications

### `oskb`
* **Install:**
  ```bash
  sudo pacman -S oskb
  ```
* **Description:**
  Full-featured responsive on-screen touch keyboard designed for touch Linux devices and KDE Plasma / GNOME.
  * Automatically adapts layout between landscape and portrait orientations.
  * Includes dedicated navigation/arrow keys, function keys, key size scaling (S, M, L), font scaling, and floating/docked positioning.

### `nabu-autobrightness`
* **Install:**
  ```bash
  sudo pacman -S nabu-autobrightness
  ```
* **Description:**
  Ambient light auto-brightness daemon calibrated for the Xiaomi Pad 5 sensor.
  * Features a smooth logarithmic response curve with hysteresis and rate-limited transitions to prevent screen flicker.
  * Includes a desktop entry and toggle script for quick enable/disable.

### `camera-studio`
* **Install:**
  ```bash
  sudo pacman -S camera-studio
  ```
* **Description:**
  Native hardware camera application built with GTK4 and Libadwaita.
  * Supports real-time orientation tracking, voice coil motor (VCM) lens focus controls (tap-to-focus, slider, presets), manual exposure and gain adjustment, color presets, and built-in photo gallery.

### `system-monitor`
* **Install:**
  ```bash
  sudo pacman -S system-monitor
  ```
* **Description:**
  Universal hardware telemetry and system monitor for Linux.
  * Displays real-time CPU, Adreno 640 GPU usage, RAM, temperatures, battery charge rate, and sensor statuses across all desktop environments.

### `nabu-torch`
* **Install:**
  ```bash
  sudo pacman -S nabu-torch
  ```
* **Description:**
  Rear dual-LED flashlight / torch controller for the Xiaomi Pad 5.
  * Provides both a desktop UI toggle slider and a command-line utility (`torch on`, `torch off`, `torch set <value>`) with udev permissions.

---

## Browsers & Development Tools

### `google-chrome`
* **Install:**
  ```bash
  sudo pacman -S google-chrome
  ```
* **Description:**
  Official Google Chrome Stable browser repackaged for Arch Linux ARM64 with Qualcomm Iris hardware video acceleration support.

### `brave-bin`
* **Install:**
  ```bash
  sudo pacman -S brave-bin
  ```
* **Description:**
  Brave web browser binary release for ARM64 with built-in tracker and ad blocking.

### `code`
* **Install:**
  ```bash
  sudo pacman -S code
  ```
* **Description:**
  Visual Studio Code (Code - OSS) binary package built for ARM64 Linux.

### `widevine`
* **Install:**
  ```bash
  sudo pacman -S widevine
  ```
* **Description:**
  Widevine Content Decryption Module (CDM) for ARM64, enabling protected DRM content playback (Netflix, Spotify, Disney+, Prime Video) in browsers.

### `bootc`
* **Install:**
  ```bash
  sudo pacman -S bootc
  ```
* **Description:**
  Boot and update controller tool for bootable container-based operating system images.

### `python2`
* **Install:**
  ```bash
  sudo pacman -S python2
  ```
* **Description:**
  Legacy Python 2.7 runtime for older development tools and firmware flashing utilities.

### `edk2-aarch64`
* **Install:**
  ```bash
  sudo pacman -S edk2-aarch64
  ```
* **Description:**
  UEFI firmware images for ARM64 virtual machines running under QEMU and KVM.
