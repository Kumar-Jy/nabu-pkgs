#!/usr/bin/env bash
set -euo pipefail

# Repackages Brave's official prebuilt aarch64 Linux release, following the
# official brave-bin recipe (see packages/brave-bin on the Arch branch).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

# The Debian revision (the -1 suffix) is ours; upstream Brave uses just the
# version number.
BRAVE_VER="${PKG_VER%-*}"
ZIP_NAME="brave-browser-${BRAVE_VER}-linux-arm64.zip"
ZIP_URL="https://github.com/brave/brave-browser/releases/download/v${BRAVE_VER}/${ZIP_NAME}"
ZIP_SHA256="1bdad41be7adc541fb82b5265ed1e8c3d4a36c964ea1ad9254f9f64305285473"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/$PKG_NAME"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/doc/$PKG_NAME"
mkdir -p "$PKG_DIR/etc/apparmor.d"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Downloading Brave ${BRAVE_VER} (arm64)..."
curl -fL --retry 3 --retry-delay 2 -sS "$ZIP_URL" -o "$WORK_DIR/$ZIP_NAME"

echo "==> Verifying SHA256..."
echo "${ZIP_SHA256}  ${ZIP_NAME}" | (cd "$WORK_DIR" && sha256sum -c -)

echo "==> Extracting to /opt/${PKG_NAME}..."
unzip -q "$WORK_DIR/$ZIP_NAME" -d "$PKG_DIR/opt/$PKG_NAME"

# Chromium's setuid sandbox helper must be root-owned and setuid.  dpkg
# preserves the mode bits from the staging tree, so mark it here.
chmod 4755 "$PKG_DIR/opt/$PKG_NAME/chrome-sandbox"

# Launcher script (reads ~/.config/brave-flags.conf, otherwise enables VA-API).
install -m 0755 "$SCRIPT_DIR/brave-bin.sh" "$PKG_DIR/usr/bin/brave"

# Desktop entry and icons.
install -m 0644 "$SCRIPT_DIR/brave-browser.desktop" "$PKG_DIR/usr/share/applications/brave-browser.desktop"
for size in 16 24 32 48 64 128 256; do
    mkdir -p "$PKG_DIR/usr/share/icons/hicolor/${size}x${size}/apps"
    install -m 0644 "$PKG_DIR/opt/$PKG_NAME/product_logo_${size}.png" \
        "$PKG_DIR/usr/share/icons/hicolor/${size}x${size}/apps/brave-desktop.png"
done

# Ubuntu restricts unprivileged user namespaces, so allow Brave's sandbox to
# create one.  The profile is Brave's own, with the path adjusted to the
# /opt/brave-bin layout used by this package.
install -m 0644 "$SCRIPT_DIR/brave-browser-stable.apparmor" \
    "$PKG_DIR/etc/apparmor.d/brave-browser-stable"

# License.
if [ -f "$PKG_DIR/opt/$PKG_NAME/LICENSE" ]; then
    install -m 0644 "$PKG_DIR/opt/$PKG_NAME/LICENSE" "$PKG_DIR/usr/share/doc/$PKG_NAME/copyright"
fi

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

echo "==> Built: $OUTPUT_DEB"
