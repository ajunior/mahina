pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// IRC input line — Tab-cycle nick completion, command completion and history.
//
// Usage:
//   IrcInput {
//       prompt:   "[alice]"
//       nicks:    ["alice", "bob", "carol"]
//       commands: ["/join", "/msg", "/part", "/quit"]
//       onSent: (line) => connection.send(line)
//   }
//
// Completion follows mIRC: Tab with no trigger character completes the token
// under the cursor, and repeated Tab cycles through matches in place.
// Shift+Tab cycles backwards. A token at the start of the line completes with
// nickSuffix (": ") appended; anywhere else, a plain space.
//
// Up/Down walk the send history. The half-typed line is preserved as a draft
// and restored when you come back down past the newest entry.
Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property alias  text:        _field.text
    property var    nicks:       []
    property var    commands:    []
    property string prompt:      ""
    property string placeholder: "Type a message…"
    property string nickSuffix:  ": "
    property int    historyLimit: 100
    property int    byteLimit:   450    // 0 disables the counter
    property bool   inputEnabled: true

    signal sent(string line)
    signal tabCompleted(string match)
    signal escapePressed()

    implicitWidth:  480
    implicitHeight: 34

    color:        Theme.surface
    border.color: _field.activeFocus ? Theme.primary : Theme.border
    border.width: 1
    radius:       Theme.radiusSm

    // ── Public methods ───────────────────────────────────────────────────────
    function focusInput() { _field.forceActiveFocus() }

    function clear() {
        root._applying = true
        _field.text = ""
        root._applying = false
        root._resetCompletion()
    }

    function insert(s) {
        _field.insert(_field.cursorPosition, s)
    }

    // ── History ──────────────────────────────────────────────────────────────
    property var    _history: []
    property int    _histIdx: -1     // -1 = editing the live draft
    property string _draft:   ""

    function _pushHistory(line) {
        if (line === "") return
        var h = root._history.slice()
        if (h.length > 0 && h[h.length - 1] === line) {
            // Consecutive duplicates aren't worth a slot.
        } else {
            h.push(line)
            if (h.length > root.historyLimit) h = h.slice(h.length - root.historyLimit)
        }
        root._history = h
        root._histIdx = -1
        root._draft   = ""
    }

    function _historyPrev() {
        if (root._history.length === 0) return
        if (root._histIdx === -1) {
            root._draft   = _field.text
            root._histIdx = root._history.length - 1
        } else if (root._histIdx > 0) {
            root._histIdx--
        } else {
            return
        }
        root._setText(root._history[root._histIdx])
    }

    function _historyNext() {
        if (root._histIdx === -1) return
        if (root._histIdx < root._history.length - 1) {
            root._histIdx++
            root._setText(root._history[root._histIdx])
        } else {
            root._histIdx = -1
            root._setText(root._draft)
        }
    }

    // ── Completion ───────────────────────────────────────────────────────────
    property bool _applying:    false   // suppresses the reset while we edit the field ourselves
    property bool _compActive:  false
    property int  _compStart:   0
    property int  _compEnd:     0
    property string _compBase:  ""
    property var  _compMatches: []
    property int  _compIndex:   0

    function _setText(s) {
        root._applying = true
        _field.text = s
        _field.cursorPosition = s.length
        root._applying = false
        root._resetCompletion()
    }

    function _resetCompletion() {
        root._compActive  = false
        root._compMatches = []
        root._compIndex   = 0
        root._compBase    = ""
    }

    // Start of the whitespace-delimited token containing pos.
    function _tokenStart(s, pos) {
        var i = pos
        while (i > 0 && s.charAt(i - 1) !== " ") i--
        return i
    }

    function _candidatesFor(base, atLineStart) {
        var isCommand = base.charAt(0) === "/"
        var pool = isCommand ? root.commands : root.nicks
        var lower = base.toLowerCase()
        var out = []
        for (var i = 0; i < pool.length; i++) {
            var cand = String(pool[i])
            if (cand.toLowerCase().indexOf(lower) === 0) out.push(cand)
        }
        out.sort(function(a, b) {
            var la = a.toLowerCase(), lb = b.toLowerCase()
            return la < lb ? -1 : (la > lb ? 1 : 0)
        })
        void atLineStart
        return out
    }

    function _applyCompletion() {
        if (root._compMatches.length === 0) return

        var match     = String(root._compMatches[root._compIndex])
        var isCommand = root._compBase.charAt(0) === "/"
        var suffix    = (!isCommand && root._compStart === 0) ? root.nickSuffix : " "
        var insertion = match + suffix

        var before = _field.text.substring(0, root._compStart)
        var after  = _field.text.substring(root._compEnd)

        root._applying = true
        _field.text = before + insertion + after
        _field.cursorPosition = root._compStart + insertion.length
        root._applying = false

        root._compEnd = root._compStart + insertion.length
        root.tabCompleted(match)
    }

    function _cycleCompletion(step) {
        if (!root._compActive) {
            var pos   = _field.cursorPosition
            var start = root._tokenStart(_field.text, pos)
            var base  = _field.text.substring(start, pos)
            if (base === "") return

            var matches = root._candidatesFor(base, start === 0)
            if (matches.length === 0) return

            root._compBase    = base
            root._compStart   = start
            root._compEnd     = pos
            root._compMatches = matches
            root._compIndex   = 0
            root._compActive  = true
        } else {
            var n = root._compMatches.length
            root._compIndex = ((root._compIndex + step) % n + n) % n
        }
        root._applyCompletion()
    }

    // ── Byte budget ──────────────────────────────────────────────────────────
    // IRC lines are capped in bytes, not characters, so non-ASCII counts more.
    function _utf8Length(s) {
        var n = 0
        for (var i = 0; i < s.length; i++) {
            var c = s.charCodeAt(i)
            if (c < 0x80) n += 1
            else if (c < 0x800) n += 2
            else if (c >= 0xD800 && c <= 0xDBFF) { n += 4; i++ }   // surrogate pair
            else n += 3
        }
        return n
    }

    readonly property int  _bytes:   root._utf8Length(_field.text)
    readonly property bool _showBudget: root.byteLimit > 0 && root._bytes > root.byteLimit * 0.8
    readonly property bool _overBudget: root.byteLimit > 0 && root._bytes > root.byteLimit

    // ── Layout ───────────────────────────────────────────────────────────────
    Row {
        anchors {
            left:           parent.left
            right:          parent.right
            verticalCenter: parent.verticalCenter
            leftMargin:     Theme.sp2
            rightMargin:    Theme.sp2
        }
        spacing: Theme.sp2

        Text {
            visible:        root.prompt !== ""
            anchors.verticalCenter: parent.verticalCenter
            text:           root.prompt
            color:          Theme.textSecondary
            font.family:    Theme.fontFamilyMono
            font.pixelSize: Theme.textSm
        }

        TextInput {
            id: _field
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width -
                   (root.prompt !== "" ? _promptMetrics.width + Theme.sp2 : 0) -
                   (root._showBudget ? _budget.width + Theme.sp2 : 0)

            enabled:        root.inputEnabled
            color:          Theme.textPrimary
            font.family:    Theme.fontFamilyMono
            font.pixelSize: Theme.textSm
            clip:           true
            selectByMouse:  true
            selectionColor: Theme.primary
            selectedTextColor: Theme.textOnPrimary

            Text {
                visible:        _field.text === ""
                text:           root.placeholder
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                anchors.verticalCenter: parent.verticalCenter
            }

            // Any edit the user makes invalidates an in-flight completion.
            onTextChanged:           if (!root._applying) root._resetCompletion()
            onCursorPositionChanged: if (!root._applying) root._resetCompletion()

            // BeforeItem so Tab reaches us instead of moving focus.
            Keys.priority: Keys.BeforeItem
            Keys.onPressed: (event) => {
                switch (event.key) {
                case Qt.Key_Tab:
                    root._cycleCompletion(1)
                    event.accepted = true
                    break
                case Qt.Key_Backtab:
                    root._cycleCompletion(-1)
                    event.accepted = true
                    break
                case Qt.Key_Up:
                    root._historyPrev()
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    root._historyNext()
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    var line = _field.text
                    if (line !== "") {
                        root.sent(line)
                        root._pushHistory(line)
                        root._applying = true
                        _field.text = ""
                        root._applying = false
                        root._resetCompletion()
                    }
                    event.accepted = true
                    break
                case Qt.Key_Escape:
                    if (root._compActive) root._resetCompletion()
                    else                  root.escapePressed()
                    event.accepted = true
                    break
                default:
                    break
                }
            }
        }

        // Remaining byte budget — appears only as you approach the line limit.
        Text {
            id:      _budget
            visible: root._showBudget
            anchors.verticalCenter: parent.verticalCenter
            text:    (root.byteLimit - root._bytes).toString()
            color:   root._overBudget ? Theme.error : Theme.warning
            font.family:    Theme.fontFamilyMono
            font.pixelSize: Theme.textXs
            font.weight:    Theme.weightMedium
        }
    }

    // Measures the prompt so the field can size around it.
    TextMetrics {
        id:   _promptMetrics
        text: root.prompt
        font.family:    Theme.fontFamilyMono
        font.pixelSize: Theme.textSm
    }
}
