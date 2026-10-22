#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-./apt-repo}"

if [ ! -d "$REPO_DIR" ]; then
    echo "Directory $REPO_DIR does not exist." >&2
    exit 1
fi

cd "$REPO_DIR"

echo "==> Scanning packages in $REPO_DIR..."
# dpkg-scanpackages requires dpkg-dev
if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
    echo "dpkg-scanpackages not found, installing dpkg-dev..."
    sudo apt-get update && sudo apt-get install -y dpkg-dev apt-utils
fi

# Generate Packages file
dpkg-scanpackages -m . /dev/null > Packages
gzip -9c Packages > Packages.gz

echo "==> Generating Release file..."
cat > Release << EOF
Origin: Kumar-Jy
Label: nabu-ubuntu
Suite: resolute
Codename: resolute
Architectures: arm64 all
Components: main
Description: Xiaomi Pad 5 (nabu) Ubuntu APT Repository
Date: $(date -Ru)
EOF

# Append hashes to Release file
echo "MD5Sum:" >> Release
for f in Packages Packages.gz; do
    if [ -f "$f" ]; then
        echo " $(md5sum "$f" | awk '{print $1}') $(stat -c %s "$f") $f" >> Release
    fi
done

echo "SHA256:" >> Release
for f in Packages Packages.gz; do
    if [ -f "$f" ]; then
        echo " $(sha256sum "$f" | awk '{print $1}') $(stat -c %s "$f") $f" >> Release
    fi
done

echo "==> APT repository metadata created successfully!"
ls -lh Packages Packages.gz Release
