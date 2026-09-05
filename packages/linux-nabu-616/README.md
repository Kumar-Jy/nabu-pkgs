# linux-nabu-616 — SMB5 charger + Iris hardware video notes

This package builds the vanilla `6.16.0` kernel with the `0001..0050`
rodriguezst patches plus the `0051..0054` SMB5 charger series, and installs
it as `linux-nabu`.

The SMB5 backport adds the Qualcomm PM8150B charger block
(`qcom_smbx` / `CONFIG_CHARGER_QCOM_SMB2`), replacing the `ln8000`
fast-charge IC so **5V USB / QC3 A-to-C** adapters charge the Pad 5.

## Install from the CI artifact

```
pacman -U linux-nabu-6.16.0-*.pkg.tar.zst linux-nabu-headers-6.16.0-*.pkg.tar.zst
```
Reboot, then validate.

## On-device validation

```
dmesg | grep -i smbx       # qcom-smbx-charger probes (Generation SMB5)
power_supply_wakeup        # available via /sys
cat /sys/class/power_supply/*/status     # Charging?
cat /sys/class/power_supply/*/voltage_now
cat /sys/class/power_supply/*/current_now
```

Expected on a 5V USB source: `status=Charging`, `voltage_now` ~4.8-5.0 V over
the USBIN path, positive charge current.

## Patch series

- `0051` backport `qcom_smbx.c` — PM8150B switch-mode charger + boost driver
  (USBIN, battery OVP, WDOG).
- `0052` `pm8150b.dtsi` — `pm8150b_charger: charger@1000` node and the
  `ADC5_USB_IN_I` (usbin_i) / `ADC5_USB_IN_V_16` (usbin_v) IIO channels.
- `0053` nabu dts — remove `ln8000_charger@51`, wire `pm8150b_fg`
  `power-supplies` to `&pm8150b_charger`, enable the charger.
- `0054` power supply Makefile — build `qcom_smbx.o`.

`config`: `CONFIG_CHARGER_QCOM_SMB2=y`, `CONFIG_CHARGER_LN8000` unset.

## Reality check

PD over C-to-C charging already worked via the Type-C/PD controller. The SMB5
backport is what enables plain 5V USB and QC3 A-to-C charging (the ln8000 IC's
6.5V OVP floor previously blocked all sub-6.5V sources).

## Iris hardware video decode (pkgrel-15)

`0058` replaces `drivers/media/platform/qcom/iris/` with the CFM880 fork
v1.5.4 which adds the **SM8150 platform** (encoder + VP9 superframe + P010
10-bit + `cached_capture`), flips `videocc-sm8150` vcodec GDSCs to
`HW_CTRL_TRIGGER`, and adds a **derived DTB** `sm8150-xiaomi-nabu-iris.dtb`
carrying the `video-codec@aa00000` (`qcom,sm8150-iris`) node.

The stock `sm8150-xiaomi-nabu.dtb` remains untouched, so the default boot is
unchanged. Boot with the **iris DTB** to get `/dev/video0` (decoder) and
`/dev/video1` (encoder). The Venus driver stays stock and idle (SM8150 binds
iris, not Venus).

### Enable after installing pkgrel-15

```
# iris DTB: point the UKI / U-Boot at sm8150-xiaomi-nabu-iris.dtb
modprobe qcom_iris cached_capture=1        # or rely on 99-iris-vaapi.conf
LIBVA_DRIVER_NAME=iris vainfo              # H264/HEVC/VP9 VAEntrypointVLD
```

Pair with the `iris-vaapi` AUR package (Qt VA-API driver + udev dma_heap rule
+ `cached_capture=1` modprobe conf) for Chrome/FFmpeg hardware decode.
Firmware: `/lib/firmware/qcom/sm8150/xiaomi/nabu/venus.mbn`.

## Speaker / audio finding — pkgrel-15 dropped, rebased onto pkgrel-14

Sound is handled by the **legacy q6asm (ASM)** path on the sm8150 sndcard
(`MultiMedia1 <-> cs35l41 speakers` via `QUAT_TDM_RX_0`). This section records
what was measured, because the first hypothesis (a recoverable boot race) was
wrong and the investigation had to be redone.

Measured facts:

- **pkgrel-14 (charger-fixed):** speaker sound works through the normal
  PipeWire stack (YouTube / GNOME Settings heard).
- **pkgrel-15 (iris):** raw ALSA proves the hardware + DSP are healthy —
  `aplay -D hw:X5,0` produces a tone the user hears. But **PipeWire's Speaker
  sink never completes playback** (stays `suspended`, `Format` stays empty), so
  Chrome/YouTube and GNOME's speaker test are silent. The sink is created with
  `api.alsa.open.ucm=true` and its UCM import fails (`alsaucm -c X5` reports
  `failed to import X5 use case configuration -2`). Forcing the sink to open
  without UCM (`api.alsa.open.ucm=false` via a `monitor.alsa.rules`
  `update-props` override) still left it `suspended` and produced no sound.
- The q6asm kernel source, the audio kernel config, the audio DT nodes, and the
  `sound/soc/qcom`, `drivers/soc/qcom`, `drivers/remoteproc`, and `drivers/iommu`
  trees are each **byte-identical** between pkgrel-14 and pkgrel-15. The iris
  patch touches only the video node/module and phandle shifts.

**Conclusion:** the pkgrel-15 speaker issue is **not** a kernel, DTS, or config
regression — the silicon/ALSA/DSP path works (proven by `aplay`). The blocker
is a **userspace PipeWire/WirePlumber↔q6asm format-negotiation failure on the
pkgrel-15 boot** that could not be resolved at the config level from the live
system.

**Decision:** pkgrel-15 is **dropped**. The current build is **pkgrel-14 base +
iris video patch only** — keeping the proven-working PipeWire speaker path of
pkgrel-14 *and* the iris hardware decode in a single boot. Boot with the iris
DTB to get both `/dev/video0`/`/dev/video1` and working speaker audio.

If audio is ever silent right after boot, wait a few seconds and play again (the
one-time ~25s q6asm/GLINK boot race on the amps), or
`systemctl --user restart pipewire wireplumber`.

Note: `cached_capture=1` (`/etc/modprobe.d/99-iris-vaapi.conf`) is video-only
and does **not** affect this audio path.
