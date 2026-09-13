# oskb (On-Screen Touch Keyboard)

A full-featured, responsive on-screen touch keyboard built for Arch Linux, Linux tablets, and touch-screen laptops (with dedicated support for the **Xiaomi Pad 5 (`nabu`)** under KDE Plasma Wayland/X11).

Built because default mobile/tablet keyboards (such as `plasma-keyboard`) lack essential desktop and terminal keys like navigation arrows, Esc, Ctrl, Alt, Delete, Tab, Function keys, and responsive resizing.

---

## Features

- **Full PC Keyboard Layout**:
  - **4 Navigation Arrows**: `←`, `↑`, `↓`, `→` with repeat support.
  - **Terminal & Desktop Essentials**: `Esc`, `Tab`, `Delete`, `Backspace`, `Enter`, `Space`, `Caps Lock`.
  - **Navigation Cluster**: `Home`, `End`, `PgUp`, `PgDn`, `Insert`.
  - **Sticky Modifiers**: `Ctrl`, `Alt`, `Super` (Windows/Meta), and `Shift` with visual latch lock.
  - **Full Function Keys**: `F1` through `F12` and `PrtSc` in dedicated Fn layer.
  - **Symbol & Numpad Layer**: Dedicated `?123` layer featuring full keypad, math operators, brackets, and clipboard shortcuts (`Undo`, `Cut`, `Copy`, `Paste`, `Select All`).
- **Dynamic Casing**:
  - Automatically renders lowercase letters (`q`, `w`, `e`...) when Caps Lock and Shift are OFF.
  - Switches to UPPERCASE (`Q`, `W`, `E`...) and shows shifted symbols when Shift is active or Caps Lock is ON.
  - One-shot Shift auto-releases back to lowercase after typing a character.
- **5 High-Contrast Visual Themes**:
  - **`dark`** (Default): Deep midnight frame with slate key surfaces and high-contrast white text (>15:1 contrast).
  - **`light`**: Soft slate frame with crisp white key tiles and dark charcoal lettering.
  - **`oled`**: True pitch-black `#000000` with cyber-cyan `#00ffcc` accents.
  - **`breeze`**: Matches KDE Plasma Breeze dark styling.
  - **`amber`**: Retro phosphor amber terminal CRT aesthetic.
- **Dock & Float Modes**:
  - **Dock Mode**: Snaps neatly to the bottom screen edge above the taskbar.
  - **Float Mode**: Drag anywhere on screen via the top header bar handle.
- **Responsive Sizing & Edge/Corner Resizing**:
  - **Preset Widths**: `S` (Compact 65%), `M` (Medium 82%), `L` (Full width 100%).
  - **Scale / Zoom Buttons**: `A-` / `A+` scale up or down smoothly.
  - **Edge & Corner Grips**: Drag through any edge or corner (`⤡`) to freely expand or shrink.
- **Auto-Popup Integration**:
  - Connects to Linux Atspi accessibility bus to automatically pop up when tapping on any focused text entry field.
  - One-tap toggle button (`⚡ Auto: ON/OFF`) directly in the header bar.
- **Floating Pill Minimization**:
  - Minimize button (`-`) collapses keyboard into a tiny floating pill (`⌨`) that stays out of your way and restores with a single tap.
- **Native `/dev/uinput` Key Injection**:
  - Uses kernel-level input subsystem injection. Injected keys work universally across Wayland native apps, Xwayland, GTK, Qt, Chromium, Firefox, Electron, Wine, and terminal emulators without stealing window focus.

---

## Installation

### From nabu pacman repository

```bash
sudo pacman -S oskb
```

### Building from PKGBUILD

```bash
git clone https://github.com/Kumar-Jy/nabu-pkgs.git
cd nabu-pkgs/packages/oskb
makepkg -si
```

---

## Service & Autostart

The package includes a systemd user service for automated background lifecycle management:

```bash
# Enable autostart with user graphical session
systemctl --user enable --now oskb.service

# Check service status
systemctl --user status oskb.service

# Restart service
systemctl --user restart oskb.service
```

---

## CLI & IPC Usage

Control the running keyboard instance from terminal, scripts, or KDE custom shortcuts:

```bash
oskb --show          # Show on-screen keyboard (default)
oskb --toggle        # Toggle visibility (show / hide)
oskb --hide          # Minimize to floating pill
oskb --theme <NAME>  # Switch theme (dark, light, oled, breeze, amber)
oskb --quit          # Terminate keyboard instance
```

---

## Configuration

Settings are saved automatically to `~/.config/oskb/config.json`:
- Active theme (`dark`, `light`, `oled`, `breeze`, `amber`)
- Dock mode (`dock` or `float`)
- Window position and floating geometry (`float_x`, `float_y`, `float_w`, `float_h`)
- Width preset (`full`, `medium`, `compact`) and scale factor
- Auto-popup preference (`auto_popup: true/false`)

---

## License

MIT License &copy; 2026 [Kumar-Jy](https://github.com/Kumar-Jy).

