pragma ComponentBehavior: Bound
import QtQuick
import Mahina

Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string label:       ""
    property bool   vertical:    false
    property color  color:       Theme.border

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  vertical ? 1 : parent ? parent.width : 200
    implicitHeight: vertical ? parent ? parent.height : 40
                             : label !== "" ? Theme.textSm + Theme.sp2 : 1

    // ── Horizontal with optional centered label ───────────────────────────────
    Row {
        visible:      !root.vertical
        anchors.fill: parent
        spacing:      root.label !== "" ? Theme.sp3 : 0

        Rectangle {
            width:  root.label !== "" ? (parent.width - _lbl.width - Theme.sp3 * 2) / 2
                                      : parent.width
            height: 1
            color:  root.color
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: _lbl
            text:           root.label
            visible:        root.label !== ""
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            visible: root.label !== ""
            width:   (parent.width - _lbl.width - Theme.sp3 * 2) / 2
            height:  1
            color:   root.color
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── Vertical ──────────────────────────────────────────────────────────────
    Rectangle {
        visible: root.vertical
        width:   1
        height:  parent.height
        color:   root.color
        anchors.centerIn: parent
    }
}
