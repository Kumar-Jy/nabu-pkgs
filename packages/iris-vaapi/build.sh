#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/pkg"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri"
mkdir -p "$PKG_DIR/usr/lib/dri"
mkdir -p "$PKG_DIR/etc/environment.d"
mkdir -p "$PKG_DIR/etc/profile.d"
mkdir -p "$PKG_DIR/etc/modprobe.d"
mkdir -p "$PKG_DIR/lib/udev/rules.d"
mkdir -p "$PKG_DIR/etc/firefox/policies"
mkdir -p "$PKG_DIR/usr/lib/firefox/defaults/pref"
mkdir -p "$PKG_DIR/usr/local/share/applications"
mkdir -p "$PKG_DIR/usr/local/bin"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"
if [ -f "$SCRIPT_DIR/DEBIAN/postinst" ]; then
    cp "$SCRIPT_DIR/DEBIAN/postinst" "$PKG_DIR/DEBIAN/postinst"
    chmod 755 "$PKG_DIR/DEBIAN/postinst"
fi

echo "==> Fetching and building Qualcomm SM8150 Iris VA-API driver..."
SRC_DIR="$WORK_DIR/src"
mkdir -p "$SRC_DIR"

_iris_pin="b0ef8f7512321d36d52e4a1a52fd3eb0eec9a107"
curl -sSL "https://github.com/CFM880/iris-vaapi/archive/${_iris_pin}.tar.gz" | tar -xz -C "$SRC_DIR" --strip-components=1

cd "$SRC_DIR"
if [ -f "$SCRIPT_DIR/0001-vaapi-support-vaAcquireBufferHandle-and-default-expo.patch" ]; then
    patch -p1 -i "$SCRIPT_DIR/0001-vaapi-support-vaAcquireBufferHandle-and-default-expo.patch"
fi

make CC=gcc DRIVERDIR=/usr/lib/aarch64-linux-gnu/dri

cp build/vpu_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so"
chmod 755 "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so"

# Provide multiarch driver symlinks for legacy iris and msm driver discovery
ln -s vpu_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/iris_drv_video.so"
ln -s vpu_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/msm_drm_drv_video.so"
ln -s vpu_drv_video.so "$PKG_DIR/usr/lib/aarch64-linux-gnu/dri/msm_drv_video.so"

# Standard /usr/lib/dri symlinks
ln -s /usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so "$PKG_DIR/usr/lib/dri/vpu_drv_video.so"
ln -s /usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so "$PKG_DIR/usr/lib/dri/iris_drv_video.so"
ln -s /usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so "$PKG_DIR/usr/lib/dri/msm_drm_drv_video.so"
ln -s /usr/lib/aarch64-linux-gnu/dri/vpu_drv_video.so "$PKG_DIR/usr/lib/dri/msm_drv_video.so"

# Modprobe and udev rules
cp "$SCRIPT_DIR/99-iris-vaapi.conf" "$PKG_DIR/etc/modprobe.d/99-iris-vaapi.conf"
cp "$SCRIPT_DIR/99-iris-dmaheap.rules" "$PKG_DIR/lib/udev/rules.d/99-iris-dmaheap.rules"

# Global environment variables
cp "$SCRIPT_DIR/99-iris.conf" "$PKG_DIR/etc/environment.d/99-iris.conf"
cp "$SCRIPT_DIR/99-iris.sh" "$PKG_DIR/etc/profile.d/99-iris.sh"
chmod 644 "$PKG_DIR/etc/profile.d/99-iris.sh"

# Firefox hardware acceleration configuration
cp "$SCRIPT_DIR/iris-vaapi.js" "$PKG_DIR/etc/firefox/syspref.js"
cp "$SCRIPT_DIR/iris-vaapi.js" "$PKG_DIR/usr/lib/firefox/defaults/pref/iris-vaapi.js"
cp "$SCRIPT_DIR/policies.json" "$PKG_DIR/etc/firefox/policies/policies.json"

# Chrome & Brave desktop launchers
cp "$SCRIPT_DIR/google-chrome.desktop" "$PKG_DIR/usr/local/share/applications/google-chrome.desktop"
cp "$SCRIPT_DIR/google-chrome.desktop" "$PKG_DIR/usr/local/share/applications/com.google.Chrome.desktop"
cp "$SCRIPT_DIR/brave-browser.desktop" "$PKG_DIR/usr/local/share/applications/brave-browser.desktop"

# CLI wrappers
cp "$SCRIPT_DIR/google-chrome-wrapper" "$PKG_DIR/usr/local/bin/google-chrome-stable"
chmod 755 "$PKG_DIR/usr/local/bin/google-chrome-stable"
ln -s google-chrome-stable "$PKG_DIR/usr/local/bin/google-chrome"

cp "$SCRIPT_DIR/brave-wrapper" "$PKG_DIR/usr/local/bin/brave-browser"
chmod 755 "$PKG_DIR/usr/local/bin/brave-browser"
ln -s brave-browser "$PKG_DIR/usr/local/bin/brave"

VERSION=$(grep -i '^Version:' "$SCRIPT_DIR/DEBIAN/control" | awk '{print $2}')
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/iris-vaapi_${VERSION}_arm64.deb"

rm -rf "$WORK_DIR"
echo "==> Built: $OUTPUT_DIR/iris-vaapi_${VERSION}_arm64.deb"
