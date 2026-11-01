// Full-size hi_IN layout for Plasma Keyboard.
//
// Installed in /usr/local/share/plasma/keyboard/layouts/hi_IN/.
// FullKey.qml next to this file implements the key behaviour (sticky
// Ctrl/Alt/Super/AltGr, Shift/Caps Lock, shifted symbols, page switching).
//
// The keyboard has two pages so that the keys can be larger:
//   page 1 - typing (Devanagari)
//   page 2 - function keys, navigation and symbols
//
// Modifier keys are one-shot/toggle keys. Ctrl, Alt, Super and AltGr clear
// after the next key; Shift is cleared after the next character. The globe
// key switches between the enabled languages.

import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Components

KeyboardLayoutLoader {
    id: root

    // Page 1 = typing, page 2 = function/navigation/symbols.
    property bool secondPage: false
    onVisibleChanged: {
        if (!visible) {
            secondPage = false
            clearChordModifiers()
            capsActive = false
            phoneticReset()
        }
    }

    // Shift/Caps state used by FullKey.qml.
    property bool shiftActive: false
    property bool capsActive: false

    // One-shot modifiers, cleared after the next chord.
    property bool ctrlActive: false
    property bool altActive: false
    property bool superActive: false
    property bool altGrActive: false

    // Caps Lock and Shift cancel each other for letter keys.
    readonly property bool upperCase: shiftActive !== capsActive

    // Whether the next key should be sent as a modifier chord.
    readonly property bool hasChordModifier: ctrlActive || altActive || superActive || altGrActive

    // Hindi phonetic input state. Consonants accumulate into a syllable and
    // are committed when a vowel (or any other key) arrives; a consonant that
    // follows another consonant gets a halant appended, and a vowel becomes a
    // matra of the pending consonant, so typing "namaste" produces "नमस्ते".
    property string hindiBuffer: ""

    readonly property var hindiMatras: ({
        "अ": "",
        "आ": "\u093E",
        "इ": "\u093F",
        "ई": "\u0940",
        "उ": "\u0941",
        "ऊ": "\u0942",
        "ऋ": "\u0943",
        "ए": "\u0947",
        "ऐ": "\u0948",
        "ओ": "\u094B",
        "औ": "\u094C"
    })

    function phoneticReset() {
        if (hindiBuffer.length > 0) {
            InputContext.commit(hindiBuffer)
            hindiBuffer = ""
        }
    }

    function typeHindi(character, consonant, vowel) {
        if (consonant) {
            if (hindiBuffer.length > 0)
                hindiBuffer += "\u094D"
            hindiBuffer += character
            return
        }
        if (hindiBuffer.length > 0) {
            let matra = hindiMatras[character] !== undefined ? hindiMatras[character] : character
            if (matra.length > 0)
                hindiBuffer += matra
            InputContext.commit(hindiBuffer)
            hindiBuffer = ""
            if (vowel)
                return
        }
        InputContext.commit(character)
    }

    function clearChordModifiers() {
        ctrlActive = false
        altActive = false
        superActive = false
        altGrActive = false
        shiftActive = false
    }

    sourceComponent: secondPage ? page2 : page1
    Component {
        id: page1
        KeyboardLayout {
            inputMode: InputEngine.InputMode.Latin
            keyWeight: 160
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "a"
                    commitText: "अ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "aa"
                    commitText: "आ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "i"
                    commitText: "इ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ee"
                    commitText: "ई"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "u"
                    commitText: "उ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "oo"
                    commitText: "ऊ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "e"
                    commitText: "ए"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ai"
                    commitText: "ऐ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "o"
                    commitText: "ओ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "au"
                    commitText: "औ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ं"
                    commitText: "ं"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ँ"
                    commitText: "ँ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ः"
                    commitText: "ः"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_Backspace
                    keyRole: "function"
                    label: "⌫"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "k"
                    commitText: "क"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "kh"
                    commitText: "ख"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "g"
                    commitText: "ग"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "gh"
                    commitText: "घ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ch"
                    commitText: "च"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "chh"
                    commitText: "छ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "j"
                    commitText: "ज"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "jh"
                    commitText: "झ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "T"
                    commitText: "ट"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "Th"
                    commitText: "ठ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "N"
                    commitText: "ण"
                    consonantKey: true
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "t"
                    commitText: "त"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "th"
                    commitText: "थ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "d"
                    commitText: "द"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "dh"
                    commitText: "ध"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "n"
                    commitText: "न"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "p"
                    commitText: "प"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ph"
                    commitText: "फ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "b"
                    commitText: "ब"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "bh"
                    commitText: "भ"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "m"
                    commitText: "म"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "y"
                    commitText: "य"
                    consonantKey: true
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "r"
                    commitText: "र"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "l"
                    commitText: "ल"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "v"
                    commitText: "व"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "sh"
                    commitText: "श"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "Sh"
                    commitText: "ष"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "s"
                    commitText: "स"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "h"
                    commitText: "ह"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "z"
                    commitText: "ज़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "f"
                    commitText: "फ़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "R"
                    commitText: "ड़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "Rh"
                    commitText: "ढ़"
                    consonantKey: true
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyRole: "page"
                    pageNumber: 2
                    label: "123"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_Control
                    keyRole: "ctrl"
                    label: "Ctrl"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.25
                    keyCode: Qt.Key_Alt
                    keyRole: "alt"
                    label: "Alt"
                }
                ChangeLanguageKey {
                    weight: 1.25
                }
                FullKey {
                    layoutRoot: root
                    weight: 3.0
                    keyCode: Qt.Key_Space
                    keyRole: "function"
                    label: "Space"
                    baseText: " "
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.25
                    keyCode: Qt.Key_AltGr
                    keyRole: "altgr"
                    label: "AltGr"
                }
                HideKeyboardKey {
                    weight: 1
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Left
                    keyRole: "function"
                    label: "←"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Up
                    keyRole: "function"
                    label: "↑"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Down
                    keyRole: "function"
                    label: "↓"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Right
                    keyRole: "function"
                    label: "→"
                }
            }
        }
    }

    Component {
        id: page2
        KeyboardLayout {
            inputMode: InputEngine.InputMode.Latin
            keyWeight: 160
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "क़"
                    commitText: "क़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ख़"
                    commitText: "ख़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ग़"
                    commitText: "ग़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "य़"
                    commitText: "य़"
                    consonantKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ri"
                    commitText: "ऋ"
                    vowelKey: true
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "ॐ"
                    commitText: "ॐ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "्"
                    commitText: "्"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyRole: "hindi"
                    label: "।"
                    commitText: "।"
                }
            }
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Escape
                    keyRole: "function"
                    label: "Esc"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F1
                    keyRole: "function"
                    label: "F1"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F2
                    keyRole: "function"
                    label: "F2"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F3
                    keyRole: "function"
                    label: "F3"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F4
                    keyRole: "function"
                    label: "F4"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F5
                    keyRole: "function"
                    label: "F5"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F6
                    keyRole: "function"
                    label: "F6"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F7
                    keyRole: "function"
                    label: "F7"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F8
                    keyRole: "function"
                    label: "F8"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F9
                    keyRole: "function"
                    label: "F9"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F10
                    keyRole: "function"
                    label: "F10"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F11
                    keyRole: "function"
                    label: "F11"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_F12
                    keyRole: "function"
                    label: "F12"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Insert
                    keyRole: "function"
                    label: "Ins"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Delete
                    keyRole: "function"
                    label: "Del"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Home
                    keyRole: "function"
                    label: "Home"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_End
                    keyRole: "function"
                    label: "End"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_PageUp
                    keyRole: "function"
                    label: "PgUp"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_PageDown
                    keyRole: "function"
                    label: "PgDn"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Print
                    keyRole: "function"
                    label: "PrtSc"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_ScrollLock
                    keyRole: "function"
                    label: "ScrLk"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Pause
                    keyRole: "function"
                    label: "Pause"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Menu
                    keyRole: "function"
                    label: "Menu"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x60
                    baseText: "`"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x7e
                    baseText: "~"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x21
                    baseText: "!"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x40
                    baseText: "@"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x23
                    baseText: "#"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x24
                    baseText: "$"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x25
                    baseText: "%"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x5e
                    baseText: "^"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x26
                    baseText: "&"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2a
                    baseText: "*"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x28
                    baseText: "("
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x29
                    baseText: ")"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x5f
                    baseText: "_"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2b
                    baseText: "+"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Backspace
                    keyRole: "function"
                    label: "⌫"
                    repeat: true
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x7b
                    baseText: "{"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x7d
                    baseText: "}"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x5b
                    baseText: "["
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x5d
                    baseText: "]"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x3c
                    baseText: "<"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x3e
                    baseText: ">"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x3b
                    baseText: ";"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x3a
                    baseText: ":"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x27
                    baseText: "'"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x22
                    baseText: "\""
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2c
                    baseText: ","
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2e
                    baseText: "."
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2f
                    baseText: "/"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x3f
                    baseText: "?"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x5c
                    baseText: "\\"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xa7
                    baseText: "§"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xb1
                    baseText: "±"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xd7
                    baseText: "×"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xf7
                    baseText: "÷"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xb0
                    baseText: "°"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x20ac
                    baseText: "€"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xa3
                    baseText: "£"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xa5
                    baseText: "¥"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xa2
                    baseText: "¢"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xa9
                    baseText: "©"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0xae
                    baseText: "®"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2122
                    baseText: "™"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2022
                    baseText: "•"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 0x2026
                    baseText: "…"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_unknown
                    keyRole: "page"
                    pageNumber: 1
                    label: "ABC"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_Control
                    keyRole: "ctrl"
                    label: "Ctrl"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.25
                    keyCode: Qt.Key_Alt
                    keyRole: "alt"
                    label: "Alt"
                }
                ChangeLanguageKey {
                    weight: 1.25
                }
                FullKey {
                    layoutRoot: root
                    weight: 3.0
                    keyCode: Qt.Key_Space
                    keyRole: "function"
                    label: "Space"
                    baseText: " "
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.25
                    keyCode: Qt.Key_AltGr
                    keyRole: "altgr"
                    label: "AltGr"
                }
                FullKey {
                    layoutRoot: root
                    weight: 2.25
                    keyCode: Qt.Key_Return
                    keyRole: "function"
                    label: "Enter"
                    baseText: "\n"
                }
                HideKeyboardKey {
                    weight: 1
                }
            }
        }
    }
}
