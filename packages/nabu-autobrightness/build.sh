#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

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
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DEB"
