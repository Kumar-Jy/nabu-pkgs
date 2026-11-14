#!/usr/bin/env bash
set -euo pipefail

# Republishes Google's official arm64 Chrome .deb verbatim.  The upstream
# package already ships correct maintainer scripts (icons, desktop database,
# AppArmor profile, update-alternatives, and the Google APT repository/signing
# key setup), so instead of rebuilding it we fetch the version-pinned build
# from Google's pool and publish it under the same name and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"

# Google keeps historical builds in a version-pinned pool path, which lets us
# pin a known-good release instead of chasing google-chrome-stable_current.
URL="https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${PKG_VER}_${PKG_ARCH}.deb"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> Downloading Google Chrome ${PKG_VER} (${PKG_ARCH})..."
curl -fL --retry 3 --retry-delay 2 -sS "$URL" -o "$WORK_DIR/google-chrome.deb"

# The pool path is version-pinned, but verify the payload so a mispublished
# file can never end up in the APT index under our version number.
deb_name=$(dpkg-deb -f "$WORK_DIR/google-chrome.deb" Package)
deb_ver=$(dpkg-deb -f "$WORK_DIR/google-chrome.deb" Version)
deb_arch=$(dpkg-deb -f "$WORK_DIR/google-chrome.deb" Architecture)
if [ "$deb_name" != "$PKG_NAME" ] || [ "$deb_ver" != "$PKG_VER" ] || [ "$deb_arch" != "$PKG_ARCH" ]; then
    echo "ERROR: downloaded ${deb_name} ${deb_ver} ${deb_arch}, expected ${PKG_NAME} ${PKG_VER} ${PKG_ARCH}" >&2
    exit 1
fi

install -m 0644 "$WORK_DIR/google-chrome.deb" "$OUTPUT_DEB"
echo "==> Built: $OUTPUT_DEB"
