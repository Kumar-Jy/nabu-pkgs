# nabu-pkgs (Ubuntu Branch)

Custom Ubuntu / Debian packages for the **Xiaomi Pad 5 (nabu)**, built and published as an **APT repository**.

> For the full package catalog and installation instructions, see [**`PACKAGES.md`**](PACKAGES.md).

---

## 🚀 Adding the APT Repository

To use this repository on your Xiaomi Pad 5 running Ubuntu (e.g. 26.04), create `/etc/apt/sources.list.d/nabu.sources`:

```deb822
Types: deb
URIs: https://github.com/Kumar-Jy/nabu-pkgs/releases/download/ubuntu/
Suites: ./
Trusted: yes
```

Then update your package lists:

```bash
sudo apt update
```

To install or upgrade the custom kernel and hardware packages:

```bash
sudo apt install xiaomi-nabu-alsa xiaomi-nabu-firmware
sudo apt upgrade
```

---

## 🛠 Repository Structure

* **`.github/workflows/ubuntu-repo.yml`:** Automated workflow that builds device debs, imports kernels, generates APT metadata (`Packages.gz` and `Release`), and publishes to the `ubuntu` GitHub Release.
* **`.github/scripts/import-kernel-deb.py`:** Automates importing Ubuntu kernel `.deb` archives from `Kumar-Jy/linux`.
* **`.github/scripts/generate-apt-repo.sh`:** Builds standard Debian `Packages` and `Release` indexes with checksums.
* **`packages/`:** Contains Debian packaging recipes for Xiaomi Pad 5 specific packages.

---

## 📄 License

This repository and its custom scripts are released under the [MIT License](LICENSE). Individual packages inherit their respective upstream licenses.
