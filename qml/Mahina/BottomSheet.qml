pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Slide-up panel from the bottom of the screen (mobile-style overlay).
//
// Usage:
//   BottomSheet { id: sheet; title: "Share"
//       Column { spacing: Theme.sp2
//           Repeater { model: ["Copy link", "Twitter", "Email"]
//               delegate: Button { text: modelData; variant: Button.Variant.Ghost } }
//       }
//   }
//   Button { text: "Share"; onClicked: sheet.open() }
//
// Place as a direct child of your root Window or full-screen Item.
Item {
    id: root

    default property alias content: _body.data
    property string title:     ""
    property bool   closeable: true
    property real   maxHeight: parent ? parent.height * 0.9 : 600

    signal opened()
    signal closed()

    function open()  {
        root.visible = true
        _panel.y     = _openY()
        _backdrop.opacity = 1
        root.opened()
    }
    function close() {
        _panel.y          = _closedY()
        _backdrop.opacity = 0
    }

    function _openY()  { return root.height - _panel.height }
    function _closedY(){ return root.height }

    anchors.fill: parent
    visible:      false
    z:            900

    Rectangle {
        id:           _backdrop
        anchors.fill: parent
        color:        Theme.overlay
        opacity:      0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        MouseArea { anchors.fill: parent; onClicked: if (root.closeable) root.close() }
    }

    Rectangle {
        id:     _panel
        width:  root.width
        height: Math.min(root.maxHeight, _col.implicitHeight + Theme.sp2)
        y:      _closedY()
        color:  Theme.surface

        // Rounded top corners only
        radius: Theme.radiusLg
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: parent.radius
            color:  parent.color
        }

        // Top border
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Theme.border
        }

        Behavior on y { NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic } }

        onYChanged: {
            if (Math.round(y) >= Math.round(root._closedY())) {
                root.visible = false
                root.closed()
            }
        }

        ColumnLayout {
            id:      _col
            width:   parent.width
            spacing: 0

            // Drag handle
            Item {
                Layout.fillWidth: true
                height:           Theme.sp4 + 4

                Rectangle {
                    anchors.centerIn: parent
                    width:  40; height: 4; radius: 2
                    color:  Theme.border
                }

                MouseArea {
                    anchors.fill: parent
                    property real _startY: 0

                    onPressed: (mouse) => _startY = mouse.y + _panel.y
                    onPositionChanged: (mouse) => {
                        var newY = mouse.y + _panel.y - _startY + _panel.y
                        _panel.y = Math.max(root._openY(), Math.min(root._closedY(), mouse.y + _panel.y - (root._openY() - _panel.y)))
                    }
                    onReleased: {
                        // Snap based on current position
                        if (_panel.y > root._openY() + _panel.height * 0.3)
                            root.close()
                        else
                            _panel.y = root._openY()
                    }
                }
            }

            // Header (if title set)
            RowLayout {
                visible:              root.title !== "" || root.closeable
                Layout.fillWidth:     true
                Layout.leftMargin:    Theme.sp5
                Layout.rightMargin:   Theme.sp4
                Layout.bottomMargin:  Theme.sp2
                spacing: Theme.sp3

                Text {
                    visible:          root.title !== ""
                    text:             root.title
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textBase
                    font.weight:      Theme.weightSemibold
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: root.closeable
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: _xH.containsMouse ? Theme.border : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _xH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                    Text { anchors.centerIn: parent; text: "×"; color: Theme.textSecondary; font.pixelSize: 18 }
                }
            }

            // Content
            Item {
                id:                  _body
                Layout.fillWidth:    true
                Layout.leftMargin:   Theme.sp5
                Layout.rightMargin:  Theme.sp5
                Layout.bottomMargin: Theme.sp6
                implicitHeight:      childrenRect.height
            }
        }
    }
}
