pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Fixed-position action button (FAB) with optional SpeedDial expansion.
//
// Usage (simple FAB):
//   FloatingActionButton {
//       icon: Icons.plus
//       onClicked: createNew()
//   }
//
// Usage (SpeedDial):
//   FloatingActionButton {
//       icon: Icons.plus
//       label: "New"          // extended FAB
//       actions: [
//           { icon: Icons.pencil,  label: "Note"  },
//           { icon: Icons.image,   label: "Photo" },
//           { icon: Icons.link,    label: "Link"  },
//       ]
//       onActionTriggered: (i, action) => handleAction(action)
//   }
//
// Place as a direct child of a full-size page Item or Window.
// Anchors itself to bottom-right by default; override anchors as needed.
Item {
    id: root

    property string icon:       Icons.plus
    property string label:      ""          // if non-empty: extended FAB
    property color  fabColor:   Theme.primary
    property real   buttonSize: 56
    property var    actions:    []          // [{icon, label, color?}]
    property bool   expanded:   false

    signal clicked()
    signal actionTriggered(int index, var action)

    // Self-positions at bottom-right corner of parent
    anchors.right:         parent ? parent.right  : undefined
    anchors.bottom:        parent ? parent.bottom : undefined
    anchors.rightMargin:   Theme.sp5
    anchors.bottomMargin:  Theme.sp5
    z:                     500

    width:  root.label !== "" ? _mainRow.implicitWidth + Theme.sp5 * 2 : root.buttonSize
    height: root.buttonSize

    // ── SpeedDial entries (above the FAB) ────────────────────────────────────
    Column {
        id:      _dial
        anchors { bottom: _fab.top; bottomMargin: Theme.sp3; horizontalCenter: _fab.horizontalCenter }
        spacing: Theme.sp3
        opacity: root.expanded ? 1 : 0
        scale:   root.expanded ? 1 : 0.8
        transformOrigin: Item.Bottom
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        Repeater {
            model: root.actions
            delegate: RowLayout {
                id: _rq1
                required property var modelData
                required property int index

                layoutDirection: Qt.RightToLeft
                spacing:         Theme.sp3

                // Mini FAB
                Rectangle {
                    width:  40; height: 40; radius: 20
                    color:  _rq1.modelData.color ?? Theme.surface
                    border.color: Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    Rectangle {
                        anchors.fill: parent; radius: parent.radius
                        color: _aH.hovered ? Qt.rgba(0,0,0,0.08) : "transparent"
                    }
                    HoverHandler { id: _aH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.expanded = false
                            root.actionTriggered(_rq1.index, _rq1.modelData)
                        }
                    }
                    Icon {
                        anchors.centerIn: parent
                        name:  _rq1.modelData.icon
                        size:  18
                        color: _rq1.modelData.color ? "#ffffff" : Theme.textPrimary
                    }
                }

                // Label chip
                Rectangle {
                    height: 28; radius: Theme.radiusFull
                    width:  _lbl.implicitWidth + Theme.sp3 * 2
                    color:  Theme.surface
                    border.color: Theme.border; border.width: 1
                    Text {
                        id:             _lbl
                        anchors.centerIn: parent
                        text:           _rq1.modelData.label ?? ""
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightMedium
                    }
                }
            }
        }
    }

    // ── Main FAB button ───────────────────────────────────────────────────────
    Rectangle {
        id:     _fab
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        width:  parent.width; height: parent.height
        radius: root.label !== "" ? Theme.radiusFull : root.buttonSize / 2
        color:  _fH.hovered ? Qt.darker(root.fabColor, 1.1) : root.fabColor
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        HoverHandler { id: _fH }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.actions.length > 0) {
                    root.expanded = !root.expanded
                } else {
                    root.clicked()
                }
            }
        }

        Row {
            id:               _mainRow
            anchors.centerIn: parent
            spacing:          Theme.sp2

            Icon {
                id:    _mainIcon
                anchors.verticalCenter: parent.verticalCenter
                name:  root.actions.length > 0 && root.expanded ? Icons.x : root.icon
                size:  22; color: "#ffffff"
                Behavior on name { }
                // `parent` inside an Animator is the icon's parent — the Row — so
                // this used to spin the whole row, label included.
                RotationAnimator {
                    running:   root.actions.length > 0
                    target:    _mainIcon
                    from:      0; to: root.expanded ? 45 : 0
                    duration:  Theme.durationNormal
                }
            }

            Text {
                visible:          root.label !== ""
                anchors.verticalCenter: parent.verticalCenter
                text:             root.label
                color:            "#ffffff"
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                font.weight:      Theme.weightSemibold
            }
        }
    }
}
