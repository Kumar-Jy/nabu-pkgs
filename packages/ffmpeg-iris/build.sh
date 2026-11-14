#!/usr/bin/env bash
set -euo pipefail

# IRIS-patched FFmpeg 8.0.1, packaged as a self-contained companion tree.
#
# Mirrors packages/ffmpeg-iris on the Arch branch: the prebuilt tree lives in a
# private directory (/usr/lib/iris-ffmpeg) and the companion commands
# (ffmpeg-iris / ffprobe-iris) point only their own process at it via
# LD_LIBRARY_PATH, so the system /usr/bin/ffmpeg is never shadowed.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
PKG_DIR="$WORK_DIR/pkg"

PKG_NAME=$(sed -n 's/^Package:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_VER=$(sed -n 's/^Version:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")
PKG_ARCH=$(sed -n 's/^Architecture:[[:space:]]*//p' "$SCRIPT_DIR/DEBIAN/control")

# Upstream FFmpeg version (control version without the Debian revision).
FFMPEG_VER="${PKG_VER%-*}"
ARCHIVE="ffmpeg-iris-${FFMPEG_VER}.7z"
ARCHIVE_SHA256="232c27c50a13c5eaa636b197d4c5333905b6c3eed16805841b109deab0da019b"
PATCH_FILE="ffmpeg-${FFMPEG_VER}-iris-v4l2-drmprime-p010.patch"
PATCH_SHA256="012b254bbb52c1442aa5478d2f7ca99f43c0d5a411c3500d24139959936674dd"

IMROOT="/usr/lib/iris-ffmpeg"

# The prebuilt tree is stored beside the build script (same convention as the
# Arch branch). 7z extraction needs p7zip; fall back to the newer 7zip name.
SEVENZ=""
for c in 7z 7zz 7za; do
    if command -v "$c" >/dev/null 2>&1; then SEVENZ="$c"; break; fi
done
if [ -z "$SEVENZ" ]; then
    echo "ERROR: no 7z extractor found (install p7zip-full)" >&2
    exit 1
fi

echo "==> Verifying source archive and patch..."
echo "${ARCHIVE_SHA256}  ${SCRIPT_DIR}/${ARCHIVE}" | sha256sum -c -
echo "${PATCH_SHA256}  ${SCRIPT_DIR}/${PATCH_FILE}" | sha256sum -c -

echo "==> Extracting ${ARCHIVE}..."
mkdir -p "$WORK_DIR/src"
"$SEVENZ" x -y -o"$WORK_DIR/src" "$SCRIPT_DIR/$ARCHIVE" >/dev/null

SRC="$WORK_DIR/src/ffmpeg-iris-${FFMPEG_VER}"
if [ ! -d "$SRC" ]; then
    echo "ERROR: expected extracted tree at $SRC" >&2
    exit 1
fi

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR$IMROOT"
mkdir -p "$PKG_DIR/usr/share/doc/$PKG_NAME"

cp "$SCRIPT_DIR/DEBIAN/control" "$PKG_DIR/DEBIAN/control"

echo "==> Installing private tree to $IMROOT..."
cp -a "$SRC/lib" "$PKG_DIR$IMROOT/"
cp -a "$SRC/bin" "$PKG_DIR$IMROOT/"
cp -a "$SRC/share" "$PKG_DIR$IMROOT/"

# Upstream ships the front-ends as patched_ffmpeg / patched_ffprobe. Provide the
# conventional names too so the wrappers (and users) can find them.
ln -sf patched_ffmpeg "$PKG_DIR$IMROOT/bin/ffmpeg"
ln -sf patched_ffprobe "$PKG_DIR$IMROOT/bin/ffprobe"

# LD-savvy companion bins: never /usr/bin/ffmpeg, the system one owns that.
for pair in "ffmpeg:ffmpeg-iris" "ffprobe:ffprobe-iris"; do
    bin="${pair%%:*}"; alias="${pair##*:}"
    cat > "$PKG_DIR/usr/bin/$alias" <<SRUN
#!/bin/sh
set -eu
export LD_LIBRARY_PATH="$IMROOT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "$IMROOT/bin/$bin" "\$@"
SRUN
    chmod 755 "$PKG_DIR/usr/bin/$alias"
done

install -m 0644 "$SCRIPT_DIR/$PATCH_FILE" \
    "$PKG_DIR/usr/share/doc/$PKG_NAME/iris-v4l2-drmprime-p010.patch"

OUTPUT_DIR="${1:-$SCRIPT_DIR}"
OUTPUT_DEB="$OUTPUT_DIR/${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb"
mkdir -p "$OUTPUT_DIR"
dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DEB"

echo "==> Built: $OUTPUT_DEB"
