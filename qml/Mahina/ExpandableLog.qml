pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Expandable-row log viewer. Like LogViewer but each entry can reveal a
// structured detail panel when clicked.
//
// Usage:
//   ExpandableLog {
//       log: myEntries
//       detailComponent: Component {
//           required property var entry   // full entry object
//           // render entry.detail, entry.category, etc.
//       }
//   }
//
// Entry shape: { id, level, message, timestamp?, tag?, category?, detail?: var }
Item {
    id: root

    property var       log:             []
    property Component detailComponent: null
    property bool      showFilter:      true
    property bool      autoScroll:      true
    property bool      showTimestamps:  true
    property bool      showTags:        true
    property bool      wrapLines:       false
    property var       enabledLevels:   ["debug", "info", "warn", "error"]

    implicitWidth:  500
    implicitHeight: 400

    property string _filterText: ""
    property var    _expanded:   ({})   // entry.id → bool

    function _toggle(entryId: var): void {
        var m = Object.assign({}, root._expanded)
        m[entryId] = !m[entryId]
        root._expanded = m
    }

    readonly property var _filtered: {
        var q = root._filterText.toLowerCase()
        return root.log.filter(function(e) {
            if (root.enabledLevels.indexOf(e.level ?? "info") === -1) return false
            if (q === "") return true
            return (e.message  ?? "").toLowerCase().indexOf(q) !== -1
                || (e.tag      ?? "").toLowerCase().indexOf(q) !== -1
                || (e.category ?? "").toLowerCase().indexOf(q) !== -1
                // Structured payloads too — SQL text, error messages, prompts…
                || JSON.stringify(e.detail ?? {}).toLowerCase().indexOf(q) !== -1
        })
    }

    function _levelColor(l: var): var {
        switch (l) {
            case "debug": return Theme.textSecondary
            case "info":  return Theme.info
            case "warn":  return Theme.warning
            case "error": return Theme.error
            default:      return Theme.textSecondary
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing:      0

        // ── Toolbar ───────────────────────────────────────────────────────────
        Rectangle {
            visible:          root.showFilter
            Layout.fillWidth: true
            height:           40
            color:            Theme.panel
            border.color:     Theme.border
            border.width:     1
            radius:           Theme.radiusMd

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                spacing: Theme.sp2

                Icon { name: Icons.funnel; size: 13; color: Theme.textSecondary }

                TextInput {
                    id:               _fi
                    Layout.fillWidth: true
                    text:             root._filterText
                    onTextChanged:    root._filterText = text
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    clip:             true
                    Text {
                        visible:        _fi.text === ""
                        text:           "Filter logs…"
                        color:          Theme.textDisabled
                        font:           _fi.font
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    model: ["debug", "info", "warn", "error"]
                    delegate: Rectangle {
                        id: _rq1
                        required property string modelData
                        readonly property bool _on: root.enabledLevels.indexOf(modelData) !== -1
                        height: 22; width: _lt.implicitWidth + 10; radius: Theme.radiusFull
                        color:        _on ? Qt.rgba(Qt.color(root._levelColor(modelData)).r,
                                                    Qt.color(root._levelColor(modelData)).g,
                                                    Qt.color(root._levelColor(modelData)).b, 0.18)
                                          : Theme.surfaceVariant
                        border.color: _on ? root._levelColor(modelData) : Theme.border
                        border.width: 1
                        Text {
                            id: _lt; anchors.centerIn: parent
                            text: _rq1.modelData
                            color: _rq1._on ? root._levelColor(_rq1.modelData) : Theme.textDisabled
                            font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; font.weight: Theme.weightMedium
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var lvls = root.enabledLevels.slice()
                                var idx  = lvls.indexOf(_rq1.modelData)
                                if (idx === -1) lvls.push(_rq1.modelData); else lvls.splice(idx, 1)
                                root.enabledLevels = lvls
                            }
                        }
                    }
                }

                Icon {
                    visible: root._filterText !== ""
                    name: Icons.x; size: 12; color: Theme.textSecondary
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { _fi.text = ""; root._filterText = "" }
                    }
                }
            }
        }

        // ── Log list ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            color:             Theme.surface
            radius:            Theme.radiusMd
            clip:              true
            border.color:      Theme.border
            border.width:      1

            ListView {
                id:              _lv
                anchors.fill:    parent
                anchors.margins: 1
                model:           root._filtered
                spacing:         0
                clip:            true
                cacheBuffer:     400

                QQC.ScrollBar.vertical: QQC.ScrollBar {
                    contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
                    background:  Rectangle { color: "transparent" }
                }

                onCountChanged: {
                    if (root.autoScroll) Qt.callLater(() => positionViewAtEnd())
                }

                delegate: Item {
                    id:    _d
                    required property var modelData
                    required property int index

                    readonly property bool _hasDetail: root.detailComponent !== null
                    readonly property bool _exp:       root._expanded[modelData.id] === true

                    width:  _lv.width
                    height: 28 + _detailArea.height
                    clip:   true
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    // Alternating row background
                    Rectangle {
                        anchors.fill: parent
                        color: _d.index % 2 === 0 ? "transparent"
                                                  : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g,
                                                            Theme.textPrimary.b, 0.03)
                    }

                    // ── Summary row ───────────────────────────────────────────
                    Item {
                        id:     _row
                        width:  parent.width
                        height: 28

                        Icon {
                            id:      _caret
                            anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                            name:     Icons.caretRight
                            size:     11
                            color:    Theme.textSecondary
                            visible:  _d._hasDetail
                            rotation: _d._exp ? 90 : 0
                            Behavior on rotation { NumberAnimation { duration: 150 } }
                        }

                        Row {
                            anchors {
                                left:        _d._hasDetail ? _caret.right : parent.left
                                leftMargin:  _d._hasDetail ? 4 : 10
                                right:       parent.right
                                rightMargin: 8
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 6

                            // Timestamp
                            Text {
                                visible: root.showTimestamps && (_d.modelData.timestamp ?? "") !== ""
                                anchors.verticalCenter: parent.verticalCenter
                                text: _d.modelData.timestamp ?? ""; color: Theme.textSecondary
                                font.family: Theme.fontFamilyMono; font.pixelSize: Theme.textXs
                            }

                            // Category badge
                            Rectangle {
                                visible: (_d.modelData.category ?? "") !== ""
                                height: 16; width: _catT.implicitWidth + 8; radius: 3
                                color: Theme.surfaceVariant; anchors.verticalCenter: parent.verticalCenter
                                Text { id: _catT; anchors.centerIn: parent
                                    text: _d.modelData.category ?? ""
                                    color: Theme.textSecondary; font.family: Theme.fontFamilyMono; font.pixelSize: 9; font.weight: Theme.weightBold }
                            }

                            // Level badge
                            Rectangle {
                                height: 16; width: _lvlT.implicitWidth + 8; radius: 3
                                color: Qt.rgba(Qt.color(root._levelColor(_d.modelData.level ?? "info")).r,
                                               Qt.color(root._levelColor(_d.modelData.level ?? "info")).g,
                                               Qt.color(root._levelColor(_d.modelData.level ?? "info")).b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter
                                Text { id: _lvlT; anchors.centerIn: parent
                                    text: (_d.modelData.level ?? "info").toUpperCase()
                                    color: root._levelColor(_d.modelData.level ?? "info")
                                    font.family: Theme.fontFamilyMono; font.pixelSize: 9; font.weight: Theme.weightBold }
                            }

                            // Optional tag
                            Rectangle {
                                visible: root.showTags && (_d.modelData.tag ?? "") !== ""
                                height: 16; width: _tagT.implicitWidth + 8; radius: 3
                                color: Qt.rgba(Theme.info.r, Theme.info.g, Theme.info.b, 0.15)
                                anchors.verticalCenter: parent.verticalCenter
                                Text { id: _tagT; anchors.centerIn: parent; text: _d.modelData.tag ?? ""
                                    color: Theme.info; font.family: Theme.fontFamilyMono; font.pixelSize: 9 }
                            }

                            // Message
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:  _d.modelData.message ?? ""; color: Theme.textPrimary
                                font.family: Theme.fontFamilyMono; font.pixelSize: Theme.textSm
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, _d.width - x - 20)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  _d._hasDetail ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked:    if (_d._hasDetail) root._toggle(_d.modelData.id)
                        }
                    }

                    // ── Detail area ───────────────────────────────────────────
                    Item {
                        id:      _detailArea
                        anchors { left: parent.left; right: parent.right; top: _row.bottom; leftMargin: 22; rightMargin: 8 }
                        height:  _d._exp && _dl.item ? _dl.item.implicitHeight + 12 : 0
                        clip:    true

                        Loader {
                            id:              _dl
                            width:           parent.width
                            sourceComponent: _d._exp ? root.detailComponent : null
                            onLoaded:        if (item) item.entry = _d.modelData
                        }
                    }
                }
            }
        }
    }
}
