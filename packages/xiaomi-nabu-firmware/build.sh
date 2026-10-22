#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/lib"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Downloading Xiaomi Pad 5 firmware archive..."
FW_URL="https://github.com/rodriguezst/arch-repo/releases/download/aarch64/linux-firmware-xiaomi-nabu-25.04.26-1-any.pkg.tar.xz"
curl -fL "$FW_URL" -o "$WORK_DIR/fw.pkg.tar.xz"

echo "==> Extracting firmware..."
tar -xf "$WORK_DIR/fw.pkg.tar.xz" -C "$WORK_DIR"
if [ -d "$WORK_DIR/usr/lib/firmware" ]; then
    cp -r "$WORK_DIR/usr/lib/firmware" "$PKG_DIR/usr/lib/"
elif [ -d "$WORK_DIR/lib/firmware" ]; then
    cp -r "$WORK_DIR/lib/firmware" "$PKG_DIR/usr/lib/"
fi

# Build .deb
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/xiaomi-nabu-firmware_1.2-1_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/xiaomi-nabu-firmware_1.2-1_all.deb"
