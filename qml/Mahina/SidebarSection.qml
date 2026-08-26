pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Collapsible labelled section for use inside a sidebar panel.
// Children are placed inside the expandable body via the default alias.
//
// Usage:
//   SidebarSection {
//       title: "HISTORY"
//       initiallyOpen: true
//
//       ListView { model: historyModel; delegate: SidebarEntry { ... } }
//   }
Column {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title:         ""
    property bool   initiallyOpen: true

    default property alias content: _inner.data

    // ── State ────────────────────────────────────────────────────────────────
    property bool _expanded: root.initiallyOpen

    width: parent ? parent.width : 0

    // ── Header ────────────────────────────────────────────────────────────────
    Item {
        width:  parent.width
        height: 36

        Text {
            anchors.left:           parent.left
            anchors.leftMargin:     Theme.sp4
            anchors.verticalCenter: parent.verticalCenter
            text:                   root.title
            color:                  Theme.textDisabled
            font.family:            Theme.fontFamily
            font.pixelSize:         Theme.textXs
            font.weight:            Theme.weightSemibold
            font.letterSpacing:     1.5
        }

        Icon {
            anchors.right:          parent.right
            anchors.rightMargin:    Theme.sp4
            anchors.verticalCenter: parent.verticalCenter
            name:     Icons.caretDown
            size:     12
            color:    Theme.textDisabled
            rotation: root._expanded ? 0 : -90

            Behavior on rotation {
                NumberAnimation { duration: Theme.durationFast * 2; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            anchors.fill: parent
            color:        _headerMouse.containsMouse ? Theme.panel : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }

        MouseArea {
            id:           _headerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    root._expanded = !root._expanded
        }
    }

    // ── Collapsible body ──────────────────────────────────────────────────────
    Item {
        id:    _clip
        width: parent.width
        clip:  true

        height: root._expanded ? _inner.implicitHeight : 0

        Behavior on height {
            NumberAnimation { duration: Theme.durationFast * 2; easing.type: Easing.InOutQuad }
        }

        Column {
            id:    _inner
            width: parent.width
        }
    }
}
