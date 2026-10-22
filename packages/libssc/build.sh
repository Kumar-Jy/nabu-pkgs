#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu"
mkdir -p "$PKG_DIR/usr/include/libssc"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Fetching and building libssc v0.4.4..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
git clone --depth 1 --branch v0.4.4 https://codeberg.org/DylanVanAssche/libssc.git "$SRC_DIR"

cd "$SRC_DIR"
patch -p1 -i "$SCRIPT_DIR/0001-report-handler-lifecycle-fixes.patch"
sed -i 's/guint report_id;/gulong report_id;/' src/libssc-sensor.c

meson setup build --prefix=/usr --buildtype=release
ninja -C build

DESTDIR="$WORK_DIR/dest" ninja -C build install

cp -a "$WORK_DIR/dest/usr/bin/ssccli" "$PKG_DIR/usr/bin/"
cp -a "$WORK_DIR/dest/usr/lib/aarch64-linux-gnu"/libssc* "$PKG_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || cp -a "$WORK_DIR/dest/usr/lib"/libssc* "$PKG_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || true
cp -a "$WORK_DIR/dest/usr/include/libssc"/* "$PKG_DIR/usr/include/libssc/"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/libssc_0.4.4-1_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/libssc_0.4.4-1_arm64.deb"
