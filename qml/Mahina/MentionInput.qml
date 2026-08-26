pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Textarea that detects @ and shows an autocomplete popup for mentions.
//
// Usage:
//   MentionInput {
//       suggestions: ["alice", "bob", "charlie", "david", "eve"]
//       placeholderText: "Write a message… type @ to mention"
//       onMentionInserted: (name) => console.log("mentioned:", name)
//   }
Item {
    id: root

    property string text:            ""
    property string placeholderText: "Type @ to mention someone…"
    property var    suggestions:     []
    property int    maxSuggestions:  6

    signal mentionInserted(string name)
    signal textEdited(string text)

    implicitWidth:  320
    implicitHeight: 100

    property string mentionQuery: ""
    property bool   mentionOpen:  false
    property int    mentionStart: -1
    property int    activeIdx:    0

    readonly property var filteredSuggestions: {
        var q = mentionQuery.toLowerCase()
        var r = []
        for (var i = 0; i < suggestions.length && r.length < maxSuggestions; i++) {
            if (suggestions[i].toLowerCase().indexOf(q) === 0) r.push(suggestions[i])
        }
        return r
    }

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.surface
        border.color: _area.activeFocus ? Theme.primary : Theme.border
        border.width: _area.activeFocus ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        TextEdit {
            id:             _area
            anchors { fill: parent; margins: Theme.sp3 }
            text:           root.text
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            wrapMode:       TextEdit.Wrap
            selectByMouse:  true

            Keys.onPressed: (event) => {
                if (!root.mentionOpen) return
                if (event.key === Qt.Key_Down) {
                    root.activeIdx = Math.min(root.filteredSuggestions.length - 1, root.activeIdx + 1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    root.activeIdx = Math.max(0, root.activeIdx - 1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Tab) {
                    if (root.filteredSuggestions.length > 0) {
                        root._insertMention(root.filteredSuggestions[root.activeIdx])
                        event.accepted = true
                    }
                } else if (event.key === Qt.Key_Escape) {
                    root.mentionOpen = false
                    event.accepted = true
                }
            }

            onTextChanged: {
                root.text = text
                root.textEdited(text)
                root._updateMentionState()
            }

            onCursorPositionChanged: root._updateMentionState()
        }

        Text {
            anchors { fill: parent; margins: Theme.sp3 }
            visible:        _area.text.length === 0
            text:           root.placeholderText
            color:          Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            wrapMode:       Text.WordWrap
        }
    }

    // Mention dropdown popup
    Rectangle {
        id:      _popup
        visible: root.mentionOpen && root.filteredSuggestions.length > 0
        z:       100
        anchors { left: parent.left; top: parent.bottom; topMargin: 4 }
        width:   200
        height:  Math.min(root.filteredSuggestions.length, root.maxSuggestions) * 36
        radius:  Theme.radiusMd
        color:   Theme.surface
        border.color: Theme.border; border.width: 1

        Column {
            anchors.fill: parent
            padding:      Theme.sp1

            Repeater {
                model: root.filteredSuggestions
                delegate: Rectangle {
                    id: _rq1
                    required property string modelData
                    required property int    index
                    width:  _popup.width - Theme.sp1 * 2
                    height: 36
                    radius: Theme.radiusSm
                    color:  index === root.activeIdx ? Theme.primary : _sugH.containsMouse ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _sugH }

                    Row {
                        anchors { fill: parent; leftMargin: Theme.sp3 }
                        spacing: Theme.sp2
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:  "@"
                            color: _rq1.index === root.activeIdx ? Theme.textOnPrimary : Theme.primary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:  _rq1.modelData
                            color: _rq1.index === root.activeIdx ? Theme.textOnPrimary : Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root._insertMention(_rq1.modelData)
                    }
                }
            }
        }
    }

    function _updateMentionState(): void {
        var t   = _area.text
        var pos = _area.cursorPosition
        // Walk back from cursor to find @ start
        var start = -1
        for (var i = pos - 1; i >= 0; i--) {
            var ch = t[i]
            if (ch === "@") { start = i; break }
            if (ch === " " || ch === "\n") break
        }
        if (start >= 0) {
            root.mentionStart = start
            root.mentionQuery = t.slice(start + 1, pos)
            root.mentionOpen  = true
            root.activeIdx    = 0
        } else {
            root.mentionOpen  = false
            root.mentionStart = -1
            root.mentionQuery = ""
        }
    }

    function _insertMention(name: var): void {
        var t   = _area.text
        var pos = _area.cursorPosition
        var before  = t.slice(0, root.mentionStart)
        var after   = t.slice(pos)
        var mention = "@" + name + " "
        _area.text  = before + mention + after
        _area.cursorPosition = before.length + mention.length
        root.mentionOpen = false
        root.mentionInserted(name)
    }
}
