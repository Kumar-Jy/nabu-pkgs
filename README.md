# nabu-pkgs

Custom Arch Linux ARM packages for the Xiaomi Pad 5 (nabu), built and
published as a pacman repository.

> For the full package catalog and install commands, see [**`PACKAGES.md`**](PACKAGES.md).

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

## License

This repository and its packages are released under the [MIT License](LICENSE).
Individual packages contain their respective licenses and copyright notices
under `packages/<name>/LICENSE`.