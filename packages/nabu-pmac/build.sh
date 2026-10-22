#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/lib/systemd/system"
mkdir -p "$PKG_DIR/etc/systemd/network"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"
if [ -f "$SCRIPT_DIR/DEBIAN/postinst" ]; then
    cp "$SCRIPT_DIR/DEBIAN/postinst" "$PKG_DIR/DEBIAN/postinst"
    chmod 755 "$PKG_DIR/DEBIAN/postinst"
fi

cp "$SCRIPT_DIR/nabu-pmac-set" "$PKG_DIR/usr/bin/nabu-pmac-set"
chmod 755 "$PKG_DIR/usr/bin/nabu-pmac-set"

cp "$SCRIPT_DIR/nabu-pmac.service" "$PKG_DIR/lib/systemd/system/nabu-pmac.service"
cp "$SCRIPT_DIR/10-wlan.link" "$PKG_DIR/etc/systemd/network/10-wlan.link"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/nabu-pmac_1.0-1_all.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/nabu-pmac_1.0-1_all.deb"
