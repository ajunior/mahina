pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Standalone copy-to-clipboard icon button with brief checkmark feedback.
//
// Usage:
//   CopyButton { text: "npm install glow" }
//   CopyButton { text: secret; label: "Copy token"; size: "sm"
//                onCopyRequested: (t) => clipboard.setText(t) }
//
// Wire onCopyRequested to your backend clipboard call.
Item {
    id: root

    property string text:  ""
    property string label: ""    // when non-empty, shown beside icon
    property string size:  "md"  // "sm" | "md"

    signal copyRequested(string text)

    property bool _copied: false

    readonly property real _h:      root.size === "sm" ? 26 : 32
    readonly property real _iconSz: root.size === "sm" ? 12 : 14

    implicitWidth:  _label.visible ? _row.implicitWidth + Theme.sp3 * 2 : _h
    implicitHeight: _h

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusSm
        color:         _hov.hovered ? Theme.hover : "transparent"
        border.color:  _hov.hovered ? Theme.border : "transparent"
        border.width:  1
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        Row {
            id:               _row
            anchors.centerIn: parent
            spacing:          Theme.sp1

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name:  root._copied ? Icons.check : Icons.copy
                size:  root._iconSz
                color: root._copied ? Theme.success : Theme.textSecondary
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            Text {
                id:             _label
                visible:        root.label !== ""
                anchors.verticalCenter: parent.verticalCenter
                text:           root._copied ? "Copied!" : root.label
                color:          root._copied ? Theme.success : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: root.size === "sm" ? Theme.textXs : Theme.textSm
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }
        }

        HoverHandler { id: _hov }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                root._copied = true
                _resetTimer.restart()
                root.copyRequested(root.text)
            }
        }
    }

    Timer { id: _resetTimer; interval: 2000; onTriggered: root._copied = false }
}
