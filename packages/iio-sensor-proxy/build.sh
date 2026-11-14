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

echo "==> Fetching and building iio-sensor-proxy 3.9 with SSC support..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"
git clone --depth 1 --branch 3.9 https://gitlab.freedesktop.org/hadess/iio-sensor-proxy.git "$SRC_DIR"

# A tag can be moved upstream. Pin the commit this package was tested against
# so a retagged release cannot silently change the contents of the .deb.
EXPECTED_COMMIT="0085ddf8ecb173a1c5fcf2344aa40e561125354f"
ACTUAL_COMMIT=$(git -C "$SRC_DIR" rev-parse HEAD)
if [ "$ACTUAL_COMMIT" != "$EXPECTED_COMMIT" ]; then
    echo "ERROR: iio-sensor-proxy tag 3.9 now points to $ACTUAL_COMMIT (expected $EXPECTED_COMMIT)" >&2
    exit 1
fi

cd "$SRC_DIR"
patch -Np1 -i "$SCRIPT_DIR/0001-fix-ssc-race-condition.patch"
patch -Np1 -i "$SCRIPT_DIR/0002-ssc-proximity-nabu-sar-fallback.patch"

meson setup build \
    --prefix=/usr \
    --buildtype=release \
    -Dsystemdsystemunitdir=/usr/lib/systemd/system \
    -Dudevrulesdir=/usr/lib/udev/rules.d \
    -Dssc-support=enabled \
    -Dgtk_doc=false \
    -Dgtk-tests=false \
    -Dtests=false

ninja -C build

DESTDIR="$PKG_DIR" ninja -C build install

# Keep the packaged rule aligned with the Arch package: both DSPs expose
# light/compass/proximity, and the accelerometer is opt-in on SDSP only via
# nabu-tablet-mode's 90 rule. Tagging ADSP as an accelerometer adds a second
# sensor with no mount matrix, which rotates GNOME 180 degrees.
RULES="$PKG_DIR/usr/lib/udev/rules.d/80-iio-sensor-proxy.rules"
if grep -q 'fastrpc-adsp.*ssc-accel' "$RULES"; then
    echo "ERROR: ADSP must not be tagged as an accelerometer" >&2
    exit 1
fi
if ! grep -q 'fastrpc-sdsp.*ssc-light.*ssc-compass.*ssc-proximity' "$RULES"; then
    echo "ERROR: unexpected SDSP sensor tagging in 80-iio-sensor-proxy.rules" >&2
    exit 1
fi

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DEB"
