#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/apt-repo}"

mkdir -p "$OUTPUT_DIR"

echo "==> Building all local deb packages from $ROOT_DIR/packages..."

for pkg in "$ROOT_DIR/packages"/*; do
    if [ ! -d "$pkg" ]; then
        continue
    fi
    pkg_name=$(basename "$pkg")
    echo "--- Building: $pkg_name ---"
    if [ -f "$pkg/build.sh" ]; then
        chmod +x "$pkg/build.sh"
        "$pkg/build.sh" "$OUTPUT_DIR"
    elif [ -f "$pkg/DEBIAN/control" ]; then
        dpkg-deb --build --root-owner-group "$pkg" "$OUTPUT_DIR/"
    fi
done

echo "==> Built packages:"
ls -lh "$OUTPUT_DIR"/*.deb 2>/dev/null || echo "No .deb files found"
