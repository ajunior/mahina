pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// IRC message pane — flat, monospaced, selectable log of channel traffic.
//
// Renders classic IRC line formats ("[12:04] <nick> text") rather than chat
// bubbles, and understands mIRC control codes, per-nick colouring, highlights
// and clickable URLs.
//
// Usage:
//   IrcTextView {
//       selfNick: "alice"
//       lines: [
//           { kind: "message", time: "12:04", nick: "bob",   text: "morning all" },
//           { kind: "action",  time: "12:04", nick: "carol", text: "waves" },
//           { kind: "join",    time: "12:05", nick: "dave",  text: "has joined #qt" },
//       ]
//       onLinkClicked: (url) => Qt.openUrlExternally(url)
//   }
//
// Each entry: { kind, text, time?, nick?, prefix? }
//   kind:   "message" | "action" | "notice" | "join" | "part" | "quit" |
//           "mode" | "topic" | "kick" | "nick" | "error" | "self"
//   prefix: channel status prefix shown before the nick (e.g. "@", "+")
//
// Lines are held in a ring buffer capped at maxLines: the whole buffer is one
// TextEdit document, which is what makes cross-line selection and copy work.
// Keep maxLines bounded — this pane is not virtualised.
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    lines:           []
    property string selfNick:        ""
    property var    highlightWords:  []      // extra words that trigger a highlight
    property bool   showTimestamps:  true
    property bool   colorNicks:      true
    property bool   parseFormatting: true    // honour mIRC \x03, \x02, \x1F … codes
    property bool   linkifyUrls:     true
    property bool   hangingIndent:   true    // wrap continuation lines under the text
    property int    maxLines:        2000
    property int    markerIndex:     -1      // draw an unread marker before this line
    property color  backgroundColor: Theme.surface
    property bool   copyOnSelect:    false   // mIRC-style: selecting text copies it

    signal linkClicked(string url)
    signal nickClicked(string nick)
    signal textCopied(string text)

    implicitWidth:  520
    implicitHeight: 360

    // ── Public methods ───────────────────────────────────────────────────────

    // Append one entry and scroll if the view was already at the bottom.
    function appendLine(entry) {
        var wasAtBottom = root._atBottom
        var next = root.lines.slice()
        next.push(entry)
        if (next.length > root.maxLines) {
            var drop = next.length - root.maxLines
            next = next.slice(drop)
            if (root.markerIndex >= 0)
                root.markerIndex = Math.max(-1, root.markerIndex - drop)
        }
        root.lines = next
        if (wasAtBottom) Qt.callLater(root.scrollToBottom)
    }

    function clear() {
        root.lines = []
        root.markerIndex = -1
    }

    function scrollToBottom() {
        _flick.contentY = Math.max(0, _flick.contentHeight - _flick.height)
    }

    // Mark the current end of the buffer as "read up to here".
    function markUnreadHere() {
        root.markerIndex = root.lines.length
    }

    // ── Internals ────────────────────────────────────────────────────────────

    readonly property bool _atBottom:
        _flick.contentHeight <= _flick.height ||
        _flick.contentY >= _flick.contentHeight - _flick.height - 4

    // Monospace advance width — lets the hanging indent be computed from the
    // exact character count of each line's prefix, so wrapped text aligns
    // under the message body rather than at a fixed offset.
    FontMetrics {
        id: _fm
        font.family:    Theme.fontFamilyMono
        font.pixelSize: Theme.textSm
    }

    // Characters consumed by the "[time] <nick> " prefix of a given entry.
    function _prefixChars(entry, kind) {
        var n = 0
        if (root.showTimestamps && (entry.time ?? "") !== "")
            n += String(entry.time).length + 1
        var nick = String(entry.nick ?? "")
        if (root._isEvent(kind))
            n += 2 + (nick !== "" ? nick.length + 1 : 0)   // glyph + space
        else if (kind === "action")
            n += 2 + nick.length + 1                        // "* nick "
        else if (kind === "notice")
            n += nick.length + 3                            // "-nick- "
        else if (kind === "error")
            n += 0
        else
            n += String(entry.prefix ?? "").length + nick.length + 3  // "<@nick> "
        return n
    }

    // Colour tables and the nick-hash live in IrcPalette so this pane and
    // IrcNickList always agree on a given nick's colour.
    function _nickColor(nick) {
        if (!root.colorNicks || nick === "") return Theme.textPrimary
        return IrcPalette.nickColor(nick)
    }

    function _kindColor(kind) {
        switch (kind) {
            case "join":   return Theme.success
            case "part":
            case "quit":
            case "kick":   return Theme.textDisabled
            case "mode":
            case "nick":
            case "topic":  return Theme.info
            case "notice": return Theme.warning
            case "error":  return Theme.error
            case "action": return Theme.textPrimary
            default:       return Theme.textPrimary
        }
    }

    function _isEvent(kind) {
        return kind === "join" || kind === "part" || kind === "quit" ||
               kind === "mode" || kind === "topic" || kind === "kick" ||
               kind === "nick"
    }

    // Escape first, always — IRC text is untrusted and this document is
    // rendered as rich text. Nothing may reach the TextEdit unescaped.
    function _esc(s) {
        return String(s === undefined || s === null ? "" : s)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
    }

    // Preserve runs of whitespace (ASCII art, aligned tables) after escaping.
    function _preserveSpaces(s) {
        return s.replace(/ {2,}/g, function(run) {
            return Array(run.length + 1).join("&nbsp;")
        })
    }

    function _linkify(s) {
        if (!root.linkifyUrls) return s
        // Runs on already-escaped text, so no raw < > can appear in a match.
        return s.replace(/((?:https?:\/\/|www\.)[^\s<>"]+)/g, function(m) {
            var href = m.indexOf("www.") === 0 ? "http://" + m : m
            return '<a href="' + href + '" style="color:' + Theme.primary +
                   '; text-decoration:underline">' + m + '</a>'
        })
    }

    // Translate mIRC control codes into styled spans.
    // \x02 bold  \x1D italic  \x1F underline  \x1E strike  \x16 reverse
    // \x03 colour (fg[,bg])   \x0F reset
    function _formatCodes(raw) {
        if (!root.parseFormatting)
            return root._linkify(root._preserveSpaces(root._esc(raw)))

        var out      = ""
        var buf      = ""
        var bold     = false
        var italic   = false
        var under    = false
        var strike   = false
        var reverse  = false
        var fg       = -1
        var bg       = -1

        function styleAttr() {
            var css = []
            var f = fg, b = bg
            if (reverse) { f = (bg >= 0 ? bg : 99); b = (fg >= 0 ? fg : 99) }
            if (f >= 0 && f <= 98) css.push("color:" + IrcPalette.mircColors[f])
            if (b >= 0 && b <= 98) css.push("background-color:" + IrcPalette.mircColors[b])
            if (bold)   css.push("font-weight:700")
            if (italic) css.push("font-style:italic")
            if (under && strike) css.push("text-decoration:underline line-through")
            else if (under)      css.push("text-decoration:underline")
            else if (strike)     css.push("text-decoration:line-through")
            return css.join("; ")
        }

        function flush() {
            if (buf === "") return
            var body = root._linkify(root._preserveSpaces(root._esc(buf)))
            var css  = styleAttr()
            out += css === "" ? body : '<span style="' + css + '">' + body + "</span>"
            buf = ""
        }

        var i = 0
        while (i < raw.length) {
            var c = raw.charAt(i)
            var code = raw.charCodeAt(i)

            if (code === 0x02)      { flush(); bold    = !bold;    i++ }
            else if (code === 0x1D) { flush(); italic  = !italic;  i++ }
            else if (code === 0x1F) { flush(); under   = !under;   i++ }
            else if (code === 0x1E) { flush(); strike  = !strike;  i++ }
            else if (code === 0x16) { flush(); reverse = !reverse; i++ }
            else if (code === 0x0F) {
                flush()
                bold = italic = under = strike = reverse = false
                fg = bg = -1
                i++
            }
            else if (code === 0x03) {
                flush()
                i++
                var m = raw.substring(i).match(/^(\d{1,2})(?:,(\d{1,2}))?/)
                if (m) {
                    fg = parseInt(m[1], 10)
                    bg = m[2] !== undefined ? parseInt(m[2], 10) : -1
                    i += m[0].length
                } else {
                    fg = -1; bg = -1   // bare \x03 clears colour
                }
            }
            else { buf += c; i++ }
        }
        flush()
        return out
    }

    // Render one entry as a rich-text block.
    function _renderLine(entry, idx) {
        var kind = String(entry.kind ?? "message")
        var nick = String(entry.nick ?? "")
        var text = String(entry.text ?? "")

        var isSelf = kind === "self" ||
                     (root.selfNick !== "" && nick.toLowerCase() === root.selfNick.toLowerCase())
        var hit = root._isHighlight(text, kind, isSelf)

        var ind = root.hangingIndent
                  ? Math.round(root._prefixChars(entry, kind) * _fm.advanceWidth("0"))
                  : 0

        var block = "margin:0; " +
                    (ind > 0
                        ? "margin-left:" + ind + "px; text-indent:-" + ind + "px; "
                        : "") +
                    (hit ? "background-color:" + root._highlightBg() + "; " : "")

        var html = '<div style="' + block + '">'

        if (root.showTimestamps && (entry.time ?? "") !== "")
            html += '<span style="color:' + Theme.textDisabled + '">' +
                    root._esc(entry.time) + "</span> "

        if (root._isEvent(kind)) {
            var ec = root._kindColor(kind)
            html += '<span style="color:' + ec + '">' + root._eventGlyph(kind) + " </span>"
            if (nick !== "")
                html += '<span style="color:' + root._nickColor(nick) + '">' +
                        root._esc(nick) + "</span> "
            html += '<span style="color:' + ec + '">' + root._formatCodes(text) + "</span>"
        } else if (kind === "action") {
            html += '<span style="color:' + Theme.textSecondary + '">* </span>'
            html += '<span style="color:' + root._nickColor(nick) + '">' +
                    root._esc(nick) + "</span> "
            html += '<span style="color:' + Theme.textPrimary + '; font-style:italic">' +
                    root._formatCodes(text) + "</span>"
        } else if (kind === "notice") {
            html += '<span style="color:' + Theme.warning + '">-' + root._esc(nick) + "- </span>"
            html += '<span style="color:' + Theme.warning + '">' + root._formatCodes(text) + "</span>"
        } else if (kind === "error") {
            html += '<span style="color:' + Theme.error + '">' + root._formatCodes(text) + "</span>"
        } else {
            var pfx = String(entry.prefix ?? "")
            html += '<span style="color:' + Theme.textSecondary + '">&lt;</span>'
            if (pfx !== "")
                html += '<span style="color:' + Theme.success + '">' + root._esc(pfx) + "</span>"
            html += '<span style="color:' + root._nickColor(nick) + '; font-weight:' +
                    (isSelf ? "700" : "400") + '">' + root._esc(nick) + "</span>"
            html += '<span style="color:' + Theme.textSecondary + '">&gt;</span> '
            html += '<span style="color:' + Theme.textPrimary + '">' +
                    root._formatCodes(text) + "</span>"
        }

        html += "</div>"

        if (idx === root.markerIndex)
            html = root._markerBlock() + html

        return html
    }

    function _eventGlyph(kind) {
        switch (kind) {
            case "join": return "&#8594;"   // →
            case "part":
            case "quit": return "&#8592;"   // ←
            case "kick": return "&#10007;"  // ✗
            default:     return "&#8226;"   // •
        }
    }

    function _markerBlock() {
        return '<div style="margin:0; color:' + Theme.error + '">' +
               "&#8212;&#8212;&#8212; new messages &#8212;&#8212;&#8212;</div>"
    }

    function _highlightBg() {
        var c = Qt.color(Theme.warning)
        return Qt.rgba(c.r, c.g, c.b, Theme.dark ? 0.18 : 0.14)
    }

    function _isHighlight(text, kind, isSelf) {
        if (isSelf || root._isEvent(kind)) return false
        var lower = text.toLowerCase()
        if (root.selfNick !== "" && lower.indexOf(root.selfNick.toLowerCase()) !== -1)
            return true
        for (var i = 0; i < root.highlightWords.length; i++) {
            var w = String(root.highlightWords[i]).toLowerCase()
            if (w !== "" && lower.indexOf(w) !== -1) return true
        }
        return false
    }

    // Whole-document rebuild. Cheap enough at maxLines ≈ 2000; if you push it
    // much higher, cache per-line HTML instead of re-rendering the buffer.
    readonly property string _document: {
        var parts = []
        for (var i = 0; i < root.lines.length; i++)
            parts.push(root._renderLine(root.lines[i], i))
        return parts.join("")
    }

    // ── View ─────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        root.backgroundColor
        border.color: Theme.border
        border.width: 1
        clip:         true

        Flickable {
            id:              _flick
            anchors.fill:    parent
            anchors.margins: 1
            contentWidth:    width
            contentHeight:   _edit.implicitHeight
            boundsBehavior:  Flickable.StopAtBounds
            clip:            true

            QQC.ScrollBar.vertical: QQC.ScrollBar {
                policy:      QQC.ScrollBar.AsNeeded
                contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
                background:  Rectangle { color: "transparent" }
            }

            TextEdit {
                id:    _edit
                width: _flick.width - Theme.sp4
                x:     Theme.sp2
                y:     Theme.sp2

                text:           root._document
                textFormat:     TextEdit.RichText
                readOnly:       true
                selectByMouse:  true
                selectByKeyboard: true
                wrapMode:       TextEdit.Wrap
                activeFocusOnPress: true

                color:            Theme.textPrimary
                selectionColor:   Theme.primary
                selectedTextColor: Theme.textOnPrimary
                font.family:      Theme.fontFamilyMono
                font.pixelSize:   Theme.textSm

                onLinkActivated: (link) => root.linkClicked(link)

                // Copy-on-select (mIRC): copy the current selection to the
                // clipboard shortly after it stops changing, so a drag-select
                // finalises to the clipboard without spamming clipboard history.
                onSelectedTextChanged: {
                    if (root.copyOnSelect && _edit.selectedText.length > 0)
                        _copyOnSelectTimer.restart()
                }

                Timer {
                    id:       _copyOnSelectTimer
                    interval: 150
                    onTriggered: {
                        if (_edit.selectedText.length > 0) {
                            _edit.copy()
                            root.textCopied(_edit.selectedText)
                        }
                    }
                }

                // Hand cursor over links; IRC panes are read-only so no I-beam
                // override is needed elsewhere.
                MouseArea {
                    anchors.fill:     parent
                    acceptedButtons:  Qt.NoButton
                    cursorShape:      _edit.hoveredLink !== ""
                                      ? Qt.PointingHandCursor : Qt.IBeamCursor
                }
            }
        }

        // Jump-to-bottom affordance when scrolled back.
        Rectangle {
            visible: !root._atBottom
            anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }
            width:   _jumpTxt.implicitWidth + Theme.sp4
            height:  26
            radius:  Theme.radiusFull
            color:   Theme.primary

            Text {
                id:               _jumpTxt
                anchors.centerIn: parent
                text:             "Jump to latest"
                color:            Theme.textOnPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textXs
                font.weight:      Theme.weightMedium
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.scrollToBottom()
            }
        }
    }

    Component.onCompleted: Qt.callLater(root.scrollToBottom)
}
