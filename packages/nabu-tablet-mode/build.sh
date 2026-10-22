#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/local/libexec"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/etc"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/lib/systemd/system"
mkdir -p "$PKG_DIR/lib/systemd/system-sleep"
mkdir -p "$PKG_DIR/usr/libexec"
mkdir -p "$PKG_DIR/lib/udev/rules.d"
mkdir -p "$PKG_DIR/lib/systemd/system/iio-sensor-proxy.service.d"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"
if [ -f "$SCRIPT_DIR/DEBIAN/postinst" ]; then
    cp "$SCRIPT_DIR/DEBIAN/postinst" "$PKG_DIR/DEBIAN/postinst"
    chmod 755 "$PKG_DIR/DEBIAN/postinst"
fi

echo "==> Compiling nabu-tablet-mode binary..."
gcc -O2 -Wall -Wextra "$SCRIPT_DIR/nabu-tablet-mode.c" -o "$PKG_DIR/usr/local/libexec/nabu-tablet-mode"
chmod 755 "$PKG_DIR/usr/local/libexec/nabu-tablet-mode"

cp "$SCRIPT_DIR/nabu-tablet-toggle" "$PKG_DIR/usr/bin/nabu-tablet-toggle"
chmod 755 "$PKG_DIR/usr/bin/nabu-tablet-toggle"

cp "$SCRIPT_DIR/nabu-tablet-mode.conf" "$PKG_DIR/etc/nabu-tablet-mode.conf"
cp "$SCRIPT_DIR/nabu-tablet-toggle.desktop" "$PKG_DIR/usr/share/applications/nabu-tablet-toggle.desktop"
cp "$SCRIPT_DIR/nabu-tablet-mode.service" "$PKG_DIR/lib/systemd/system/nabu-tablet-mode.service"

cp "$SCRIPT_DIR/nabu-sensors-resume.sh" "$PKG_DIR/lib/systemd/system-sleep/nabu-sensors-resume.sh"
chmod 755 "$PKG_DIR/lib/systemd/system-sleep/nabu-sensors-resume.sh"

cp "$SCRIPT_DIR/nabu-sensors-recover" "$PKG_DIR/usr/libexec/nabu-sensors-recover"
chmod 755 "$PKG_DIR/usr/libexec/nabu-sensors-recover"

cp "$SCRIPT_DIR/90-nabu-ssc-accelerometer.rules" "$PKG_DIR/lib/udev/rules.d/90-nabu-ssc-accelerometer.rules"
cp "$SCRIPT_DIR/nabu-ssc.conf" "$PKG_DIR/lib/systemd/system/iio-sensor-proxy.service.d/nabu-ssc.conf"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/nabu-tablet-mode_1.0.0-1_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/nabu-tablet-mode_1.0.0-1_arm64.deb"
