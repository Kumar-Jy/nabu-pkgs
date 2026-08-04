# nabu-pkgs

Custom Arch Linux ARM packages for the Xiaomi Pad 5 (nabu), built and
published as a pacman repository.

## Packages

| Package        | Description                                        |
| -------------- | -------------------------------------------------- |
| `linux-nabu`   | Linux kernel + headers for nabu (TwinbornPlate75) |
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

## Adding a package

1. Create `packages/<name>/PKGBUILD`.
2. Add the name to the package list in `arch-repo.yml`.