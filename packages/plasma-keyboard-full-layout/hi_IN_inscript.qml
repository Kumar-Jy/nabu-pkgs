// Full-size hi_IN_inscript layout for Plasma Keyboard.
//
// Installed in /usr/local/share/plasma/keyboard/layouts/hi_IN_inscript/.
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
                    baseText: "१"
                    shiftedText: "1"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "२"
                    shiftedText: "2"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "३"
                    shiftedText: "3"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "४"
                    shiftedText: "4"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "५"
                    shiftedText: "5"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "६"
                    shiftedText: "6"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "७"
                    shiftedText: "7"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "८"
                    shiftedText: "8"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "९"
                    shiftedText: "9"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "०"
                    shiftedText: "0"
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
                    baseText: "ौ"
                    shiftedText: "औ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ै"
                    shiftedText: "ऐ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ा"
                    shiftedText: "आ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ी"
                    shiftedText: "ई"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ू"
                    shiftedText: "ऊ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ब"
                    shiftedText: "भ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ह"
                    shiftedText: "ङ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ग"
                    shiftedText: "घ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "द"
                    shiftedText: "ध"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ज"
                    shiftedText: "झ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ड़"
                    shiftedText: "ढ़"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "़"
                    shiftedText: "ञ"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ो"
                    shiftedText: "ओ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "े"
                    shiftedText: "ए"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "्"
                    shiftedText: "अ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ि"
                    shiftedText: "इ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ु"
                    shiftedText: "उ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "प"
                    shiftedText: "फ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "र"
                    shiftedText: "ऱ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "क"
                    shiftedText: "ख"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "त"
                    shiftedText: "थ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "च"
                    shiftedText: "छ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ट"
                    shiftedText: "ठ"
                }
            }

            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ॉ"
                    shiftedText: "ऑ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ं"
                    shiftedText: "ँ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "म"
                    shiftedText: "ण"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "न"
                    shiftedText: "ऩ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "व"
                    shiftedText: "ऴ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ल"
                    shiftedText: "ळ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "स"
                    shiftedText: "श"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: ","
                    shiftedText: "ष"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "."
                    shiftedText: "।"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "य"
                    shiftedText: "?"
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
                    baseText: "क़"
                    shiftedText: "क़"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ख़"
                    shiftedText: "ख़"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ग़"
                    shiftedText: "ग़"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "य़"
                    shiftedText: "य़"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ऋ"
                    shiftedText: "ॠ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ृ"
                    shiftedText: "ॄ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "ॐ"
                    shiftedText: "ऍ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "्"
                    shiftedText: "ऽ"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    baseText: "।"
                    shiftedText: "॥"
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
