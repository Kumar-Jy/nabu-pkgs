#!/usr/bin/env python3
import argparse
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.parse
import urllib.request
import zipfile
from datetime import datetime

def parse_args():
    parser = argparse.ArgumentParser(description="Import linux-nabu package from Release or CI Artifact")
    parser.add_argument("--pkgver", required=True, help="Target kernel pkgver (e.g. 7.2.11)")
    parser.add_argument("--pkgrel", type=int, default=0, help="Target pkgrel if new version (default: 0)")
    parser.add_argument("--repo", default="Kumar-Jy/linux", help="Upstream kernel repository")
    parser.add_argument("--branch", default="nabu/7.2.y", help="Upstream branch for CI runs")
    parser.add_argument("--db-url", default="https://github.com/Kumar-Jy/nabu-pkgs/releases/download/repo/nabu.db.tar.gz", help="Pacman database URL")
    parser.add_argument("--output-dir", required=True, help="Directory to save final packages")
    return parser.parse_args()

def get_headers():
    headers = {"User-Agent": "nabu-pkgs-ci/1.0"}
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

def find_candidate(repo, branch, pkgver):
    headers = get_headers()

    # 1. Query GitHub Releases
    release_cand = None
    try:
        url = f"https://api.github.com/repos/{repo}/releases"
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            releases = json.loads(resp.read().decode())
        for r in releases:
            tag = r.get("tag_name", "")
            if pkgver in tag:
                for a in r.get("assets", []):
                    name = a.get("name", "")
                    if "arch" in name and (pkgver in name or "linux-nabu" in name):
                        dt = datetime.fromisoformat(r["published_at"].replace("Z", "+00:00"))
                        release_cand = {
                            "type": "release",
                            "tag": tag,
                            "timestamp": dt.timestamp(),
                            "date_str": r["published_at"],
                            "download_url": a["browser_download_url"],
                            "name": name,
                        }
                        break
            if release_cand:
                break
    except Exception as e:
        print(f"Notice: Release search returned: {e}")

    # 2. Query GitHub Actions Artifacts
    artifact_cand = None
    try:
        url = f"https://api.github.com/repos/{repo}/actions/runs?branch={urllib.parse.quote(branch, safe='')}&status=success"
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            runs = json.loads(resp.read().decode()).get("workflow_runs", [])
        for run in runs:
            art_req = urllib.request.Request(run["artifacts_url"], headers=headers)
            with urllib.request.urlopen(art_req) as resp2:
                arts = json.loads(resp2.read().decode()).get("artifacts", [])
            for a in arts:
                aname = a.get("name", "")
                if pkgver in aname and "arch" in aname:
                    dt = datetime.fromisoformat(run["created_at"].replace("Z", "+00:00"))
                    artifact_cand = {
                        "type": "artifact",
                        "run_id": run["id"],
                        "artifact_id": a["id"],
                        "artifact_name": aname,
                        "timestamp": dt.timestamp(),
                        "date_str": run["created_at"],
                        "download_url": a["archive_download_url"],
                    }
                    break
            if artifact_cand:
                break
    except Exception as e:
        print(f"Notice: Action runs search returned: {e}")

    # 3. Select newest candidate
    if release_cand and artifact_cand:
        if release_cand["timestamp"] >= artifact_cand["timestamp"]:
            print(f"Found both Release and Artifact. Picking newer Release ({release_cand['date_str']} vs {artifact_cand['date_str']})")
            return release_cand
        else:
            print(f"Found both Release and Artifact. Picking newer Artifact ({artifact_cand['date_str']} vs {release_cand['date_str']})")
            return artifact_cand
    elif release_cand:
        print(f"Picking Release candidate ({release_cand['tag']}, date: {release_cand['date_str']})")
        return release_cand
    elif artifact_cand:
        print(f"Picking Action Artifact candidate ({artifact_cand['artifact_name']}, run: {artifact_cand['run_id']}, date: {artifact_cand['date_str']})")
        return artifact_cand
    else:
        print(f"ERROR: No release or action artifact found for version {pkgver} in {repo}")
        sys.exit(1)

def download_candidate(cand, dest_dir, branch):
    os.makedirs(dest_dir, exist_ok=True)
    headers = get_headers()
    zip_dest = os.path.join(dest_dir, "kernel.zip")

    if cand["type"] == "release":
        print(f"Downloading release asset from: {cand['download_url']}")
        req = urllib.request.Request(cand["download_url"], headers=headers)
        with urllib.request.urlopen(req) as resp, open(zip_dest, "wb") as out:
            shutil.copyfileobj(resp, out)
    else:
        # Artifact download
        downloaded = False
        token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
        if token:
            try:
                print(f"Attempting artifact download via GitHub API...")
                req = urllib.request.Request(cand["download_url"], headers=headers)
                with urllib.request.urlopen(req) as resp, open(zip_dest, "wb") as out:
                    shutil.copyfileobj(resp, out)
                downloaded = True
                print("Downloaded artifact via GitHub API.")
            except Exception as e:
                print(f"GitHub API download failed: {e}")

        if not downloaded:
            # Fallback 1: gh CLI
            try:
                print("Attempting artifact download via gh CLI...")
                cmd = ["gh", "run", "download", str(cand["run_id"]), "--name", cand["artifact_name"], "--dir", dest_dir]
                res = subprocess.run(cmd, capture_output=True, text=True)
                if res.returncode == 0:
                    print("Downloaded artifact via gh CLI.")
                    return
                else:
                    print(f"gh CLI download failed: {res.stderr.strip()}")
            except Exception as e:
                print(f"gh CLI not available: {e}")

        if not downloaded:
            # Fallback 2: nightly.link blob extraction
            try:
                print("Attempting artifact download via nightly.link...")
                page_url = f"https://nightly.link/Kumar-Jy/linux/workflows/pkgbuild/{urllib.parse.quote(branch, safe='')}/{cand['artifact_name']}"
                req = urllib.request.Request(page_url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req) as resp:
                    html = resp.read().decode("utf-8", errors="ignore")
                m = re.search(r'href=\"(https://[^\"]+blob\.core\.windows\.net[^\"]+)\"', html)
                if m:
                    blob_url = m.group(1).replace("&amp;", "&")
                    with urllib.request.urlopen(blob_url) as resp, open(zip_dest, "wb") as out:
                        shutil.copyfileobj(resp, out)
                    downloaded = True
                    print("Downloaded artifact via nightly.link blob URL.")
            except Exception as e:
                print(f"nightly.link download failed: {e}")

        if not downloaded:
            print("ERROR: Failed to download candidate artifact through all methods.")
            sys.exit(1)

    if os.path.exists(zip_dest):
        print(f"Extracting {zip_dest}...")
        with zipfile.ZipFile(zip_dest) as zf:
            zf.extractall(dest_dir)
        os.remove(zip_dest)

def inspect_package(pkg_path):
    with open(pkg_path, "rb") as f:
        pkg_bytes = f.read()
    h = hashlib.sha256(pkg_bytes).hexdigest()

    tf = tarfile.open(fileobj=io.BytesIO(pkg_bytes), mode="r:*")
    info = {"sha256": h}
    try:
        pf = tf.extractfile(".PKGINFO")
        if pf:
            for line in pf.read().decode("utf-8", errors="ignore").splitlines():
                if " = " in line:
                    k, v = line.split(" = ", 1)
                    k = k.strip()
                    v = v.strip()
                    if k == "pkgname":
                        info["pkgname"] = v
                    elif k == "pkgver":
                        info["pkgver"] = v
                    elif k == "builddate":
                        info["builddate"] = int(v)
    except Exception as e:
        print(f"Warning extracting .PKGINFO from {pkg_path}: {e}")
    return info

def get_existing_db_pkg(db_url, pkgname):
    try:
        req = urllib.request.Request(db_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as resp:
            db_bytes = resp.read()
        tf = tarfile.open(fileobj=io.BytesIO(db_bytes), mode="r:gz")
        best = None
        for m in tf.getmembers():
            if m.name.endswith("/desc") and m.name.startswith(f"{pkgname}-"):
                f = tf.extractfile(m)
                lines = f.read().decode("utf-8", errors="ignore").splitlines()
                entry = {}
                for i, line in enumerate(lines):
                    if line.startswith("%") and line.endswith("%") and i + 1 < len(lines):
                        k = line[1:-1]
                        entry[k] = lines[i+1]
                v = entry.get("VERSION", "")
                if "-" in v:
                    base_v, rel_v = v.rsplit("-", 1)
                else:
                    base_v, rel_v = v, "0"
                entry["base_ver"] = base_v
                try:
                    entry["rel_num"] = int(rel_v)
                except ValueError:
                    entry["rel_num"] = 0
                if best is None:
                    best = entry
                else:
                    if base_v > best["base_ver"] or (base_v == best["base_ver"] and entry["rel_num"] > best["rel_num"]):
                        best = entry
        return best
    except Exception as e:
        print(f"Notice fetching db: {e}")
        return None

def main():
    args = parse_args()
    print(f"=== Checking kernel import for version {args.pkgver} ===")
    cand = find_candidate(args.repo, args.branch, args.pkgver)

    tmp_dir = tempfile.mkdtemp(prefix="kernel-import-")
    try:
        download_candidate(cand, tmp_dir, args.branch)

        pkg_files = [f for f in os.listdir(tmp_dir) if f.endswith(".pkg.tar.xz") or f.endswith(".pkg.tar.zst")]
        if not pkg_files:
            print("ERROR: No .pkg.tar.* files found in downloaded archive.")
            sys.exit(1)

        print(f"Downloaded package files: {pkg_files}")

        main_pkg_file = next((f for f in pkg_files if f.startswith("linux-nabu-") and not f.startswith("linux-nabu-headers-")), None)
        if not main_pkg_file:
            print("ERROR: Could not locate main linux-nabu package file.")
            sys.exit(1)

        main_pkg_path = os.path.join(tmp_dir, main_pkg_file)
        cand_info = inspect_package(main_pkg_path)
        print(f"Candidate package: {cand_info}")

        existing_info = get_existing_db_pkg(args.db_url, "linux-nabu")
        print(f"Existing package in db: {existing_info}")

        cand_pkgver_full = cand_info.get("pkgver", "")
        if "-" in cand_pkgver_full:
            cand_base_ver, cand_rel_str = cand_pkgver_full.rsplit("-", 1)
            cand_rel = int(cand_rel_str)
        else:
            cand_base_ver = cand_pkgver_full
            cand_rel = 0

        is_new_build = False
        target_pkgrel = args.pkgrel

        if existing_info is None:
            print(f"No existing linux-nabu in database. New build accepted.")
            is_new_build = True
            target_pkgrel = cand_rel
        elif cand_base_ver != existing_info.get("base_ver"):
            print(f"New base version detected ({cand_base_ver} vs existing {existing_info.get('base_ver')}). New build accepted.")
            is_new_build = True
            target_pkgrel = args.pkgrel
        else:
            # Same base version: verify build date and hash
            existing_sha256 = existing_info.get("SHA256SUM", "")
            existing_builddate = int(existing_info.get("BUILDDATE", 0))
            cand_sha256 = cand_info.get("sha256", "")
            cand_builddate = cand_info.get("builddate", 0)

            print(f"Comparing build date & hash for {cand_base_ver}:")
            print(f"  Existing db: sha256={existing_sha256}, builddate={existing_builddate}")
            print(f"  Candidate:   sha256={cand_sha256}, builddate={cand_builddate}")

            if cand_sha256 == existing_sha256 and cand_builddate <= existing_builddate:
                print(f"::notice::Build verified: candidate SHA256 and build date match existing package in database ({existing_info.get('VERSION')}). No new build available. Skipping.")
                is_new_build = False
            else:
                is_new_build = True
                target_pkgrel = existing_info.get("rel_num", 0) + 1
                print(f"New build detected! Hash or build date differs from db. Auto-bumping pkgrel to {target_pkgrel}.")

        if not is_new_build:
            print("Nothing to build or update. Repository is up to date.")
            sys.exit(0)

        # Copy or repackage
        os.makedirs(args.output_dir, exist_ok=True)
        for f in pkg_files:
            src_path = os.path.join(tmp_dir, f)
            info = inspect_package(src_path)
            pkgname = info.get("pkgname", "")
            ext = ".pkg.tar.xz" if f.endswith(".pkg.tar.xz") else ".pkg.tar.zst"

            if target_pkgrel == cand_rel:
                dest_path = os.path.join(args.output_dir, f)
                print(f"Copying {f} as-is to {dest_path}...")
                shutil.copy2(src_path, dest_path)
            else:
                new_pkgver = f"{cand_base_ver}-{target_pkgrel}"
                new_filename = f"{pkgname}-{new_pkgver}-aarch64{ext}"
                dest_path = os.path.join(args.output_dir, new_filename)
                print(f"Repackaging {f} -> {dest_path} with pkgver={new_pkgver}...")

                repack_dir = tempfile.mkdtemp(prefix=f"repack-{pkgname}-")
                try:
                    subprocess.run(["bsdtar", "-xf", src_path, "-C", repack_dir], check=True)
                    pkginfo_path = os.path.join(repack_dir, ".PKGINFO")
                    if os.path.exists(pkginfo_path):
                        with open(pkginfo_path, "r") as pf:
                            c = pf.read()
                        c = re.sub(r"^pkgver = .*", f"pkgver = {new_pkgver}", c, flags=re.MULTILINE)
                        with open(pkginfo_path, "w") as pf:
                            pf.write(c)

                    buildinfo_path = os.path.join(repack_dir, ".BUILDINFO")
                    if os.path.exists(buildinfo_path):
                        with open(buildinfo_path, "r") as bf:
                            c = bf.read()
                        c = re.sub(r"^pkgver = .*", f"pkgver = {new_pkgver}", c, flags=re.MULTILINE)
                        with open(buildinfo_path, "w") as bf:
                            bf.write(c)

                    # Regenerate .MTREE
                    mtree_path = os.path.join(repack_dir, ".MTREE")
                    if os.path.exists(mtree_path):
                        os.remove(mtree_path)
                    entries = [e for e in os.listdir(repack_dir) if e != ".MTREE"]
                    subprocess.run(
                        ["bsdtar", "-czf", ".MTREE", "--format=mtree",
                         "--options=!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link"] + entries,
                        cwd=repack_dir, check=True
                    )

                    tar_entries = [".PKGINFO"]
                    if os.path.exists(os.path.join(repack_dir, ".BUILDINFO")):
                        tar_entries.append(".BUILDINFO")
                    tar_entries.append(".MTREE")
                    tar_entries.extend([e for e in os.listdir(repack_dir) if e not in [".PKGINFO", ".BUILDINFO", ".MTREE"]])

                    if ext == ".pkg.tar.zst":
                        compress_cmd = ["zstd", "-T0", "-19", "-c"]
                    else:
                        compress_cmd = ["xz", "-T0", "-c"]

                    p1 = subprocess.Popen(["tar", "-cf", "-"] + tar_entries, cwd=repack_dir, stdout=subprocess.PIPE)
                    with open(dest_path, "wb") as out_f:
                        p2 = subprocess.Popen(compress_cmd, stdin=p1.stdout, stdout=out_f)
                        p1.stdout.close()
                        p2.communicate()
                        if p2.returncode != 0:
                            raise RuntimeError(f"Compression failed with exit code {p2.returncode}")
                finally:
                    shutil.rmtree(repack_dir, ignore_errors=True)

        print(f"Successfully processed packages for {cand_base_ver}-{target_pkgrel}:")
        for out_file in os.listdir(args.output_dir):
            out_p = os.path.join(args.output_dir, out_file)
            print(f"  {out_file} ({os.path.getsize(out_p)} bytes, sha256={hashlib.sha256(open(out_p, 'rb').read()).hexdigest()})")

    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

if __name__ == "__main__":
    main()
