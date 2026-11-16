# Nabu Backup & Restore

Comprehensive system and user data backup, migration, and restore utility designed for the **Xiaomi Pad 5 (nabu)** running Arch Linux ARM across **KDE Plasma** and **GNOME**.

## Key Highlights

- **Desktop-Agnostic Adaptive GUI**: Built with GTK4 and Libadwaita. Runs natively under Wayland and X11 in both KDE Plasma and GNOME, adapting seamlessly to system dark and light modes.
- **Dynamic Storage Detection**:
  - Automatically identifies all reliable internal partitions (`ntfs`, `vfat`, `exfat`, `ext4`, `btrfs`, `f2fs`) such as Windows (`WINNABU`) and Android data (`Data`).
  - Auto-detects external USB drives (USB OTG, USB-C flash drives, portable SSDs, SD card readers).
  - On-demand partition mounting via `udisks2` without requiring root password.
  - Low disk space warnings (< 4 GB) and user prompt when no suitable storage is connected.
- **Cloud Storage Integration**:
  - Direct backup and restore to remote cloud storage powered by `rclone`.
  - Native setup and support for **MEGA**, **Google Drive**, **OneDrive**, **Dropbox**, **Nextcloud**, and **WebDAV**.
  - Encrypted credential handling (`rclone obscure`).
  - Progress feedback during cloud uploads and downloads.
- **Non-Conflicting Fresh System Restore**:
  - Package synchronization using `pacman -S --needed`, safely skipping pre-installed packages on fresh installs without overwriting or causing conflicts.
  - Automatic user file permission normalization (`chown -R $USER:$USER`).
  - NetworkManager WiFi profiles restored with strict permissions (`chmod 600`) and automatic connection reload.
  - Bluetooth device pairings restored (`/var/lib/bluetooth`) with service reload.
  - Preserves tablet-specific boot arguments (`/etc/cmdline.d/`).
- **High-Performance Compression**: Multi-threaded `zstd` compression (`tar -I 'zstd -3 -T0'`) optimized for the Qualcomm Snapdragon 860.
- **Dual Mode**: Full GUI interface and comprehensive CLI mode (`nabu-backup --cli`, `nabu-backup backup`, `nabu-backup restore`).

## Usage

### Graphical Mode
Launch from application menu (Kickoff / App Grid) or run:
```bash
nabu-backup
```

### Command Line Mode
```bash
# Interactive terminal menu
nabu-backup --cli

# List detected internal and external drives
nabu-backup --list-drives

# List configured cloud remotes and existing cloud backups
nabu-backup --list-cloud

# Perform automated backup to a specified directory or mounted drive
nabu-backup backup --dest /run/media/root/WINNABU/NabuBackups

# Perform automated cloud backup to a configured remote (e.g. Google Drive or MEGA)
nabu-backup backup --dest mymega --cloud

# Restore from an archive
nabu-backup restore /path/to/nabu-backup-YYYY-MM-DD-HHMM.tar.zst
```
