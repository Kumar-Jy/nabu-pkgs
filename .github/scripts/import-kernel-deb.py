#!/usr/bin/env python3
"""
Import linux-nabu Ubuntu .deb packages from Kumar-Jy/linux releases or artifacts.
"""
import argparse
import io
import json
import os
import shutil
import sys
import urllib.request
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description="Import kernel .deb packages for nabu Ubuntu repo")
    parser.add_argument("--repo", default="Kumar-Jy/linux", help="GitHub repository (owner/repo)")
    parser.add_argument("--branch", default="nabu/7.3.y", help="Target kernel branch")
    parser.add_argument("--pkgver", default="", help="Optional version substring (e.g. 7.3.0)")
    parser.add_argument("--output-dir", required=True, help="Directory where .deb files should be saved")
    return parser.parse_args()

def get_headers():
    headers = {"User-Agent": "nabu-ubuntu-repo/1.0"}
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

def fetch_releases(repo):
    headers = get_headers()
    url = f"https://api.github.com/repos/{repo}/releases?per_page=20"
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        print(f"Error querying GitHub releases for {repo}: {e}", file=sys.stderr)
        return []

def main():
    args = parse_args()
    os.makedirs(args.output_dir, exist_ok=True)
    
    print(f"Querying releases from {args.repo}...")
    releases = fetch_releases(args.repo)
    if not releases:
        print("No releases found or API limit reached.", file=sys.stderr)
        return 1

    candidate_asset = None
    target_tag = ""
    for r in releases:
        tag = r.get("tag_name", "")
        if args.pkgver and args.pkgver not in tag:
            continue
        for a in r.get("assets", []):
            name = a.get("name", "")
            if "ubuntu" in name and name.endswith(".zip"):
                candidate_asset = a
                target_tag = tag
                break
        if candidate_asset:
            break

    if not candidate_asset:
        print(f"No ubuntu.zip kernel asset found in {args.repo} releases matching '{args.pkgver}'.")
        return 0

    download_url = candidate_asset.get("browser_download_url")
    asset_name = candidate_asset.get("name")
    print(f"Found candidate: {asset_name} from tag {target_tag}")
    print(f"Downloading from: {download_url}")

    headers = get_headers()
    req = urllib.request.Request(download_url, headers=headers)
    with urllib.request.urlopen(req) as resp:
        data = resp.read()

    with zipfile.ZipFile(io.BytesIO(data)) as zf:
        for member in zf.namelist():
            if member.endswith(".deb"):
                print(f"Extracting {member} -> {args.output_dir}")
                extracted_path = zf.extract(member, args.output_dir)
                # If nested in a subfolder, move it to output root
                if os.path.dirname(extracted_path) != os.path.abspath(args.output_dir):
                    dest = os.path.join(args.output_dir, os.path.basename(extracted_path))
                    shutil.move(extracted_path, dest)

    print("Kernel import completed successfully.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
