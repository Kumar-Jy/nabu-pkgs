// A Key with the extra behaviour needed by the full-size layout.
//
// Normal Qt VirtualKeyboard only implements Shift/Caps Lock. This component
// adds:
//   * shifted symbol text for the number/punctuation row
//   * Caps Lock that combines with Shift like a hardware keyboard
//   * one-shot Ctrl / Alt / Super / AltGr modifiers
//   * page switching keys
//
// When one of those modifiers is latched, the key event is sent by this
// component with the Qt modifier flags set. After the chord the modifier is
// automatically released.
//
// The key panel is overridden because the stock Breeze panel uses a fixed
// font size (60 * scaleHint). On a phone-sized keyboard that is large enough
// that long labels ("PrtSc", "Enter", ...) bleed outside the key. Here the
// label is scaled down horizontally until it fits inside the key.

import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Components

import org.kde.plasma.keyboard.lib as PlasmaKeyboard

Key {
    id: control

    // The KeyboardLayout / KeyboardLayoutLoader root, used for the shared
    // Shift/Caps/modifier/page state.
    property var layoutRoot: null

    // Text shown on the key. If empty, the character text is shown.
    property string label: ""

    // Character emitted without Shift.
    property string baseText: ""

    // Character emitted with Shift. Leave empty for letters; their case is
    // derived from baseText and the Shift/Caps state.
    property string shiftedText: ""

    // Qt.Key_* code sent for this key.
    property int keyCode: Qt.Key_unknown

    // Phonetic (Hindi) keys: the character this key produces and what it is.
    // The layout root decides whether the character is joined to the previous
    // consonant with a halant and whether a vowel becomes a matra.
    property string commitText: ""
    property bool consonantKey: false
    property bool vowelKey: false

    // "char", "function", "shift", "caps", "ctrl", "alt", "super", "altgr",
    // "page" or "hindi".
    property string keyRole: "char"

    // Target page for keyRole "page": 1 = main, 2 = function/symbols.
    property int pageNumber: 1

    readonly property bool stateModifier: keyRole === "ctrl" || keyRole === "alt"
                                          || keyRole === "super" || keyRole === "altgr"

    readonly property bool latched: {
        if (!layoutRoot)
            return false
        switch (keyRole) {
        case "shift":
            return layoutRoot.shiftActive
        case "caps":
            return layoutRoot.capsActive
        case "ctrl":
            return layoutRoot.ctrlActive
        case "alt":
            return layoutRoot.altActive
        case "super":
            return layoutRoot.superActive
        case "altgr":
            return layoutRoot.altGrActive
        default:
            return false
        }
    }

    key: keyCode
    text: {
        if (!layoutRoot)
            return baseText
        if (keyRole === "hindi")
            return ""
        if (keyRole !== "char")
            return baseText
        if (shiftedText.length > 0)
            return layoutRoot.shiftActive ? shiftedText : baseText
        return layoutRoot.upperCase ? baseText.toUpperCase() : baseText
    }
    displayText: label.length > 0 ? label : text

    // Do not let Qt VirtualKeyboard apply its own Shift handling; this
    // component changes the emitted text instead.
    noModifier: true
    functionKey: keyRole !== "char"
    // Modifier and page keys never emit an event directly. Other keys suppress
    // their normal event only when a chord modifier is latched, so that
    // onClicked() below can send the complete chord.
    noKeyEvent: stateModifier || keyRole === "shift" || keyRole === "caps"
                || keyRole === "page" || keyRole === "hindi"
                || (layoutRoot && layoutRoot.hasChordModifier)
    highlighted: latched || keyRole === "page"

    // Key panel with a label that shrinks to fit instead of overlapping the
    // neighbouring keys. Reuses the Breeze panel so colours, shadow, key click
    // sound and vibration stay consistent with the rest of the keyboard.
    keyPanelDelegate: Component {
        PlasmaKeyboard.BreezeKeyPanel {
            id: panel

            Item {
                anchors.fill: parent

                Text {
                    id: keyText
                    anchors.fill: parent
                    text: panel.control ? panel.control.displayText : ""
                    color: PlasmaKeyboard.BreezeConstants.keyTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.NoWrap
                    clip: true
                    opacity: panel.control && !panel.control.enabled ? 0.4 : 1.0
                    font {
                        family: PlasmaKeyboard.BreezeConstants.fontFamily
                        weight: Font.Light
                        pixelSize: Math.max(12, 52 * PlasmaKeyboard.BreezeConstants.scaleHint)
                    }
                    // Shrink long labels (e.g. "PrtSc", "Enter") until they fit
                    // the key width instead of running into the next key.
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: Math.max(8, Math.round(18 * PlasmaKeyboard.BreezeConstants.scaleHint))
                }
            }
        }
    }

    onClicked: {
        if (!layoutRoot)
            return

        switch (keyRole) {
        case "shift":
            layoutRoot.shiftActive = !layoutRoot.shiftActive
            return
        case "caps":
            layoutRoot.capsActive = !layoutRoot.capsActive
            return
        case "ctrl":
            layoutRoot.ctrlActive = !layoutRoot.ctrlActive
            return
        case "alt":
            layoutRoot.altActive = !layoutRoot.altActive
            return
        case "super":
            layoutRoot.superActive = !layoutRoot.superActive
            return
        case "altgr":
            layoutRoot.altGrActive = !layoutRoot.altGrActive
            return
        case "page":
            layoutRoot.secondPage = (pageNumber === 2)
            return
        case "hindi":
            // Phonetic input: the layout combines the character with the
            // previous one (halant / matra) and commits the result.
            layoutRoot.clearChordModifiers()
            layoutRoot.typeHindi(commitText, consonantKey, vowelKey)
            return
        }

        if (layoutRoot.hasChordModifier) {
            let mods = 0
            if (layoutRoot.ctrlActive)
                mods |= Qt.ControlModifier
            if (layoutRoot.altActive)
                mods |= Qt.AltModifier
            if (layoutRoot.superActive)
                mods |= Qt.MetaModifier
            if (layoutRoot.altGrActive)
                mods |= Qt.GroupSwitchModifier
            if (layoutRoot.shiftActive)
                mods |= Qt.ShiftModifier

            // Empty text makes the key event a pure shortcut: the patched
            // input listener turns it into a real key event with the modifier
            // state set, which is what applications need for Ctrl+V etc.
            InputContext.sendKeyClick(keyCode, "", mods)
            layoutRoot.clearChordModifiers()
        } else if (keyRole === "char" && layoutRoot.shiftActive) {
            // One-shot Shift: the normal event has already been sent by the
            // time onClicked() runs, so just clear the state for the next key.
            layoutRoot.shiftActive = false
        }

        // Any other key (space, punctuation, backspace, Enter, ...) ends the
        // current phonetic syllable.
        if (layoutRoot.phoneticReset)
            layoutRoot.phoneticReset()
    }
}
