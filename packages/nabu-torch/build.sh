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

cp "$SCRIPT_DIR/torch" "$PKG_DIR/usr/bin/torch"
chmod 755 "$PKG_DIR/usr/bin/torch"
ln -sf torch "$PKG_DIR/usr/bin/nabu-torch"
ln -sf torch "$PKG_DIR/usr/bin/flashlight"

cp "$SCRIPT_DIR/torch.desktop" "$PKG_DIR/usr/share/applications/torch.desktop"
cp "$SCRIPT_DIR/torch.svg" "$PKG_DIR/usr/share/icons/hicolor/scalable/apps/torch.svg"
cp "$SCRIPT_DIR/torch.svg" "$PKG_DIR/usr/share/pixmaps/torch.svg"
cp "$SCRIPT_DIR/90-torch.rules" "$PKG_DIR/lib/udev/rules.d/90-torch.rules"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/nabu-torch_1.0.0-1_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/nabu-torch_1.0.0-1_all.deb"
