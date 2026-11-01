// Full-size uk_UA layout for Plasma Keyboard.
//
// Loaded from the Plasma Keyboard layouts directory (this is the uk_UA layout).
// FullKey.qml next to this file implements the key behaviour (sticky
// Ctrl/Alt/Super/AltGr, Shift/Caps Lock, shifted symbols, page switching).
//
// The keyboard has two pages so that the keys can be larger:
//   page 1 - normal typing (Q/W/E/R/T/Y ...)
//   page 2 - function keys, navigation and symbols
//
// Modifier keys are one-shot/toggle keys: tap Ctrl, then tap C to send Ctrl+C.
// Ctrl, Alt, Super and AltGr clear after the next key. Shift is cleared after
// the next character. Caps Lock stays on until you tap it again.

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
                    keyCode: Qt.Key_QuoteLeft
                    baseText: "`"
                    shiftedText: "~"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_1
                    baseText: "1"
                    shiftedText: "!"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_2
                    baseText: "2"
                    shiftedText: "@"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_3
                    baseText: "3"
                    shiftedText: "#"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_4
                    baseText: "4"
                    shiftedText: "$"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_5
                    baseText: "5"
                    shiftedText: "%"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_6
                    baseText: "6"
                    shiftedText: "^"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_7
                    baseText: "7"
                    shiftedText: "&"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_8
                    baseText: "8"
                    shiftedText: "*"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_9
                    baseText: "9"
                    shiftedText: "("
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_0
                    baseText: "0"
                    shiftedText: ")"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Minus
                    baseText: "-"
                    shiftedText: "_"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Equal
                    baseText: "="
                    shiftedText: "+"
                }
                FullKey {
                    layoutRoot: root
                    weight: 2
                    keyCode: Qt.Key_Backspace
                    keyRole: "function"
                    label: "⌫"
                    repeat: true
                }
            }
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_Tab
                    keyRole: "function"
                    label: "Tab"
                    baseText: "\\t"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1044
                    baseText: "д"
                    shiftedText: "Д"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1061
                    baseText: "ф"
                    shiftedText: "Ф"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1043
                    baseText: "г"
                    shiftedText: "Г"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1045
                    baseText: "е"
                    shiftedText: "Е"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1065
                    baseText: "ш"
                    shiftedText: "Ш"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_BracketLeft
                    baseText: "["
                    shiftedText: "{"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_BracketRight
                    baseText: "]"
                    shiftedText: "}"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Backslash
                    baseText: "\\"
                    shiftedText: "|"
                }
                FullKey {
                    layoutRoot: root
                    weight: 2.25
                    keyCode: Qt.Key_Return
                    keyRole: "function"
                    label: "Enter"
                    baseText: "
"
                }
            }
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 1.75
                    keyCode: Qt.Key_CapsLock
                    keyRole: "caps"
                    label: "Caps"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1040
                    baseText: "а"
                    shiftedText: "А"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1056
                    baseText: "п"
                    shiftedText: "П"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1057
                    baseText: "р"
                    shiftedText: "Р"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1058
                    baseText: "с"
                    shiftedText: "С"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1060
                    baseText: "у"
                    shiftedText: "У"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1062
                    baseText: "х"
                    shiftedText: "Х"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1063
                    baseText: "ц"
                    shiftedText: "Ц"
                }
                FullKey {
                    layoutRoot: root
                    weight: 2.25
                    keyCode: Qt.Key_Return
                    keyRole: "function"
                    label: "Enter"
                    baseText: "
"
                }
            }
            KeyboardRow {
                FullKey {
                    layoutRoot: root
                    weight: 2.25
                    keyCode: Qt.Key_Shift
                    keyRole: "shift"
                    label: "Shift"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1048
                    baseText: "з"
                    shiftedText: "З"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1041
                    baseText: "б"
                    shiftedText: "Б"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1059
                    baseText: "т"
                    shiftedText: "Т"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1043
                    baseText: "г"
                    shiftedText: "Г"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: 1071
                    baseText: "ю"
                    shiftedText: "Ю"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Comma
                    baseText: ","
                    shiftedText: "<"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Period
                    baseText: "."
                    shiftedText: ">"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1
                    keyCode: Qt.Key_Slash
                    baseText: "/"
                    shiftedText: "?"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.75
                    keyCode: Qt.Key_Shift
                    keyRole: "shift"
                    label: "Shift"
                }
                FullKey {
                    layoutRoot: root
                    weight: 1.5
                    keyCode: Qt.Key_unknown
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
                    keyCode: Qt.Key_Meta
                    keyRole: "super"
                    label: "Super"
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
                    weight: 1.5
                    keyCode: Qt.Key_Control
                    keyRole: "ctrl"
                    label: "Ctrl"
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
