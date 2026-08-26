pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// IRC channel user list — virtualised, mode-sorted roster for a channel.
//
// Usage:
//   IrcNickList {
//       selfNick: "alice"
//       nicks: [
//           { nick: "bob",   mode: "@" },
//           { nick: "carol", mode: "+" },
//           { nick: "dave",  away: true },
//       ]
//       onNickActivated: (n) => openQuery(n)
//       onNickRightClicked: (n, x, y) => userMenu.popup(x, y)
//   }
//
// Each entry: { nick, mode?, away?, ircop? }
//   mode: channel status prefix — "~" owner, "&" admin, "@" op, "%" halfop,
//         "+" voice, "" regular. Sorted by rank, then case-insensitively.
//
// Backed by a ListView, so it stays responsive with thousands of users on a
// large channel. Nick colours come from IrcPalette and match IrcTextView.
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    nicks:       []
    property string selfNick:    ""
    property bool   showFilter:  true
    property bool   showHeader:  true
    property bool   colorNicks:  true
    property bool   showModeIcon: true
    property string channelName: ""
    property int    rowHeight:   22
    property string selectedNick: ""

    signal nickClicked(string nick)
    signal nickActivated(string nick)                       // double-click — open a query
    signal nickRightClicked(string nick, real x, real y)    // position is in root coordinates

    implicitWidth:  180
    implicitHeight: 320

    // ── Public methods ───────────────────────────────────────────────────────
    function positionAtNick(nick: var): var {
        var lower = String(nick).toLowerCase()
        for (var i = 0; i < root._view.length; i++) {
            if (String(root._view[i].nick).toLowerCase() === lower) {
                _list.positionViewAtIndex(i, ListView.Contain)
                return true
            }
        }
        return false
    }

    // ── Internals ────────────────────────────────────────────────────────────
    property string _filter: ""

    // Sorted by mode rank, then case-insensitive nick — the conventional IRC
    // ordering, so ops float to the top.
    readonly property var _sorted: {
        var arr = root.nicks.slice()
        arr.sort(function(a, b) {
            var ra = IrcPalette.modeRank(a.mode ?? "")
            var rb = IrcPalette.modeRank(b.mode ?? "")
            if (ra !== rb) return ra - rb
            var na = String(a.nick ?? "").toLowerCase()
            var nb = String(b.nick ?? "").toLowerCase()
            return na < nb ? -1 : (na > nb ? 1 : 0)
        })
        return arr
    }

    readonly property var _view: {
        var f = root._filter.toLowerCase()
        if (f === "") return root._sorted
        return root._sorted.filter(function(e) {
            return String(e.nick ?? "").toLowerCase().indexOf(f) !== -1
        })
    }

    // Theme.primarySubtle is a fixed light value, so it can't be used as a
    // selection background — derive a tint from the primary hue instead, which
    // stays legible in both modes.
    readonly property color _selectionBg: {
        var c = Qt.color(Theme.primary)
        return Qt.rgba(c.r, c.g, c.b, Theme.dark ? 0.26 : 0.14)
    }

    // Per-mode tallies for the header, e.g. "128 users (@4 +9)".
    readonly property string _counts: {
        var total = root.nicks.length
        var byMode = ({})
        for (var i = 0; i < root.nicks.length; i++) {
            var m = String(root.nicks[i].mode ?? "")
            if (m !== "") byMode[m] = (byMode[m] ?? 0) + 1
        }
        var bits = []
        for (var k = 0; k < IrcPalette.modePrefixes.length; k++) {
            var p = IrcPalette.modePrefixes[k]
            if (byMode[p] !== undefined) bits.push(p + byMode[p])
        }
        return total + (total === 1 ? " user" : " users") +
               (bits.length > 0 ? " (" + bits.join(" ") + ")" : "")
    }

    // ── View ─────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.surface
        border.color: Theme.border
        border.width: 1
        clip:         true

        Column {
            anchors.fill:    parent
            anchors.margins: 1
            spacing:         0

            // Header — channel name and user tallies
            Item {
                visible: root.showHeader
                width:   parent.width
                height:  root.showHeader ? 34 : 0

                Column {
                    anchors {
                        left:        parent.left
                        right:       parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin:  Theme.sp3
                        rightMargin: Theme.sp3
                    }
                    spacing: 1

                    Text {
                        visible:        root.channelName !== ""
                        width:          parent.width
                        text:           root.channelName
                        color:          Theme.textPrimary
                        elide:          Text.ElideRight
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Theme.weightSemibold
                    }

                    Text {
                        width:          parent.width
                        text:           root._counts
                        color:          Theme.textSecondary
                        elide:          Text.ElideRight
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }
            }

            Rectangle {
                visible: root.showHeader
                width:   parent.width
                height:  root.showHeader ? 1 : 0
                color:   Theme.border
            }

            // Filter field
            Item {
                visible: root.showFilter
                width:   parent.width
                height:  root.showFilter ? 30 : 0

                Row {
                    anchors {
                        fill:        parent
                        leftMargin:  Theme.sp3
                        rightMargin: Theme.sp2
                    }
                    spacing: Theme.sp2

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name:  Icons.magnifyingGlass
                        size:  12
                        color: Theme.textDisabled
                    }

                    TextInput {
                        id:     _filterField
                        width:  parent.width - 34
                        anchors.verticalCenter: parent.verticalCenter
                        text:           root._filter
                        onTextChanged:  root._filter = text
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        clip:           true
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.textOnPrimary
                        selectByMouse:  true

                        Text {
                            visible:        _filterField.text === ""
                            text:           "Filter nicks…"
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Rectangle {
                visible: root.showFilter
                width:   parent.width
                height:  root.showFilter ? 1 : 0
                color:   Theme.border
            }

            // Roster
            ListView {
                id:     _list
                width:  parent.width
                height: parent.height -
                        (root.showHeader ? 35 : 0) -
                        (root.showFilter ? 31 : 0)
                model:  root._view
                clip:   true
                boundsBehavior: Flickable.StopAtBounds
                cacheBuffer:    200

                QQC.ScrollBar.vertical: QQC.ScrollBar {
                    policy:      QQC.ScrollBar.AsNeeded
                    contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
                    background:  Rectangle { color: "transparent" }
                }

                delegate: Rectangle {
                    id: _row
                    required property var modelData
                    required property int index

                    readonly property string _nick: String(_row.modelData.nick ?? "")
                    readonly property string _mode: String(_row.modelData.mode ?? "")
                    readonly property bool   _away: _row.modelData.away === true
                    readonly property bool   _isSelf:
                        root.selfNick !== "" &&
                        _row._nick.toLowerCase() === root.selfNick.toLowerCase()
                    readonly property bool _selected:
                        root.selectedNick !== "" &&
                        _row._nick.toLowerCase() === root.selectedNick.toLowerCase()

                    width:  _list.width
                    height: root.rowHeight
                    color:  _selected ? root._selectionBg
                                      : (_hover.hovered ? Theme.surfaceVariant : "transparent")

                    HoverHandler { id: _hover }

                    Row {
                        anchors {
                            left:           parent.left
                            right:          parent.right
                            leftMargin:     Theme.sp3
                            rightMargin:    Theme.sp2
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 0

                        // Fixed-width mode column keeps every nick left-aligned
                        // whether or not it carries a prefix.
                        Text {
                            visible: root.showModeIcon
                            width:   root.showModeIcon ? 10 : 0
                            text:    _row._mode
                            color:   IrcPalette.modeColor(_row._mode)
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textSm
                            font.weight:    Theme.weightBold
                        }

                        Text {
                            width:          parent.width - (root.showModeIcon ? 10 : 0)
                            text:           _row._nick
                            elide:          Text.ElideRight
                            color:          root.colorNicks ? IrcPalette.nickColor(_row._nick)
                                                            : Theme.textPrimary
                            opacity:        _row._away ? 0.45 : 1.0
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textSm
                            font.weight:    _row._isSelf ? Theme.weightBold : Theme.weightRegular
                            font.italic:    _row._away
                        }
                    }

                    MouseArea {
                        anchors.fill:    parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape:     Qt.PointingHandCursor

                        onClicked: (mouse) => {
                            root.selectedNick = _row._nick
                            if (mouse.button === Qt.RightButton) {
                                var p = _row.mapToItem(root, mouse.x, mouse.y)
                                root.nickRightClicked(_row._nick, p.x, p.y)
                            } else {
                                root.nickClicked(_row._nick)
                            }
                        }

                        onDoubleClicked: root.nickActivated(_row._nick)
                    }
                }
            }
        }
    }
}
