# stylus-popup

Dynamic Island style status pill for the Xiaomi Pad 5 stylus. It reads the
modified **IDTP9418** driver (`/dev/idtp9418`) that the `linux-nabu-618`
kernel ships, shows the pen's battery/charging state in a `wlr-layer-shell`
overlay and pairs the pen over Bluetooth on attach. It also turns the pen's
two side buttons into shell commands.

Packaged from `TwinbornPlate75/stylus-popup` @ `17a42ee` (MIT, © TwinbornPlate75
<3342733415@qq.com>) with three nabu patches:

| Patch | Fix |
| --- | --- |
| `0001` | Monitor uses `poll()` + an `eventfd` wake, so `stop()` can never hang; retries opening `/dev/idtp9418` while it is absent and drains every buffered event, so a pen docked before startup is still seen |
| `0002` | Generation detection (Gen 1 / Gen 2 / Unknown) from the docked pen's MAC, a `Gen N` tag in the popup, and a `generation=` config override |
| `0003` | Per-generation side-button key layout, with an explicit journal warning when the generation is unknown instead of a silent Gen-1 fallback |

## Use

```sh
systemctl --user enable --now stylus-popup.service
systemctl --user status  stylus-popup.service
```

The button mapping lives in `~/.config/stylus-popup/config.ini`, created with
defaults on first run. The popup section is `[popup]`; generation handling is
`[stylus]` with `generation=auto` (dock MAC), `gen1` or `gen2` (user pin).

The user must be a member of the `input` group for the button grab:

```sh
sudo usermod -aG input "$USER"   # then log out and back in
```