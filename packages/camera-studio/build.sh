#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/scalable/apps"
mkdir -p "$PKG_DIR/usr/share/pixmaps"
mkdir -p "$PKG_DIR/lib/udev/rules.d"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

cp "$SCRIPT_DIR/camera-studio" "$PKG_DIR/usr/bin/camera-studio"
chmod 755 "$PKG_DIR/usr/bin/camera-studio"

ln -sf camera-studio "$PKG_DIR/usr/bin/pro-camera"
ln -sf camera-studio "$PKG_DIR/usr/bin/cam-studio"

cp "$SCRIPT_DIR/camera-studio.desktop" "$PKG_DIR/usr/share/applications/camera-studio.desktop"
cp "$SCRIPT_DIR/camera-studio.svg" "$PKG_DIR/usr/share/icons/hicolor/scalable/apps/camera-studio.svg"
cp "$SCRIPT_DIR/camera-studio.svg" "$PKG_DIR/usr/share/pixmaps/camera-studio.svg"

cp "$SCRIPT_DIR/90-camera-flash.rules" "$PKG_DIR/lib/udev/rules.d/90-camera-flash.rules"

VERSION=$(grep -i '^Version:' "$SCRIPT_DIR/DEBIAN/control" | awk '{print $2}')
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/camera-studio_${VERSION}_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/camera-studio_${VERSION}_all.deb"
