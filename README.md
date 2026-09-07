# nabu-pkgs

Custom Arch Linux ARM packages for the Xiaomi Pad 5 (nabu), built and
published as a pacman repository.

## Packages

| Package        | Description                                        |
| -------------- | -------------------------------------------------- |
| `linux-nabu`   | Linux kernel + headers for nabu (6.16 + SMB5 charger) |
| `linux-nabu-614` | Linux kernel + headers for nabu (CFM880 6.14.11 iris + camera baseline) |
| `upower-nncc`  | upower patched for nabu battery                   |
| `bootc`        | bootc (bootable containers) binary                |
| `code`         | Visual Studio Code                                |
| `python2`      | Python 2                                          |
| `widevine`     | Widevine DRM                                      |
| `nabu-pmac`    | Deterministic WLAN MAC from board serial          |

## Repository

Packages are built and published automatically by the
`arch-repo.yml` GitHub Actions workflow. The resulting pacman repository is
uploaded as a GitHub Release named `repo`:

```
https://github.com/Kumar-Jy/nabu-pkgs/releases/download/repo
```

To use it in a system, add the following to `/etc/pacman.conf`:

```
[nabu]
SigLevel = Never
Server = https://github.com/Kumar-Jy/nabu-pkgs/releases/download/repo
```

## Building

Run the `Arch repo` workflow (`build_linux_nabu`, `build_bootc`, etc. inputs
control which packages are rebuilt). The workflow caches builds by source
signature and only rebuilds when the upstream source or version changes.

## SMB5 charger backport (linux-nabu-616)

The `linux-nabu-616` package carries a `0051..0054` patch series that backports
the Qualcomm SMB5 charger (`qcom_smbx` driver) to 6.16, replacing the earlier
`ln8000` fast-charge IC so **5V USB / QC3 A-to-C** adapters charge the Pad 5
(PD over C-to-C already worked; ln8000's 6.5V OVP floor blocked sub-6.5V
sources):

- `0051` backport `qcom_smbx.c` — the PM8150B switch-mode charger + boost
  driver (USBIN + battery OVP etc.).
- `0052` `pm8150b.dtsi` — add `pm8150b_charger: charger@1000` node +
  `ADC5_USB_IN_I` / `ADC5_USB_IN_V_16` IIO channels.
- `0053` nabu dts — drop the `ln8000_charger@51` node, wire
  `pm8150b_fg` `power-supplies` to `&pm8150b_charger`, enable it.
- `0054` power supply Makefile — build `qcom_smbx.o` for `CHARGER_QCOM_SMB2`.

`config`: `CONFIG_CHARGER_QCOM_SMB2=y`, `CONFIG_CHARGER_LN8000` unset. The
SM8150 camss series (old `0051..0055`) was removed: enabling camss/cci at boot
is rejected by the ABL bootloader (gray-screen reset) and caused a no-console
CAMSS probe hang, so camera nodes stay disabled.

### Validate only the kernel build (no repo touch)

Run the `Build linux-nabu-616` workflow (`build-linux-nabu-616.yml`).
It compiles the patched kernel on a native aarch64 runner and uploads the
`.pkg.tar.*` as an artifact — no GPG signing or `repo` release rewrite, so it is
safe to run on forks/PRs. Install the artifact on the device with
`pacman -U linux-nabu-*.pkg.tar.*`.

The full `Arch repo` workflow assembles and re-signs the pacman repository and
requires the `REPO_GPG_PRIVATE_KEY` / `REPO_GPG_KEY_ID` secrets, so prefer the
build-only workflow until the charger changes are validated on hardware.

## CFM880 baseline (linux-nabu-614)

The `linux-nabu-614` package adopts the postmarketOS `sm8150/6.14.11` kernel
tree at `5181e1358ddd6ea8028e841d928942373e6aebc8` — the exact baseline CFM880's
nabu repos are built against — so the full feature stack applies cleanly:

- **nabu-camera** (`c0e4fdb`): rear OV13B10 + front OV8856 + CN3927 AF, camss/cci
  — applied verbatim via `kernel-overlay/`.
- **nabu-iris** (`ed09ef4`): Iris1/Venus HW video decode driver.
- **nabu-accelerometer** (`25bc5c3`): LSM6DSO via SLPI/SSC, FastRPC/PDR patch
  (high-IOVA alias + root-PD PDR wait), `fastrpc`/`qcom_pd_mapper` modules.
- The boot DTB is the derived
  `sm8150-xiaomi-nabu-iris-camera-accelerometer-slpi-boot-only.dtb`
  (`sm8150-xiaomi-nabu.dts` + iris + camera + SLPI DTSIs), built via Kbuild's
  explicit per-dtb target.

Config is generated from `defconfig` + `sm8150.config` + the `nabu-camera.config`
and `nabu-iris.config` fragments. Firmware (`venus.mbn`, `slpi_nb.mbn`) comes
from the `linux-firmware-xiaomi-nabu` dependency.

**Production mode (matches CFM880):** the SLPI accelerometer is the default boot
target — the postinstall writes `fw_devlink=permissive` and blacklists
`venus_core,qcom_iris` (HW video decode off, camera on). The iris driver is
still built; remove `/etc/modprobe.d/blacklist-iris.conf` to re-enable video
decode at the cost of the accelerometer.

### Validate only the kernel build (no repo touch)

Run the `Build linux-nabu-614` workflow (`build-linux-nabu-614.yml`). It
compiles the stock 6.14.11 base + both CFM880 overlays on a native aarch64
runner and uploads the `.pkg.tar.*` as an artifact — no GPG signing or `repo`
release rewrite. Install the artifact on the device with
`pacman -U linux-nabu-*.pkg.tar.*`.

## Adding a package

1. Create `packages/<name>/PKGBUILD`.
2. Add the name to the package list in `arch-repo.yml`.