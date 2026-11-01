# plasma-keyboard-full-layout

Add-on package for **Plasma Keyboard** that installs

* full-size, two-page keyboard layouts for `en_US` and 16 other languages, plus
  full-size **Hindi** layouts, and
* a patched Plasma Keyboard binary that sends **real modifier chords**
  (`Ctrl+V`, `Ctrl+Shift+V`, `Ctrl+C`, ...) to the focused application.

The stock `plasma-keyboard` package stays installed and untouched.

## Layouts without touching package files

At startup Plasma Keyboard picks the **first** existing
`<GenericDataLocation>/plasma/keyboard/layouts` directory and points Qt's
virtual keyboard at it. On this system the search list is:

```
~/.local/share:/usr/local/share:/usr/share
```

So layouts installed under `/usr/local/share/plasma/keyboard/layouts` override
the stock layout without touching any package-owned file. All stock layouts that
are not overridden are symlinked from `/usr/share` so they keep working.

## Working modifier chords

The stock keyboard only commits text, so tapping `Ctrl` and then `V` never
produced a shortcut. Upstream Plasma Keyboard (6.8.2) has no path from QML to a
real key event with modifiers.

`plasma-keyboard-chords.patch` adds that path:

* `InputPlugin::sendChord(Qt::Key, Qt::KeyboardModifiers)` resolves the key to an
  evdev keycode via the input method's xkb keymap and emits
  `zwp_input_method_context_v1.modifiers` + `key` press/release + a modifiers
  reset.
* `InputListenerItem` turns a key press with **empty text** and Ctrl/Alt/Meta
  into `sendChord()` and swallows the matching release, so shortcuts are not
  also inserted as text.

In the QML layouts, `FullKey.qml` dispatches chords with
`InputContext.sendKeyClick(keyCode, "", mods)`; empty text is what selects the
shortcut path. Modifiers are one-shot latches: tap `Ctrl`, then `C`.

This was verified end-to-end against a Wayland text-input-v3 client:
`Ctrl+V` and `Ctrl+Shift+V` arrive as key events with the modifier state set,
and the clipboard content is actually pasted.

## Included layouts

- `en_US` - full-size, two-page typing layout (numbers/QWERTY/modifiers page 1,
  functions/navigation/symbols page 2)
- `fr_FR`, `de_DE`, `es_ES`, `it_IT`, `pt_BR`, `nl_NL`, `sv_SE`, `da_DK`, `fi_FI`,
  `pl_PL`, `cs_CZ`, `el_GR`, `hu_HU`, `tr_TR`, `ru_RU`, `uk_UA` - full-size,
  two-page layouts generated from each language's character set
- `hi_IN` - full-size, two-page **Hindi phonetic** layout. Latin keys produce
  Devanagari: consonants accumulate into a syllable, a following consonant gets
  a halant, and a vowel becomes a matra, so typing `namaste` produces `नमस्ते`.
- `hi_IN_inscript` - full-size, two-page **Hindi InScript** layout (Devanagari
  directly, two InScript input levels).

All other languages keep the stock `/usr/share` layouts via symlinks.

## Language switching

Every layout shipped by this package (including both Hindi layouts) provides a
globe / change-language key before the space bar on both pages, so the user can
cycle or pick another enabled language without leaving the keyboard.

Languages are managed through the normal Plasma Keyboard settings:

* System Settings -> Input & Output -> Virtual Keyboard -> **Languages**, or
* `~/.config/plasmakeyboardrc` (`[General] enabledLocales`).

The globe key switches between the enabled languages; it requires at least two
enabled locales.

> **Note:** the name `hi_IN_inscript` is a technical locale identifier; it is
> displayed in the KCM as plain **हिन्दी**. The same display name is used for both
> the phonetic (`hi_IN`) and the InScript (`hi_IN_inscript`) entries.

## Build and install

The package builds the patched binary from the Plasma Keyboard 6.8.2 source
tarball, so it is architecture specific (`arch=('aarch64')`).

```bash
cd ~/plasma-keyboard-full-layout
makepkg -f
sudo pacman -U plasma-keyboard-full-layout-1.3.0-1-aarch64.pkg.tar.xz
```

If you previously installed the binary or desktop file by hand, let pacman take
them over:

```bash
sudo pacman -U --overwrite '/usr/local/bin/plasma-keyboard-nabu' \
               --overwrite '/usr/local/share/applications/org.kde.plasma.keyboard.nabu.desktop' \
               plasma-keyboard-full-layout-1.3.0-1-aarch64.pkg.tar.xz
```

Then select the patched keyboard through KWin's `InputMethod` setting and make
sure no per-user layout override is in the way:

```bash
rm -rf ~/.local/share/plasma/keyboard/layouts
kwriteconfig6 --file kwinrc --group Wayland --key InputMethod --notify \
    /usr/local/share/applications/org.kde.plasma.keyboard.nabu.desktop
```

Log out and back in, or toggle the setting, to restart the input method. The
`.install` script enables it automatically for existing `/home/*` users on a
fresh install.

## Update / uninstall

```bash
makepkg -f
sudo pacman -U plasma-keyboard-full-layout-1.3.0-1-aarch64.pkg.tar.xz   # after bumping pkgrel
sudo pacman -Rns plasma-keyboard-full-layout
```

After removal, point KWin back at the stock keyboard:

```bash
kwriteconfig6 --file kwinrc --group Wayland --key InputMethod --notify \
    /usr/share/applications/org.kde.plasma.keyboard.desktop
```

The stock `plasma-keyboard` package is never modified; this add-on only depends
on it.

## Files

| File | Purpose |
| --- | --- |
| `PKGBUILD` | builds the patched binary and installs layouts |
| `plasma-keyboard-chords.patch` | C++ chord support for Plasma Keyboard 6.8.2 |
| `FullKey.qml` | key behaviour: latches, shifted symbols, page switching, chords, Hindi |
| `main.qml` | full-size two-page `en_US` layout |
| `<locale>.qml` | full-size two-page layouts for the other languages, plus `hi_IN*.qml` |
| `org.kde.plasma.keyboard.nabu.desktop` | launcher for `/usr/local/bin/plasma-keyboard-nabu` |
| `plasma-keyboard-full-layout.install` | enables the input method for existing users |
