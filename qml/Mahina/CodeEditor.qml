pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string code:            ""
    property bool   lineNumbers:     true
    property bool   readOnly:        false
    property int    tabWidth:        4
    property bool   insertSpacesForTab: true
    property string language:        ""
    property string fontFamily:      Theme.fontFamilyMono
    property int    fontSize:        Theme.textSm
    property int    fontWeight:      Font.Normal
    property color  backgroundColor:    Theme.surface
    property bool  highlightCurrentLine: false
    property real  lineHeight:           1.0

    // A frame of its own is right when this sits on a page by itself and
    // wrong inside a SplitPane, where the divider already draws that line:
    // the two together make a 2px seam sitting next to the 1px ones the rest
    // of the window uses. The host turns it off, and the seam then belongs to
    // whatever is between the panels rather than to the panels themselves.
    property bool   framed: true

    // Each entry: { line: <int>, icon: <Icons.*>, color: <color> }
    // Lines are 1-indexed. Only entries with a matching line are shown.
    property var lineDecorations: []

    // Expose the underlying TextEdit document so MahinaExtras.SyntaxHighlighter can attach.
    readonly property alias textDocument:    _edit.textDocument
    readonly property alias cursorPosition:  _edit.cursorPosition
    readonly property alias cursorRectangle: _edit.cursorRectangle
    readonly property alias selectedText:    _edit.selectedText
    readonly property alias selectionStart:  _edit.selectionStart

    // Set by QueryEditor when the completion popup is open so key events route there
    property bool completionActive: false

    signal completionMoveDown()
    signal completionMoveUp()
    signal completionAccept()
    signal completionDismiss()

    // Cursor bottom-left in CodeEditor coordinates (accounts for Flickable scroll)
    readonly property point cursorEditorPos: {
        const _sx = _codeFlick.contentX
        const _sy = _codeFlick.contentY
        const r = _edit.cursorRectangle
        return _edit.mapToItem(root, r.x, r.y + r.height)
    }

    function insertAtCursor(text: var): void {
        _edit.insert(_edit.cursorPosition, text)
        _edit.forceActiveFocus()
    }

    function replaceRange(from: var, to: var, text: var): void {
        _edit.remove(from, to)
        _edit.insert(from, text)
        _edit.cursorPosition = from + text.length
        _edit.forceActiveFocus()
    }

    // ── Find / Replace ────────────────────────────────────────────────────────
    property bool _findOpen:    false
    property bool _replaceMode: false
    property var  _matches:     []
    property int  _curIdx:      -1

    readonly property string _matchLabel: {
        if (!_findOpen || !_findField.text) return ""
        if (!_matches.length) return "No results"
        return (_curIdx + 1) + " of " + _matches.length
    }

    function openFind(): void {
        _replaceMode = false
        _findOpen    = true
        if (_edit.selectedText) _findField.text = _edit.selectedText
        _scanMatches()
        Qt.callLater(function() { _findField.forceActiveFocus(); _findField.selectAll() })
    }

    function openReplace(): void {
        _replaceMode = true
        _findOpen    = true
        if (_edit.selectedText) _findField.text = _edit.selectedText
        _scanMatches()
        Qt.callLater(function() { _findField.forceActiveFocus(); _findField.selectAll() })
    }

    function closeFind(): void {
        _findOpen = false
        _edit.deselect()
        _edit.forceActiveFocus()
    }

    function findNext(): void {
        if (!_matches.length) return
        _curIdx = (_curIdx + 1) % _matches.length
        _selectCurrent()
    }

    function findPrev(): void {
        if (!_matches.length) return
        _curIdx = (_curIdx - 1 + _matches.length) % _matches.length
        _selectCurrent()
    }

    function replaceCurrent(): void {
        if (_curIdx < 0 || _curIdx >= _matches.length) return
        var pos = _matches[_curIdx]
        replaceRange(pos, pos + _findField.text.length, _replaceField.text)
        _scanMatches()
    }

    function replaceAll(): void {
        var q = _findField.text
        if (!q) return
        _edit.text = _edit.text.split(q).join(_replaceField.text)
        _scanMatches()
    }

    function _scanMatches(): void {
        var arr = []
        var q   = _findField.text
        var t   = _edit.text
        if (q) {
            var i = 0
            while (true) {
                var p = t.indexOf(q, i)
                if (p === -1) break
                arr.push(p)
                i = p + 1
            }
        }
        _matches = arr
        if (arr.length > 0) {
            _curIdx = (_curIdx >= 0) ? Math.min(_curIdx, arr.length - 1) : 0
            _selectCurrent()
        } else {
            _curIdx = -1
            _edit.deselect()
        }
    }

    function _selectCurrent(): void {
        if (_curIdx < 0 || _curIdx >= _matches.length) return
        var pos = _matches[_curIdx]
        _edit.select(pos, pos + _findField.text.length)
        Qt.callLater(function() {
            var y  = _edit.cursorRectangle.y
            var ch = _codeFlick.height
            if (y < _codeFlick.contentY)
                _codeFlick.contentY = Math.max(0, y - ch * 0.25)
            else if (y + _edit.cursorRectangle.height > _codeFlick.contentY + ch)
                _codeFlick.contentY = y + _edit.cursorRectangle.height - ch * 0.75
        })
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    implicitWidth:  520
    implicitHeight: 320

    readonly property int _iconSlotW: lineDecorations.length > 0 ? 20 : 0
    readonly property int _gutterW:   (lineNumbers ? 48 : 0) + _iconSlotW

    readonly property var _decorationMap: {
        var m = {}
        for (var _i = 0; _i < lineDecorations.length; _i++) {
            var _d = lineDecorations[_i]
            m[_d.line] = _d
        }
        return m
    }

    Rectangle {
        anchors.fill: parent
        color:        root.backgroundColor
        border.color: Theme.border
        border.width: root.framed ? 1 : 0
        radius:       0
        clip:         true

        // Language badge
        Rectangle {
            visible: root.language !== ""
            anchors { top: parent.top; right: parent.right; margins: Theme.sp2 }
            width:  _langTxt.implicitWidth + 12; height: 20; radius: Theme.radiusSm
            color:  Theme.panel; border.color: Theme.border; border.width: 1
            Text {
                id: _langTxt
                anchors.centerIn: parent
                text:  root.language
                color: Theme.textDisabled
                font { family: Theme.fontFamilyMono; pixelSize: 10 }
            }
        }

        Row {
            anchors.fill: parent

            // ── Gutter ────────────────────────────────────────────────────────
            Rectangle {
                id:      _gutter
                visible: root.lineNumbers || root.lineDecorations.length > 0
                width:   root._gutterW
                height:  parent.height
                color:   Theme.panel
                Rectangle { width: 1; color: Theme.border; anchors { right: parent.right; top: parent.top; bottom: parent.bottom } }

                Flickable {
                    id:            _gutterFlick
                    anchors.fill:  parent
                    contentY:      _codeFlick.contentY
                    contentHeight: _codeFlick.contentHeight
                    interactive:   false
                    clip:          true

                    Column {
                        width:      parent.width
                        topPadding: Theme.sp3

                        Repeater {
                            model: _edit.lineCount
                            delegate: Item {
                                id:    _dRow
                                required property int index
                                width:  root._gutterW
                                height: _edit.cursorRectangle.height > 0 ? _edit.cursorRectangle.height : 20

                                // Decoration icon. A decoration carrying
                                // `spin: true` turns into a progress marker —
                                // the gutter is where the outcome of a line
                                // already shows, so it is where "still working"
                                // belongs too.
                                Icon {
                                    id: _dIcon
                                    readonly property var  dec:   root._decorationMap[_dRow.index + 1] || null
                                    readonly property bool spins: !!_dIcon.dec && _dIcon.dec.spin === true

                                    visible: root._iconSlotW > 0 && !!_dIcon.dec && !_dIcon.spins
                                    anchors { left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter }
                                    name:  (_dIcon.dec || {}).icon  || ""
                                    color: (_dIcon.dec || {}).color || Theme.textDisabled
                                    size:  13
                                }

                                // The spinning one is an icon of its own rather
                                // than a rotation applied to the one above. An
                                // animator writes the angle it stopped at back
                                // to the property, and it does so after any
                                // handler that reacts to it stopping — so the
                                // icon cannot be shared: the check mark that
                                // replaces the spinner would arrive frozen at
                                // 37°, which reads as a rendering fault rather
                                // than a result. Kept apart, that leftover
                                // angle lands on an item that is hidden by then.
                                Icon {
                                    id: _dSpin
                                    visible: root._iconSlotW > 0 && _dIcon.spins
                                    anchors { left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter }
                                    name:  (_dIcon.dec || {}).icon  || ""
                                    color: (_dIcon.dec || {}).color || Theme.textDisabled
                                    size:  13

                                    RotationAnimator on rotation {
                                        running:  _dSpin.visible
                                        from:     0
                                        to:       360
                                        duration: 800
                                        loops:    Animation.Infinite
                                    }
                                }

                                // Line number
                                Text {
                                    visible:             root.lineNumbers
                                    anchors {
                                        right:          parent.right
                                        rightMargin:    8
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width:               44
                                    horizontalAlignment: Text.AlignRight
                                    text:                (_dRow.index + 1).toString()
                                    color:               Theme.textDisabled
                                    font { family: root.fontFamily; pixelSize: root.fontSize }
                                }
                            }
                        }
                    }
                }
            }

            // ── Code area ─────────────────────────────────────────────────────
            Flickable {
                id:            _codeFlick
                width:         parent.width - root._gutterW
                height:        parent.height
                contentWidth:  _edit.contentWidth + Theme.sp6
                contentHeight: _edit.contentHeight + Theme.sp6
                clip:          true
                QQC.ScrollBar.vertical:   QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }
                QQC.ScrollBar.horizontal: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded; minimumSize: 0.05 }

                TextEdit {
                    id:            _edit
                    width:         Math.max(_codeFlick.width, _codeFlick.contentWidth)
                    padding:       Theme.sp3
                    text:          root.code
                    color:         Theme.textPrimary
                    font {
                        family:    root.fontFamily
                        pixelSize: root.fontSize
                        weight:    root.fontWeight
                    }
                    wrapMode:   TextEdit.NoWrap
                    readOnly:      root.readOnly
                    selectByMouse: true

                    onTextChanged: root.code = text

                    Keys.onPressed: (e) => {
                        if (root.completionActive) {
                            if (e.key === Qt.Key_Down)  { root.completionMoveDown(); e.accepted = true; return }
                            if (e.key === Qt.Key_Up)    { root.completionMoveUp();   e.accepted = true; return }
                            if (e.key === Qt.Key_Tab
                                    || ((e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
                                        && !(e.modifiers & Qt.ControlModifier))) {
                                root.completionAccept(); e.accepted = true; return
                            }
                            if (e.key === Qt.Key_Escape) { root.completionDismiss(); e.accepted = true; return }
                        }
                        if (e.key === Qt.Key_Tab) {
                            e.accepted = true
                            if (root.insertSpacesForTab) {
                                var spaces = ""
                                for (var i = 0; i < root.tabWidth; i++) spaces += " "
                                insert(cursorPosition, spaces)
                            } else {
                                insert(cursorPosition, "\t")
                            }
                            return
                        }
                        if (e.key === Qt.Key_F && (e.modifiers & Qt.ControlModifier)) {
                            root.openFind(); e.accepted = true; return
                        }
                        if (e.key === Qt.Key_H && (e.modifiers & Qt.ControlModifier)) {
                            root.openReplace(); e.accepted = true; return
                        }
                        if (e.key === Qt.Key_Escape && root._findOpen) {
                            root.closeFind(); e.accepted = true; return
                        }
                    }

                    // Cursor line highlight
                    Rectangle {
                        x:       0
                        y:       _edit.cursorRectangle.y
                        width:   parent.width
                        height:  _edit.cursorRectangle.height
                        color:   Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.06)
                        visible: _edit.activeFocus && root.highlightCurrentLine
                        z:       -1
                    }

                    Text {
                        visible: _edit.text === ""
                        text:    "// Start typing…"
                        color:   Theme.textDisabled
                        font:    _edit.font
                        x:       Theme.sp3; y: Theme.sp3
                    }
                }
            }
        }

        // ── Right-click menu ──────────────────────────────────────────────────
        // Anchored to the text rather than to the whole editor, so the gutter
        // stays free for whatever a host wants to put on a line number.
        ContextMenu {
            anchor: _edit
            menuWidth: 200

            // Right-clicking somewhere else and then choosing Paste has to
            // paste there, not wherever the caret happened to be left. A click
            // inside an existing selection keeps it: that is the one case where
            // the menu is about to act on the selection, not on the caret.
            onOpening: (x, y) => {
                const pos = _edit.positionAt(x, y)
                if (pos < _edit.selectionStart || pos > _edit.selectionEnd)
                    _edit.cursorPosition = pos
                _edit.forceActiveFocus()
            }

            model: [
                { label: "Undo", act: "undo",  icon: Icons.arrowCounterClockwise, shortcut: "Ctrl+Z",
                  disabled: root.readOnly || !_edit.canUndo },
                { label: "Redo", act: "redo",  icon: Icons.arrowClockwise, shortcut: "Ctrl+Shift+Z",
                  disabled: root.readOnly || !_edit.canRedo },
                null,
                { label: "Cut", act: "cut",   icon: Icons.scissors, shortcut: "Ctrl+X",
                  disabled: root.readOnly || _edit.selectedText === "" },
                { label: "Copy", act: "copy",  icon: Icons.copy, shortcut: "Ctrl+C",
                  disabled: _edit.selectedText === "" },
                { label: "Paste", act: "paste", icon: Icons.clipboard, shortcut: "Ctrl+V",
                  disabled: root.readOnly || !_edit.canPaste },
                null,
                { label: "Select all", act: "selectAll", icon: Icons.selectionAll, shortcut: "Ctrl+A",
                  disabled: _edit.text === "" },
            ]

            onTriggered: (index, item) => {
                switch (item.act) {
                case "undo":      _edit.undo();      break
                case "redo":      _edit.redo();      break
                case "cut":       _edit.cut();       break
                case "copy":      _edit.copy();      break
                case "paste":     _edit.paste();     break
                case "selectAll": _edit.selectAll(); break
                }
                _edit.forceActiveFocus()
            }
        }

        // ── Find / Replace bar ────────────────────────────────────────────────
        Rectangle {
            id:      _findBar
            visible: root._findOpen
            z:       10
            anchors { top: parent.top; right: parent.right; margins: Theme.sp2 }
            width:   340
            height:  _fbCol.implicitHeight + Theme.sp3 * 2
            color:   Theme.panel
            border.color: Theme.border
            border.width: 1
            radius:  Theme.radiusMd

            Column {
                id:      _fbCol
                width:   parent.width - Theme.sp3 * 2
                x:       Theme.sp3
                y:       Theme.sp3
                spacing: Theme.sp2

                // ── Find row ──────────────────────────────────────────────────
                Row {
                    width:   parent.width
                    height:  26
                    spacing: Theme.sp1

                    // Find input
                    Rectangle {
                        width:  parent.width - _matchLbl.width - _prevBtn.width - _nextBtn.width - _closeBtn.width - 4 * Theme.sp1
                        height: 26
                        radius: Theme.radiusSm
                        color:  Theme.surface
                        border.color: _findField.activeFocus ? Theme.primary : Theme.border
                        border.width: 1

                        TextInput {
                            id:             _findField
                            anchors {
                                left:           parent.left;  right:  parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin:     7;            rightMargin: 7
                            }
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            selectByMouse:  true
                            clip:           true
                            onTextChanged:  root._scanMatches()
                            Keys.onReturnPressed: (e) => {
                                if (e.modifiers & Qt.ShiftModifier) root.findPrev()
                                else root.findNext()
                                e.accepted = true
                            }
                            Keys.onUpPressed:     root.findPrev()
                            Keys.onDownPressed:   root.findNext()
                            Keys.onEscapePressed: root.closeFind()

                            Text {
                                visible:          !parent.text
                                text:             "Find"
                                color:            Theme.textDisabled
                                font:             parent.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Match count
                    Text {
                        id:                  _matchLbl
                        width:               62
                        anchors.verticalCenter: parent.verticalCenter
                        text:                root._matchLabel
                        color:               (root._matches.length || !_findField.text) ? Theme.textSecondary : Theme.error
                        font.family:         Theme.fontFamily
                        font.pixelSize:      Theme.textXs
                        horizontalAlignment: Text.AlignHCenter
                        elide:               Text.ElideRight
                    }

                    // Prev
                    Rectangle {
                        id:     _prevBtn
                        width:  22; height: 22
                        radius: Theme.radiusSm
                        color:  _pma.containsMouse ? Theme.surfaceVariant : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: Icons.arrowUp; size: 13; color: Theme.textSecondary; anchors.centerIn: parent }
                        MouseArea { id: _pma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.findPrev() }
                    }

                    // Next
                    Rectangle {
                        id:     _nextBtn
                        width:  22; height: 22
                        radius: Theme.radiusSm
                        color:  _nma.containsMouse ? Theme.surfaceVariant : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: Icons.arrowDown; size: 13; color: Theme.textSecondary; anchors.centerIn: parent }
                        MouseArea { id: _nma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.findNext() }
                    }

                    // Close
                    Rectangle {
                        id:     _closeBtn
                        width:  22; height: 22
                        radius: Theme.radiusSm
                        color:  _cma.containsMouse ? Theme.surfaceVariant : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: Icons.x; size: 13; color: Theme.textSecondary; anchors.centerIn: parent }
                        MouseArea { id: _cma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeFind() }
                    }
                }

                // ── Replace row ───────────────────────────────────────────────
                Row {
                    visible: root._replaceMode
                    width:   parent.width
                    height:  26
                    spacing: Theme.sp1

                    // Replace input
                    Rectangle {
                        width:  parent.width - _replBtn.width - _replAllBtn.width - 2 * Theme.sp1
                        height: 26
                        radius: Theme.radiusSm
                        color:  Theme.surface
                        border.color: _replaceField.activeFocus ? Theme.primary : Theme.border
                        border.width: 1

                        TextInput {
                            id:             _replaceField
                            anchors {
                                left:           parent.left;  right:  parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin:     7;            rightMargin: 7
                            }
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            selectByMouse:  true
                            clip:           true
                            Keys.onReturnPressed: root.replaceCurrent()
                            Keys.onEscapePressed: root.closeFind()

                            Text {
                                visible:          !parent.text
                                text:             "Replace"
                                color:            Theme.textDisabled
                                font:             parent.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Replace current
                    Rectangle {
                        id:     _replBtn
                        width:  _replTxt.implicitWidth + Theme.sp3 * 2
                        height: 22
                        radius: Theme.radiusSm
                        color:  _rma.containsMouse ? Theme.primaryHover : Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id:             _replTxt
                            anchors.centerIn: parent
                            text:           "Replace"
                            color:          Theme.textOnPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            font.weight:    Theme.weightMedium
                        }
                        MouseArea { id: _rma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.replaceCurrent() }
                    }

                    // Replace all
                    Rectangle {
                        id:     _replAllBtn
                        width:  _replAllTxt.implicitWidth + Theme.sp3 * 2
                        height: 22
                        radius: Theme.radiusSm
                        color:  Theme.surface
                        border.color: Theme.border; border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id:             _replAllTxt
                            anchors.centerIn: parent
                            text:           "All"
                            color:          Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            font.weight:    Theme.weightMedium
                        }
                        MouseArea { id: _rama; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.replaceAll() }
                    }
                }
            }
        }
    }
}
