#!/usr/bin/env python3
"""
Import linux-nabu Ubuntu .deb packages dynamically from Kumar-Jy/linux releases or CI artifacts.
"""
import argparse
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description="Import kernel .deb packages for nabu Ubuntu repo")
    parser.add_argument("--repo", default="Kumar-Jy/linux", help="GitHub repository (owner/repo)")
    parser.add_argument("--branch", default="", help="Optional kernel branch for CI runs (e.g. nabu/7.3.y)")
    parser.add_argument("--pkgver", default="latest", help="Version substring or 'latest' (default: latest)")
    parser.add_argument("--output-dir", required=True, help="Directory where .deb files should be saved")
    return parser.parse_args()

def get_headers():
    headers = {"User-Agent": "nabu-ubuntu-repo/2.0"}
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

def parse_iso_time(ts_str):
    try:
        return datetime.datetime.fromisoformat(ts_str.replace("Z", "+00:00")).timestamp()
    except Exception:
        return 0.0

def find_candidate(repo, branch, pkgver):
    headers = get_headers()
    is_latest = not pkgver or pkgver.lower() == "latest"

    # 1. Query GitHub Releases
    release_cand = None
    try:
        url = f"https://api.github.com/repos/{repo}/releases?per_page=30"
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            releases = json.loads(resp.read().decode())

        for r in releases:
            if r.get("draft"):
                continue
            tag = r.get("tag_name", "")
            if not is_latest and pkgver not in tag:
                continue

            for a in r.get("assets", []):
                name = a.get("name", "")
                if "ubuntu" in name and name.endswith(".zip"):
                    release_cand = {
                        "type": "release",
                        "tag": tag,
                        "timestamp": parse_iso_time(r.get("published_at", "")),
                        "date_str": r.get("published_at", ""),
                        "download_url": a.get("browser_download_url"),
                        "asset_name": name,
                    }
                    break

            if release_cand:
                break
    except Exception as e:
        print(f"Notice: Releases search returned: {e}", file=sys.stderr)

    # 2. Query GitHub Actions Artifacts
    artifact_cand = None
    try:
        runs_url = f"https://api.github.com/repos/{repo}/actions/runs?status=success&per_page=20"
        if branch:
            runs_url += f"&branch={urllib.parse.quote(branch, safe='')}"
        req = urllib.request.Request(runs_url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            runs = json.loads(resp.read().decode()).get("workflow_runs", [])

        for run in runs:
            art_url = run.get("artifacts_url")
            if not art_url:
                continue
            art_req = urllib.request.Request(art_url, headers=headers)
            with urllib.request.urlopen(art_req) as resp2:
                arts = json.loads(resp2.read().decode()).get("artifacts", [])

            for a in arts:
                aname = a.get("name", "")
                if "ubuntu" in aname and (is_latest or pkgver in aname):
                    artifact_cand = {
                        "type": "artifact",
                        "run_id": run.get("id"),
                        "artifact_id": a.get("id"),
                        "artifact_name": aname,
                        "timestamp": parse_iso_time(run.get("created_at", "")),
                        "date_str": run.get("created_at", ""),
                        "download_url": a.get("archive_download_url"),
                    }
                    break
            if artifact_cand:
                break
    except Exception as e:
        print(f"Notice: Actions runs search returned: {e}", file=sys.stderr)

    # 3. Choose candidate (prefer newer timestamp)
    if release_cand and artifact_cand:
        if release_cand["timestamp"] >= artifact_cand["timestamp"]:
            print(f"Picked Release candidate: {release_cand['asset_name']} ({release_cand['tag']}, date: {release_cand['date_str']})")
            return release_cand
        else:
            print(f"Picked Action Artifact candidate: {artifact_cand['artifact_name']} (run: {artifact_cand['run_id']}, date: {artifact_cand['date_str']})")
            return artifact_cand
    elif release_cand:
        print(f"Picked Release candidate: {release_cand['asset_name']} ({release_cand['tag']}, date: {release_cand['date_str']})")
        return release_cand
    elif artifact_cand:
        print(f"Picked Action Artifact candidate: {artifact_cand['artifact_name']} (run: {artifact_cand['run_id']}, date: {artifact_cand['date_str']})")
        return artifact_cand
    else:
        print(f"ERROR: No release or CI artifact found for version '{pkgver}' in {repo}", file=sys.stderr)
        return None

def download_candidate(cand, dest_zip):
    download_url = cand.get("download_url")
    print(f"Downloading from: {download_url}")

    if cand["type"] == "release":
        # Release assets: use curl without auth header to avoid S3/Azure redirect authentication errors
        res = subprocess.run(["curl", "-fSL", "-o", dest_zip, download_url], capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(dest_zip) and os.path.getsize(dest_zip) > 0:
            print(f"Downloaded {os.path.getsize(dest_zip)} bytes via curl.")
            return True

        print("curl failed or unavailable, falling back to urllib streaming...")
        req = urllib.request.Request(download_url, headers={"User-Agent": "nabu-ubuntu-repo/2.0"})
        with urllib.request.urlopen(req) as resp, open(dest_zip, "wb") as out:
            shutil.copyfileobj(resp, out)
        return True

    # Artifact candidate: requires GitHub Token
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        try:
            req = urllib.request.Request(download_url, headers={"Authorization": f"Bearer {token}", "User-Agent": "nabu-ubuntu-repo/2.0"})
            with urllib.request.urlopen(req) as resp, open(dest_zip, "wb") as out:
                shutil.copyfileobj(resp, out)
            return True
        except Exception as e:
            print(f"urllib artifact download failed: {e}")

    # Fallback: gh CLI
    try:
        run_id = str(cand["run_id"])
        art_name = cand["artifact_name"]
        tmp_dir = os.path.dirname(dest_zip)
        cmd = ["gh", "run", "download", run_id, "--name", art_name, "--dir", tmp_dir]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            # gh downloads the artifact either as files or as a zip
            for f in os.listdir(tmp_dir):
                if f.endswith(".zip"):
                    shutil.move(os.path.join(tmp_dir, f), dest_zip)
                    return True
    except Exception as e:
        print(f"gh CLI download failed: {e}")

    return False

def main():
    args = parse_args()
    os.makedirs(args.output_dir, exist_ok=True)

    print(f"=== Discovering latest available kernel ({args.pkgver}) in {args.repo} ===")
    cand = find_candidate(args.repo, args.branch, args.pkgver)
    if not cand:
        print(f"No kernel candidate found for {args.pkgver}")
        return 1

    with tempfile.TemporaryDirectory(prefix="nabu-deb-") as tmp_dir:
        dest_zip = os.path.join(tmp_dir, "kernel-ubuntu.zip")
        if not download_candidate(cand, dest_zip):
            print("ERROR: Failed to download candidate archive", file=sys.stderr)
            return 1

        print("Extracting kernel Debian packages...")
        extracted_debs = []
        with zipfile.ZipFile(dest_zip) as zf:
            for member in zf.namelist():
                if member.endswith(".deb"):
                    fname = os.path.basename(member)
                    out_path = os.path.join(args.output_dir, fname)
                    with zf.open(member) as src, open(out_path, "wb") as dst:
                        shutil.copyfileobj(src, dst)
                    extracted_debs.append(fname)
                    print(f"  Extracted: {fname} ({os.path.getsize(out_path)} bytes)")

        if not extracted_debs:
            print("ERROR: No .deb files found in downloaded archive", file=sys.stderr)
            return 1

        # Detect kernel version from extracted filenames
        # Example filename: linux-image-7.3.1-krjy_7.3.1-0_arm64.deb or linux-headers-7.3.1-krjy_7.3.1-0_arm64.deb
        detected_version = ""
        for deb in extracted_debs:
            m = re.search(r'_([0-9]+\.[0-9]+[^_]+)_', deb)
            if m:
                detected_version = m.group(1)
                break
        if not detected_version and cand.get("tag"):
            detected_version = cand["tag"].lstrip("v").split("-")[0]

        print(f"\nSuccessfully imported {len(extracted_debs)} kernel packages (version: {detected_version})")

        # Export to GITHUB_OUTPUT if present
        github_output = os.environ.get("GITHUB_OUTPUT")
        if github_output and os.path.exists(github_output):
            with open(github_output, "a") as f:
                f.write(f"kernel_version={detected_version}\n")
                f.write(f"kernel_tag={cand.get('tag', '')}\n")

    return 0

if __name__ == "__main__":
    sys.exit(main())
