import QtQuick
import Mahina

// Clickable path segments that switch to an editable TextInput on double-click.
//
// Usage:
//   BreadcrumbEditor {
//       crumbPath:  "/home/user/documents/reports"
//       separator:  "/"
//       onCrumbPathChanged: (p) => loadPath(p)
//       onSegmentClicked:   (seg, idx) => navigateTo(idx)
//   }
Item {
    id: root

    property string crumbPath:  ""
    property string separator:  "/"
    property bool   editing:    false

    signal pathCommitted(string newPath)
    signal segmentClicked(string segment, int index)

    readonly property var segments: {
        var parts = root.crumbPath.split(root.separator)
        var out = []
        for (var i = 0; i < parts.length; i++)
            if (parts[i] !== "") out.push(parts[i])
        return out
    }

    implicitWidth:  400
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: root.editing ? Theme.primary : Theme.border
        border.width: root.editing ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 100 } }
        clip: true

        // ── Breadcrumb display ─────────────────────────────────────────
        Row {
            visible:  !root.editing
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            spacing: 0

            Repeater {
                model: root.segments
                delegate: Row {
                    id: _rq1
                    required property string modelData
                    required property int    index
                    spacing: 0

                    Text {
                        visible:        _rq1.index > 0
                        text:           root.separator
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                    }

                    Rectangle {
                        height: 22
                        width:  _segTxt.implicitWidth + 8
                        radius: Theme.radiusSm
                        color:  _segH.hovered ? Theme.panel : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _segH }

                        Text {
                            id:             _segTxt
                            anchors.centerIn: parent
                            text:           _rq1.modelData
                            color:          _rq1.index === root.segments.length - 1
                                            ? Theme.textPrimary : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _rq1.index === root.segments.length - 1
                                            ? Font.Medium : Font.Normal
                        }

                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.segmentClicked(_rq1.modelData, _rq1.index)
                        }
                    }
                }
            }
        }

        // ── Edit mode ──────────────────────────────────────────────────
        Item {
            visible:  root.editing
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }

            Text {
                visible: _editInput.text === ""
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                text:           "Enter path…"
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            TextInput {
                id:    _editInput
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                text:            root.crumbPath
                color:           Theme.textPrimary
                font.family:     Theme.fontFamily
                font.pixelSize:  Theme.textSm
                selectByMouse:   true
                Keys.onReturnPressed: {
                    root.crumbPath = text
                    root.pathCommitted(text)
                    root.editing = false
                }
                Keys.onEscapePressed: {
                    text = root.crumbPath
                    root.editing = false
                }
            }
        }

        // Double-click to enter edit mode
        MouseArea {
            visible: !root.editing
            anchors.fill: parent
            onDoubleClicked: {
                root.editing = true
                _editInput.text = root.crumbPath
                _editInput.forceActiveFocus()
                _editInput.selectAll()
            }
        }
    }
}
