pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

// Key names as the keyboard in front of the person actually prints them.
//
// A binding has one spelling in code and another on the keycap. Qt takes
// "Ctrl+K" on every platform and maps Ctrl to Command on macOS, so the
// application is right to declare it that way — but a Mac user reads that
// binding as ⌘K, and their keyboard has no key labelled Ctrl in that position.
// Printing the Qt spelling there names a key they do not have.
//
//   KeyLabels.key("Ctrl")        → "Ctrl"    ·  "⌘"  on macOS
//   KeyLabels.sequence("Ctrl+K") → "Ctrl+K"  ·  "⌘K" on macOS
//
// Anything the map does not know is returned unchanged, so a label already
// written as a glyph — or a key with no macOS convention behind it — passes
// straight through and can never be mangled by running it through twice.
QtObject {
    id: root

    // Bound to the platform, but left writable on purpose: a demo, a
    // screenshot harness or a test needs to render the other platform's
    // labels on this one.
    property bool mac: Qt.platform.os === "osx"

    // Only what a Mac keyboard and the macOS menu bar genuinely print. Esc,
    // the function keys and the letters stay as they are — a Mac keycap says
    // "esc", not "⎋", and inventing glyphs for keys that have none would make
    // the shortcut harder to read rather than more native.
    readonly property var _mac: ({
        "ctrl":      "⌘",  // Qt maps Ctrl to Command…
        "control":   "⌘",
        "cmd":       "⌘",
        "command":   "⌘",
        "meta":      "⌃",  // …and Meta to the physical Control key
        "alt":       "⌥",
        "option":    "⌥",
        "opt":       "⌥",
        "shift":     "⇧",
        "enter":     "↩",
        "return":    "↩",
        "tab":       "⇥",
        "backspace": "⌫",
        "delete":    "⌦",
        "del":       "⌦",
        "up":        "↑",
        "down":      "↓",
        "left":      "←",
        "right":     "→"
    })

    // One key: "Ctrl" → "⌘" on macOS, unchanged everywhere else.
    function key(name: string): string {
        if (!root.mac || name === undefined || name === null)
            return name
        const hit = root._mac[String(name).trim().toLowerCase()]
        return hit !== undefined ? hit : name
    }

    // A whole binding: "Ctrl+Shift+K" → "⌘⇧K". macOS writes the modifiers
    // butted together with no separator, which is why the join differs too.
    function sequence(seq: string): string {
        if (seq === undefined || seq === null || seq === "")
            return seq
        const parts = String(seq).split("+").map(p => root.key(p.trim()))
        return parts.join(root.mac ? "" : "+")
    }
}
