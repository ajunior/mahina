pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Shared IRC colour and channel-mode helpers.
//
// Both IrcTextView and IrcNickList render nicks, so the colouring rule lives
// here — a nick must get the same colour in the message pane and the user
// list, or the two panes look unrelated.
QtObject {
    id: root

    // ── mIRC colour codes ────────────────────────────────────────────────────
    // Index 0–15 classic, 16–98 extended, 99 = "default" (no colour).
    readonly property var mircColors: [
        "#FFFFFF","#000000","#00007F","#009300","#FF0000","#7F0000","#9C009C","#FC7F00",
        "#FFFF00","#00FC00","#009393","#00FFFF","#0000FC","#FF00FF","#7F7F7F","#D2D2D2",
        "#470000","#472100","#474700","#324700","#004700","#00472C","#004747","#002747",
        "#000047","#2E0047","#470047","#47002A","#740000","#743A00","#747400","#517400",
        "#007400","#007449","#007474","#004074","#000074","#4B0074","#740074","#740045",
        "#B50000","#B56300","#B5B500","#7DB500","#00B500","#00B571","#00B5B5","#0063B5",
        "#0000B5","#7500B5","#B500B5","#B5006B","#FF0000","#FF8C00","#FFFF00","#B2FF00",
        "#00FF00","#00FFA0","#00FFFF","#008CFF","#0000FF","#A500FF","#FF00FF","#FF0098",
        "#FF5959","#FFB459","#FFFF71","#CFFF60","#6FFF6F","#65FFC9","#6DFFFF","#59B4FF",
        "#5959FF","#C459FF","#FF66FF","#FF59BC","#FF9C9C","#FFD39C","#FFFF9C","#E2FF9C",
        "#9CFF9C","#9CFFDB","#9CFFFF","#9CD3FF","#9C9CFF","#DC9CFF","#FF9CFF","#FF94D3",
        "#000000","#131313","#282828","#363636","#4D4D4D","#656565","#818181","#9F9F9F",
        "#BCBCBC","#E2E2E2","#FFFFFF"
    ]

    // ── Per-nick colouring ───────────────────────────────────────────────────
    readonly property var nickPaletteLight: [
        "#B5341C","#1F6F3F","#1B5FA8","#8A3FA0","#A0641B","#0F6E70",
        "#8C2F5E","#3B5FB5","#6B6F1B","#2F7A55","#94381F","#4A4FA8"
    ]
    readonly property var nickPaletteDark: [
        "#F08A70","#7FD495","#77B6F5","#D79CE8","#EBB56A","#6FD4D6",
        "#EE93BC","#94A8F2","#CBD26F","#82DDB0","#F0997F","#A3A6F0"
    ]

    // Deterministic: the same nick always maps to the same palette slot, so
    // colours stay stable across reconnects and between panes.
    function nickColor(nick: var): var {
        var s = String(nick ?? "")
        if (s === "") return Theme.textPrimary
        var pal = Theme.dark ? root.nickPaletteDark : root.nickPaletteLight
        var h = 0
        var lower = s.toLowerCase()
        for (var i = 0; i < lower.length; i++)
            h = (h * 31 + lower.charCodeAt(i)) >>> 0
        return pal[h % pal.length]
    }

    // ── Channel status modes ─────────────────────────────────────────────────
    // Conventional prefix order: owner, admin, op, halfop, voice, none.
    readonly property var modePrefixes: ["~", "&", "@", "%", "+"]

    function modeRank(mode: var): var {
        var i = root.modePrefixes.indexOf(String(mode ?? ""))
        return i === -1 ? root.modePrefixes.length : i
    }

    function modeColor(mode: var): var {
        switch (String(mode ?? "")) {
            case "~": return Theme.error      // owner
            case "&": return Theme.warning    // admin
            case "@": return Theme.success    // op
            case "%": return Theme.info       // halfop
            case "+": return Theme.primary    // voice
            default:  return Theme.textDisabled
        }
    }

    function modeLabel(mode: var): var {
        switch (String(mode ?? "")) {
            case "~": return "Owners"
            case "&": return "Admins"
            case "@": return "Operators"
            case "%": return "Half-ops"
            case "+": return "Voiced"
            default:  return "Users"
        }
    }
}
