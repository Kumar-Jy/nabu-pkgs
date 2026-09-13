# camera-studio

A full-fledged camera and image processing application built for Arch Linux, tailored specifically for the **Xiaomi Pad 5 (`nabu`)** and compatible with any Linux PC or laptop.

Standard Linux camera apps like GNOME Snapshot offer almost no manual controls—no color adjustments, no resolution choices, and no format options. Furthermore, PipeWire camera portals often fail format negotiation on mainline mobile SoCs. **Camera Studio** talks directly to hardware through `libcamera` and GStreamer with Mesa FD640 EGL acceleration, giving you a smooth, lag-free viewfinder and deep image processing controls.

---

## Features

### 1. Real-time Image Color Tuning
- **Live Viewfinder Sliders**:
  - **Brightness**: fine-tune exposure levels (-1.00 to +1.00).
  - **Contrast**: adjust tone separation (0.00 to 2.00).
  - **Saturation**: adjust color intensity (from pure black-and-white monochrome to punchy saturation).
  - **Hue**: shift color tint across the spectrum (-1.00 to +1.00).
  - **Gamma**: adjust shadow-to-highlight midtone curves (0.20 to 2.50).
- **One-Tap Color Presets**:
  - 🌿 **Natural**: Clean, true-to-life colors.
  - 🌈 **Vivid**: Saturated punchy colors with high contrast.
  - 🎬 **Cinematic**: Filmic teal & moody tones.
  - 🌅 **Warm Sunset**: Golden hour warmth.
  - 🎞️ **Vintage Sepia**: Retro faded film look.
  - 🖤 **B&W Classic**: High-fidelity monochrome.
  - 🌌 **Noir**: Dramatic high-contrast shadows.
  - ❄️ **Nordic Cool**: Crisp blue highlights and clean whites.
- **One-Click Reset**: Restores all sliders back to pristine defaults.

### 2. Resolution & Output Customization
- **Resolution Presets**:
  - **Full Sensor Native**: Up to 13 MP (4200 × 3120) on Rear / 8 MP (3272 × 2464) on Front.
  - **4K UHD (16:9)**: 3840 × 2160 (8.3 MP).
  - **2K QHD (16:9)**: 2560 × 1440 (3.7 MP).
  - **Full HD (16:9)**: 1920 × 1080 (2.1 MP).
  - **HD (16:9)**: 1280 × 720 (0.9 MP).
  - **4:3 Standard**: 2048 × 1536 (3.1 MP).
  - **1:1 Square**: 2160 × 2160 (ideal for avatars & social media).
- **Output Formats**:
  - **JPEG (.jpg)**: With customizable compression quality slider (50% to 100%).
  - **PNG (.png)**: Uncompressed lossless image quality.
  - **WebP (.webp)**: Modern, highly-efficient image compression.
- **Storage**: Automatically saves timestamped files (`IMG_YYYYMMDD_HHMMSS.jpg`) into `~/Pictures/Camera/`.

### 3. Camera Controls & Viewfinder Tools
- **Multi-Camera Switching**: Seamless toggle between:
  - **Rear Camera**: OmniVision OV13B10 (13 Megapixels).
  - **Front Camera**: OmniVision OV8856 (8 Megapixels).
  - Any external USB webcam.
- **Mirroring (Selfie Flip)**: Auto-mirrors front selfie camera; toggleable anytime.
- **Rotation**: Rotate camera orientation in 90° increments.
- **Framing Grids**: Rule of Thirds (3×3), Golden Ratio, Center Crosshair, or Off.
- **Shutter Timer**: 3s, 5s, or 10s countdown with large on-screen animated timer.
- **Feedback**: Screen flash on capture and audio shutter click sound.
- **Screen Fill Light**: Soft white screen light for low-light selfie shots.

### 4. In-App Photo Gallery & Inspector
- Bottom thumbnail preview of the last taken photo.
- Clicking the thumbnail opens the photo inspector:
  - High-res photo preview with previous/next navigation.
  - Detailed metadata (dimensions, megapixels, file size, capture timestamp).
  - Direct actions: "Open in Loupe / Image Viewer", "Open Pictures Folder", and "Delete".

---

## Keyboard Shortcuts

| Key | Action |
| :--- | :--- |
| `Space` / `Return` | Capture Photo |
| `C` | Switch Front / Rear Camera |
| `F` | Cycle Flash Light / Torch Mode |
| `T` | Cycle Shutter Timer (Off / 3s / 5s / 10s) |
| `G` | Cycle Framing Grid (Off / 3×3 / Golden / Cross) |
| `M` | Toggle Mirror (Horizontal Flip) |
| `F11` | Toggle Fullscreen |
| `Esc` | Close Adjustment Drawer / Close App |
| `Ctrl+Q` / `Ctrl+W` | Exit / Close Camera Studio |

---

## Installation

Build and install using `makepkg`:

```bash
cd packages/camera-studio
makepkg -si
```

### Dependencies
- `python`
- `python-gobject`
- `libadwaita`
- `gtk4`
- `gstreamer`
- `gst-plugins-base`
- `gst-plugins-good`
- `gst-plugin-libcamera`
- `libcamera`
- `hicolor-icon-theme`

---

## Usage

Launch it from your desktop application drawer (**"Camera Studio"**) or from terminal:

```bash
# Main command
camera-studio

# Short aliases
pro-camera
cam-studio
```

---

## License & Copyright

Licensed under the **MIT License**.  
Copyright (c) 2026 Kumar-Jy. See [LICENSE](LICENSE) for details.
