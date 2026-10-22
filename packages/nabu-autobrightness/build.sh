#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/lib/systemd/user"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/lib/udev/rules.d"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

cp "$SCRIPT_DIR/nabu-autobrightness" "$PKG_DIR/usr/bin/nabu-autobrightness"
chmod 755 "$PKG_DIR/usr/bin/nabu-autobrightness"

cp "$SCRIPT_DIR/nabu-autobrightness.service" "$PKG_DIR/usr/lib/systemd/user/nabu-autobrightness.service"
cp "$SCRIPT_DIR/nabu-autobrightness-toggle.desktop" "$PKG_DIR/usr/share/applications/nabu-autobrightness-toggle.desktop"
cp "$SCRIPT_DIR/99-nabu-backlight.rules" "$PKG_DIR/lib/udev/rules.d/99-nabu-backlight.rules"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/nabu-autobrightness_1.0.0-1_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/nabu-autobrightness_1.0.0-1_all.deb"
