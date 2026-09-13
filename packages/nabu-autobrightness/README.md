# nabu-autobrightness

Intelligent Ambient Light Screen Auto-Brightness Daemon for Xiaomi Pad 5 (`nabu`) running Arch Linux ARM / KDE Plasma 6.

## Highlights

- **Hardware Light Sensor**: Directly interfaces with `net.hadess.SensorProxy` (`iio-sensor-proxy`) to read the Xiaomi Pad 5 ambient light sensor.
- **KDE Plasma 6 Silent Integration**: Modulates screen brightness silently via `org.kde.Solid.PowerManagement.Actions.BrightnessControl` (`setBrightnessSilent`), updating the Plasma UI slider without displaying distracting OSD popups.
- **Sysfs Fallback**: Automatically falls back to `/sys/class/backlight/ktz8866-backlight` if KDE PowerDevil is absent.
- **Human Contrast-Calibrated Curves**: Log-space anchor curve calibrated specifically for the Xiaomi Pad 5 500-nit display across pitch-dark, dim, normal indoor, office, and outdoor sunlight environments.
- **Asymmetric Smoothing & Anti-Jitter**: Exponential Moving Average (EMA) filtering adapts promptly to brightening conditions ($\alpha = 0.22$), while dampening darkening changes ($\alpha = 0.08$) to prevent dips from brief hand occlusion over the sensor.
- **Continuous Slew Rate Transitions**: Uses a rate-limited smooth follower at 25 fps that glides gradually between light levels without stutter, abrupt stepping, or mid-transition hitching.
- **Intelligent User Preference Learning**: Moving the manual brightness slider adjusts personal bias offset (`user_bias`), maintaining your preferred offset as ambient light shifts.
- **Power Conscious**: Automatically pauses and releases sensor polling when the screen locks (`ScreenSaver`) or system suspends (`PrepareForSleep`).
- **Zero-Latency IPC**: Communicates through a fast Unix domain socket for CLI management and desktop applet toggling.

---

## Brightness Profiles

| Profile | Min % | Normal Indoor (50-80 lx) | Max % | Target Use Case |
| :--- | :---: | :---: | :---: | :--- |
| **`standard`** *(default)* | 8% | 45% – 55% | 100% | Ergonomic human-calibrated curve for comfortable everyday indoor & outdoor viewing |
| **`bright`** | 12% | 57% – 68% | 100% | Vibrant boost for brightly-lit rooms, sunny workspaces, and media playback |
| **`dim`** | 5% | 30% – 38% | 85% | Soft, low-glare curve for night reading and dark bedrooms |
| **`battery`** | 5% | 27% – 35% | 68% | Energy-efficient curve capped at 68% to maximize battery life |

---

## Installation

### From Repository
```bash
sudo pacman -S nabu-autobrightness
```

### Enable User Service
```bash
systemctl --user enable --now nabu-autobrightness.service
```

---

## CLI Usage

```bash
# View live status
nabu-autobrightness

# Toggle auto-brightness on / off
nabu-autobrightness --toggle

# Explicitly enable or disable
nabu-autobrightness --enable
nabu-autobrightness --disable

# Change active profile
nabu-autobrightness --profile bright
nabu-autobrightness --profile standard
nabu-autobrightness --profile dim
nabu-autobrightness --profile battery

# Adjust personal brightness offset
nabu-autobrightness --bias +10
nabu-autobrightness --bias -5
nabu-autobrightness --reset-bias

# Test / Monitor mode (diagnose sensor readings without altering brightness)
nabu-autobrightness --test
```

---

## Configuration

Settings are saved in `~/.config/nabu-autobrightness/config.json`:

```json
{
  "enabled": true,
  "profile": "standard",
  "user_bias": 0.0,
  "smooth_duration": 0.8,
  "deadband_pct": 1.5,
  "notify_on_toggle": true
}
```

---

## License

MIT License. Copyright (c) 2026 [Kumar-Jy](https://github.com/Kumar-Jy).
