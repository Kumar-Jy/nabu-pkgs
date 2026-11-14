#!/usr/bin/env bash
set -euo pipefail

# Installs the mpv-iris launcher (see packages/mpv-iris/mpv-iris).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/doc/$PKG_NAME"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"
install -m 0755 "$SCRIPT_DIR/mpv-iris" "$PKG_DIR/usr/bin/mpv-iris"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

echo "==> Built: $OUTPUT_DEB"
