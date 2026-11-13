#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

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
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DEB"
