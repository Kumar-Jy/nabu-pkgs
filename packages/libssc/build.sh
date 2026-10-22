#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Fetching and building libssc v0.4.4..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
git clone --depth 1 --branch v0.4.4 https://codeberg.org/DylanVanAssche/libssc.git "$SRC_DIR"

cd "$SRC_DIR"
sed -i "/subdir('mocking')/d; /subdir('tests')/d" meson.build
sed -i "s/>= 1.4.0/>= 1.3.0/" meson.build
patch -p1 -i "$SCRIPT_DIR/0001-report-handler-lifecycle-fixes.patch"
sed -i 's/guint report_id;/gulong report_id;/' src/libssc-sensor.c

meson setup build --prefix=/usr --buildtype=release
ninja -C build

DESTDIR="$PKG_DIR" ninja -C build install

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/libssc_0.4.4-1_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/libssc_0.4.4-1_arm64.deb"
