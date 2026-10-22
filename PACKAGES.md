# Package Catalog (Ubuntu / Debian)

This document lists all packages available in the **`nabu-pkgs` Ubuntu repository**.

---

## 📦 Kernel Packages

| Package | Source | Description |
| :--- | :--- | :--- |
| **`linux-image-*`** | [`Kumar-Jy/linux`](https://github.com/Kumar-Jy/linux) | Mainline Linux kernel for SM8150 Xiaomi Pad 5 (includes 120Hz display, CS35L41 audio, and Iris video decode). |
| **`linux-headers-*`** | [`Kumar-Jy/linux`](https://github.com/Kumar-Jy/linux) | Kernel headers matching the running kernel for building on-device DKMS modules (e.g. DisplayLink). |
| **`linux-libc-dev`** | [`Kumar-Jy/linux`](https://github.com/Kumar-Jy/linux) | Linux API headers for userspace development. |

---

## 📱 Hardware & Sensor Daemons

| Package | Description |
| :--- | :--- |
| **`nabu-tablet-mode`** | Exposes tablet mode to GNOME Mutter and KDE Plasma for automatic screen rotation, handles sensor sleep/wake recovery, and provides the `nabu-tablet-toggle` CLI tool. |
| **`nabu-autobrightness`** | Intelligent ambient light sensor daemon that smoothly adjusts backlight brightness based on lux readings over SLPI. Includes a quick toggle desktop shortcut. |
| **`nabu-torch`** | Dual rear camera flash controller with GUI slider intensity control, CLI tool (`torch` / `flashlight`), and quick toggles. |
| **`nabu-pmac`** | Derives a permanent, deterministic Wi-Fi MAC address from the SoC serial number to prevent random MAC changes across reboots. |

---

## 🔊 Audio & Firmware

| Package | Description |
| :--- | :--- |
| **`xiaomi-nabu-alsa`** | ALSA Use Case Manager (UCM2) configuration for quad Cirrus CS35L41 speakers and 24-bit microphone routing. |
| **`xiaomi-nabu-firmware`** | Proprietary Qualcomm DSP, Hexagon, sensor, Ath10k Wi-Fi/BT, and Cirrus amp firmware blobs. |

---

## 🛠️ Installation Commands

Once the repository is configured in `/etc/apt/sources.list.d/nabu.sources`:

```bash
# Refresh index
sudo apt update

# Install all hardware support daemons
sudo apt install -y \
  xiaomi-nabu-alsa \
  xiaomi-nabu-firmware \
  nabu-tablet-mode \
  nabu-autobrightness \
  nabu-torch \
  nabu-pmac

# Upgrade installed kernel and system packages
sudo apt upgrade
```
