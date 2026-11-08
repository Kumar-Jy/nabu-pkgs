#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/scalable/apps"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

cp "$SCRIPT_DIR/system-monitor" "$PKG_DIR/usr/bin/system-monitor"
chmod 755 "$PKG_DIR/usr/bin/system-monitor"

cp "$SCRIPT_DIR/system-monitor.desktop" "$PKG_DIR/usr/share/applications/system-monitor.desktop"
cp "$SCRIPT_DIR/system-monitor.svg" "$PKG_DIR/usr/share/icons/hicolor/scalable/apps/system-monitor.svg"

VERSION=$(grep -i '^Version:' "$SCRIPT_DIR/DEBIAN/control" | awk '{print $2}')
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/system-monitor_${VERSION}_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/system-monitor_${VERSION}_all.deb"
