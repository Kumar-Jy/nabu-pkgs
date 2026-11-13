#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
UPSTREAM_VER="${PKG_VER%-*}"

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

echo "==> Fetching and building hexagonrpc v${UPSTREAM_VER}..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
curl -fL "https://github.com/linux-msm/hexagonrpc/archive/refs/tags/v${UPSTREAM_VER}.tar.gz" | tar -xz -C "$SRC_DIR" --strip-components=1

cd "$SRC_DIR"
meson setup build --prefix=/usr --buildtype=release
meson compile -C build

DESTDIR="$WORK_DIR/dest" meson install -C build

# Install daemon to libexec and wrapper to /usr/bin
cp "$WORK_DIR/dest/usr/bin/hexagonrpcd" "$PKG_DIR/usr/libexec/hexagonrpc/hexagonrpcd"
install -Dm755 "$SCRIPT_DIR/hexagonrpcd-wrapper" "$PKG_DIR/usr/bin/hexagonrpcd"

# Shared library (runtime SONAME only). The unversioned libhexagonrpc.so
# symlink is a -dev artifact and would clash with Ubuntu's libhexagonrpc-dev.
mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu"
LIB_DIR="$WORK_DIR/dest/usr/lib/aarch64-linux-gnu"
[ -d "$LIB_DIR" ] || LIB_DIR="$WORK_DIR/dest/usr/lib"
runtime_libs=("$LIB_DIR"/libhexagonrpc.so.*)
if [ -e "${runtime_libs[0]}" ]; then
    cp -a "${runtime_libs[@]}" "$PKG_DIR/usr/lib/aarch64-linux-gnu/"
else
    echo "ERROR: libhexagonrpc runtime library not found in $LIB_DIR" >&2
    exit 1
fi

# Services & udev
install -Dm644 "$SCRIPT_DIR/hexagonrpcd.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd.service"
install -Dm644 "$SCRIPT_DIR/hexagonrpcd-suspend.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd-suspend.service"
install -Dm644 "$SCRIPT_DIR/hexagonrpcd-resume.service" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd-resume.service"
install -Dm644 "$SCRIPT_DIR/nabu-slpi-hexagonrpcd.conf" "$PKG_DIR/usr/lib/systemd/system/hexagonrpcd.service.d/nabu-slpi.conf"
install -Dm644 "$SCRIPT_DIR/60-hexagonrpcd.rules" "$PKG_DIR/usr/lib/udev/rules.d/60-hexagonrpcd.rules"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DEB"
