import QtQuick
import Mahina

// Slide-in side panel from the right with a draggable resize handle.
//
// Usage:
//   SidePanel {
//       panelOpen:  showDetails
//       panelTitle: "Details"
//       panelWidth: 320
//       Text { text: "Panel content here" }
//   }
Item {
    id: root

    property bool   panelOpen:   false
    property real   panelWidth:  300
    property real   minWidth:    180
    property real   maxWidth:    600
    property string panelTitle:  ""
    property bool   resizable:   true

    signal closeRequested()

    default property alias content: _panelBody.data

    anchors.fill: parent

    // Dim overlay behind panel
    Rectangle {
        anchors.fill: parent
        color:  Qt.rgba(0, 0, 0, 0.3)
        opacity: root.panelOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
        visible: opacity > 0
        MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }
    }

    // Panel
    Rectangle {
        id:     _panel
        // Deliberately not anchored right: a right anchor overrides the x
        // binding below, pinning the panel to the edge so it can never slide
        // out and the close button appears to do nothing.
        anchors { top: parent.top; bottom: parent.bottom }
        width:  root.panelWidth
        x:      root.panelOpen ? parent.width - width : parent.width
        Behavior on x { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        color:  Theme.surface
        border.color: Theme.border; border.width: 1

        Column {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                width: parent.width; height: 48
                color: Theme.surfaceVariant

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp2 }
                    spacing: 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36
                        text:           root.panelTitle
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        font.weight:    Font.Medium
                        elide:          Text.ElideRight
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: Theme.radiusSm
                        color: _closeH.hovered ? Theme.panel : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _closeH }
                        Text { anchors.centerIn: parent; text: "✕"; color: Theme.textSecondary; font.pixelSize: 12 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.closeRequested() }
                    }
                }

                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
            }

            // Body
            Item {
                id:    _panelBody
                width: parent.width
                height: parent.height - 48
                clip: true
            }
        }

        // Resize handle (left edge)
        Rectangle {
            visible: root.resizable
            x: 0; y: 0; width: 5; height: parent.height
            color: _rH.hovered ? Theme.primary : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
            HoverHandler { id: _rH; cursorShape: Qt.SizeHorCursor }

            MouseArea {
                id: _resizeArea
                anchors.fill: parent
                cursorShape:  Qt.SizeHorCursor
                // Global coordinates: this handle sits on the panel edge and so
                // travels with every pixel the panel is resized by.
                property real pressX:  0
                property real pressW:  0
                onPressed: (m) => {
                    pressX = _resizeArea.mapToGlobal(m.x, m.y).x
                    pressW = root.panelWidth
                }
                onPositionChanged: (m) => {
                    if (_resizeArea.pressed) {
                        var delta = pressX - _resizeArea.mapToGlobal(m.x, m.y).x
                        root.panelWidth = Math.max(root.minWidth, Math.min(root.maxWidth, pressW + delta))
                    }
                }
            }
        }
    }
}
