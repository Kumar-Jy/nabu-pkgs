#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Fetching and building iio-sensor-proxy 3.9 with SSC support..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
git clone --depth 1 --branch 3.9 https://gitlab.freedesktop.org/hadess/iio-sensor-proxy.git "$SRC_DIR"

cd "$SRC_DIR"
patch -Np1 -i "$SCRIPT_DIR/0001-fix-ssc-race-condition.patch"
patch -Np1 -i "$SCRIPT_DIR/0002-ssc-proximity-nabu-sar-fallback.patch"

meson setup build \
    --prefix=/usr \
    --buildtype=release \
    -Dsystemdsystemunitdir=/usr/lib/systemd/system \
    -Dudevrulesdir=/usr/lib/udev/rules.d \
    -Dssc-support=enabled \
    -Dgtk_doc=false

ninja -C build

DESTDIR="$PKG_DIR" ninja -C build install

# Ensure ssc-accel is included in the udev rule
if [ -f "$PKG_DIR/usr/lib/udev/rules.d/80-iio-sensor-proxy.rules" ]; then
    sed -i 's/ssc-light/ssc-accel ssc-light/g' "$PKG_DIR/usr/lib/udev/rules.d/80-iio-sensor-proxy.rules"
fi

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/iio-sensor-proxy_3.9-1nabu1_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/iio-sensor-proxy_3.9-1nabu1_arm64.deb"
