#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/lib"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Downloading Xiaomi Pad 5 firmware archive..."
# Pin both the upstream archive and its SHA-256. The old code accepted any
# asset matching a wildcard (and silently fell through to an unverified URL),
# so a changed or truncated download would have been packaged unnoticed.
FW_VERSION="25.04.26-1"
FW_SHA256="bef43c32029902bc4c3c1b7c7007c6e5d954fe673933087a836b5a41b567bac9"
FW_URL="https://github.com/rodriguezst/arch-repo/releases/download/aarch64/linux-firmware-xiaomi-nabu-${FW_VERSION}-any.pkg.tar.xz"
curl -fSL --retry 3 --retry-delay 5 "$FW_URL" -o "$WORK_DIR/fw.pkg.tar.xz"
echo "$FW_SHA256  $WORK_DIR/fw.pkg.tar.xz" | sha256sum -c -

echo "==> Extracting firmware..."
tar -xf "$WORK_DIR/fw.pkg.tar.xz" -C "$WORK_DIR"
if [ -d "$WORK_DIR/usr/lib/firmware" ]; then
    cp -r "$WORK_DIR/usr/lib/firmware" "$PKG_DIR/usr/lib/"
elif [ -d "$WORK_DIR/lib/firmware" ]; then
    cp -r "$WORK_DIR/lib/firmware" "$PKG_DIR/usr/lib/"
fi

# Build .deb
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DEB"
