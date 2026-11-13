#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/apt-repo}"

mkdir -p "$OUTPUT_DIR"

build_pkg() {
    local pkg="$1"
    local pkg_name
    pkg_name=$(basename "$pkg")
    echo "--- Building: $pkg_name ---"
    if [ -f "$pkg/build.sh" ]; then
        chmod +x "$pkg/build.sh" 2>/dev/null || true
        bash "$pkg/build.sh" "$OUTPUT_DIR"
    elif [ -f "$pkg/DEBIAN/control" ]; then
        dpkg-deb --build --root-owner-group "$pkg" "$OUTPUT_DIR/"
    else
        return 0
    fi

    # Refuse to publish a .deb whose filename disagrees with DEBIAN/control.
    # This is how hexagonrpcd 0.4.0-2 ended up published as
    # hexagonrpcd_0.4.0-1_arm64.deb.
    local name ver arch deb deb_ver
    name=$(sed -n 's/^Package:[[:space:]]*//p' "$pkg/DEBIAN/control")
    ver=$(sed -n 's/^Version:[[:space:]]*//p' "$pkg/DEBIAN/control")
    arch=$(sed -n 's/^Architecture:[[:space:]]*//p' "$pkg/DEBIAN/control")
    deb="$OUTPUT_DIR/${name}_${ver}_${arch}.deb"
    if [ ! -f "$deb" ]; then
        echo "ERROR: $pkg_name did not produce $deb" >&2
        return 1
    fi
    deb_ver=$(dpkg-deb -f "$deb" Version)
    if [ "$deb_ver" != "$ver" ]; then
        echo "ERROR: $deb reports Version $deb_ver but control says $ver" >&2
        return 1
    fi
}

echo "==> Building all local deb packages from $ROOT_DIR/packages..."

# 1. libssc must be built first because iio-sensor-proxy links against it
if [ -d "$ROOT_DIR/packages/libssc" ]; then
    build_pkg "$ROOT_DIR/packages/libssc"
    echo "==> Installing libssc for downstream builds..."
    sudo dpkg -i "$OUTPUT_DIR"/libssc_*.deb 2>/dev/null || true
fi

# 2. hexagonrpcd and iio-sensor-proxy
if [ -d "$ROOT_DIR/packages/hexagonrpcd" ]; then
    build_pkg "$ROOT_DIR/packages/hexagonrpcd"
fi

if [ -d "$ROOT_DIR/packages/iio-sensor-proxy" ]; then
    build_pkg "$ROOT_DIR/packages/iio-sensor-proxy"
fi

# 3. All other packages
for pkg in "$ROOT_DIR/packages"/*; do
    if [ ! -d "$pkg" ]; then
        continue
    fi
    pkg_name=$(basename "$pkg")
    if [ "$pkg_name" = "libssc" ] || [ "$pkg_name" = "hexagonrpcd" ] || [ "$pkg_name" = "iio-sensor-proxy" ]; then
        continue
    fi
    build_pkg "$pkg"
done

echo "==> Built packages:"
ls -lh "$OUTPUT_DIR"/*.deb 2>/dev/null || echo "No .deb files found"
