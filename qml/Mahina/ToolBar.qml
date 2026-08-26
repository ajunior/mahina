pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Icon/action toolbar with separators and optional labels.
//
// Action object fields (all optional except icon or separator):
//   icon:      string   — icon glyph from Icons.*
//   label:     string   — text shown when showLabels is true
//   variant:   string   — "" | "primary" | "danger"  (default: "")
//   visible:   bool     — conditionally hide an action  (default: true)
//   separator: bool     — render a vertical divider instead of a button
//   action:    function — called on click
//
// Usage:
//   ToolBar {
//       showLabels: true
//       toolActions: [
//           { icon: Icons.play, label: "Run",  variant: "primary", action: function() { query.run()  } },
//           { icon: Icons.stop, label: "Stop",  variant: "danger",  action: function() { query.stop() } },
//           { separator: true },
//           { icon: Icons.floppyDisk, label: "Save", action: function() { file.save() } },
//       ]
//   }
Item {
    id: root

    property var  toolActions: []
    property bool showLabels:  false

    signal actionTriggered(string label)

    implicitWidth:  _tbRow.implicitWidth + Theme.sp2 * 2
    implicitHeight: 44

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceVariant

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1; color: Theme.border
        }
    }

    // ── Actions (left side) ───────────────────────────────────────────────────
    Row {
        id: _tbRow
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: Theme.sp2 }
        spacing: 2

        Repeater {
            model: root.toolActions
            delegate: Item {
                id: _del
                required property var modelData
                required property int index

                // root is unreachable from JS handlers in required-property delegates,
                // but property bindings resolve it fine — so capture it here and
                // access via _del._toolbar from nested onClicked handlers.
                readonly property var _toolbar: root

                visible: modelData.visible !== false
                width:   modelData.separator ? 13
                         : root.showLabels   ? (_tbActLbl.implicitWidth + _tbActIcon.implicitWidth + 24)
                         : 36
                height:  parent.height

                // Separator
                Rectangle {
                    visible:  !!_del.modelData.separator
                    anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
                    width: 1; height: 22; color: Theme.border
                }

                // Button
                Rectangle {
                    id: _btn
                    visible:  !_del.modelData.separator
                    anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
                    width:  root.showLabels ? parent.width - 4 : 32
                    height: 32
                    radius: Theme.radiusSm

                    readonly property bool _isPrimary: _del.modelData.variant === "primary"
                    readonly property bool _isDanger:  _del.modelData.variant === "danger"
                    readonly property color _fg: (_isPrimary || _isDanger)
                                                 ? Theme.textOnPrimary
                                                 : Theme.textSecondary

                    color: {
                        if (_isPrimary) return _tbBH.hovered ? Theme.primaryHover          : Theme.primary
                        if (_isDanger)  return _tbBH.hovered ? Qt.darker(Theme.error, 1.1) : Theme.error
                        return _tbBH.hovered ? Theme.panel : "transparent"
                    }

                    Behavior on color { ColorAnimation { duration: 80 } }

                    HoverHandler { id: _tbBH }

                    Row {
                        anchors.centerIn: parent
                        spacing: root.showLabels ? 5 : 0

                        Text {
                            id:             _tbActIcon
                            text:           _del.modelData.icon || ""
                            color:          _btn._fg
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textBase
                            Behavior on color { ColorAnimation { duration: 80 } }
                        }

                        Text {
                            id:             _tbActLbl
                            visible:        root.showLabels
                            text:           _del.modelData.label || ""
                            color:          _btn._fg
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            Behavior on color { ColorAnimation { duration: 80 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (_del.modelData.action) _del.modelData.action()
                            _del._toolbar.actionTriggered(_del.modelData.label || "")
                        }
                    }
                }
            }
        }
    }

}
