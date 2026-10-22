#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/libexec/hexagonrpc"
mkdir -p "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd.service.d"
mkdir -p "$PKG_DIR/usr/lib/udev/rules.d"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"
cp "$SCRIPT_DIR/DEBIAN/postinst" "$PKG_DIR/DEBIAN/postinst"
chmod 755 "$PKG_DIR/DEBIAN/postinst"
cp "$SCRIPT_DIR/DEBIAN/prerm" "$PKG_DIR/DEBIAN/prerm"
chmod 755 "$PKG_DIR/DEBIAN/prerm"

echo "==> Fetching and building hexagonrpc v0.4.0..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
curl -fL "https://github.com/linux-msm/hexagonrpc/archive/refs/tags/v0.4.0.tar.gz" | tar -xz -C "$SRC_DIR" --strip-components=1

cd "$SRC_DIR"
meson setup build --prefix=/usr --buildtype=release
meson compile -C build

DESTDIR="$WORK_DIR/dest" meson install -C build

# Install daemon to libexec and wrapper to /usr/bin
cp "$WORK_DIR/dest/usr/bin/hexagonrpcd" "$PKG_DIR/usr/libexec/hexagonrpc/hexagonrpcd"
install -Dm755 "$SCRIPT_DIR/hexagonrpcd-wrapper" "$PKG_DIR/usr/bin/hexagonrpcd"

# Shared library
if [ -d "$WORK_DIR/dest/usr/lib/aarch64-linux-gnu" ]; then
    mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu"
    cp -a "$WORK_DIR/dest/usr/lib/aarch64-linux-gnu"/libhexagonrpc* "$PKG_DIR/usr/lib/aarch64-linux-gnu/"
elif [ -d "$WORK_DIR/dest/usr/lib" ]; then
    mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu"
    cp -a "$WORK_DIR/dest/usr/lib"/libhexagonrpc* "$PKG_DIR/usr/lib/aarch64-linux-gnu/" 2>/dev/null || true
fi

# Services & udev
install -Dm644 "$SCRIPT_DIR/hexagonrpcd.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd.service"
install -Dm644 "$SCRIPT_DIR/hexagonrpcd-suspend.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd-suspend.service"
install -Dm644 "$SCRIPT_DIR/hexagonrpcd-resume.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd-resume.service"
install -Dm644 "$SCRIPT_DIR/nabu-slpi-hexagonrpcd.conf" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd.service.d/nabu-slpi.conf"
install -Dm644 "$SCRIPT_DIR/60-hexagonrpcd.rules" "$PKG_DIR/usr/lib/udev/rules.d/60-hexagonrpcd.rules"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/hexagonrpcd_0.4.0-1_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/hexagonrpcd_0.4.0-1_arm64.deb"
