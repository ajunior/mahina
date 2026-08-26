import QtQuick
import Mahina

// Draggable, resizable floating window with title bar.
//
// Usage:
//   WindowFrame {
//       title:     "My Window"
//       x: 60; y: 40; width: 420; height: 300
//       TextField { anchors.centerIn: parent; placeholderText: "Content here" }
//   }
Rectangle {
    id: root

    property string title:       ""
    property bool   closable:    true
    property bool   minimizable: true
    property bool   resizable:   true
    property bool   showShadow:  true

    signal closeRequested()
    signal minimized()

    default property alias content: _contentArea.data

    width:  400
    height: 280
    radius: Theme.radiusMd

    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    layer.enabled:    root.showShadow
    layer.effect: null

    readonly property int titleBarH: 36
    readonly property int resizeMargin: 6

    // Title bar
    Rectangle {
        id:     _titleBar
        width:  parent.width
        height: root.titleBarH
        radius: root.radius
        color:  Theme.surfaceVariant

        // Square off bottom corners
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: parent.radius; color: parent.color
        }

        border.color: Theme.border; border.width: 0

        // Traffic-light buttons (only bottom border separator)
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10 }
            spacing: 7

            Repeater {
                model: [
                    { visible: root.closable,    color: "#ff5f57", tip: "Close"    },
                    { visible: root.minimizable, color: "#febc2e", tip: "Minimize" },
                    { visible: true,             color: "#28c840", tip: "Expand"   },
                ]
                delegate: Rectangle {
                    required property var  modelData
                    visible: modelData.visible
                    width: 12; height: 12; radius: 6
                    color: modelData.color
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (index === 0) root.closeRequested()
                            else if (index === 1) root.minimized()
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text:           root.title
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Font.Medium
            elide:          Text.ElideRight
            width:          parent.width - 80
            horizontalAlignment: Text.AlignHCenter
        }

        // Drag handle
        MouseArea {
            anchors.fill: parent
            drag.target:  root
            drag.axis:    Drag.XAndYAxis
            cursorShape:  Qt.SizeAllCursor
        }
    }

    // Separator
    Rectangle {
        anchors.top: _titleBar.bottom
        width: parent.width; height: 1; color: Theme.border
    }

    // Content area
    Item {
        id:     _contentArea
        anchors {
            top:    _titleBar.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
            topMargin:    1
            margins:      0
        }
        clip: true
    }

    // Resize handles (edges + corners)
    // Right edge
    MouseArea {
        id: _resizeRight
        visible: root.resizable
        x: parent.width - root.resizeMargin
        y: root.resizeMargin
        width:  root.resizeMargin
        height: parent.height - root.resizeMargin * 2
        cursorShape: Qt.SizeHorCursor
        // Global coordinates, because the handle moves as the window resizes:
        // anything relative to the handle itself would chase the cursor.
        property real startW: 0; property real startX: 0
        onPressed:  (m) => { startW = root.width;  startX = _resizeRight.mapToGlobal(m.x, m.y).x }
        onPositionChanged: (m) => {
            if (_resizeRight.pressed)
                root.width = Math.max(180, startW + (_resizeRight.mapToGlobal(m.x, m.y).x - startX))
        }
    }
    // Bottom edge
    MouseArea {
        id: _resizeBottom
        visible: root.resizable
        x: root.resizeMargin
        y: parent.height - root.resizeMargin
        width:  parent.width - root.resizeMargin * 2
        height: root.resizeMargin
        cursorShape: Qt.SizeVerCursor
        property real startH: 0; property real startY: 0
        onPressed:  (m) => { startH = root.height; startY = _resizeBottom.mapToGlobal(m.x, m.y).y }
        onPositionChanged: (m) => {
            if (_resizeBottom.pressed)
                root.height = Math.max(120, startH + (_resizeBottom.mapToGlobal(m.x, m.y).y - startY))
        }
    }
    // Bottom-right corner
    MouseArea {
        id: _resizeCorner
        visible: root.resizable
        x: parent.width  - root.resizeMargin
        y: parent.height - root.resizeMargin
        width:  root.resizeMargin; height: root.resizeMargin
        cursorShape: Qt.SizeFDiagCursor
        property real startW: 0; property real startH: 0
        property real startX: 0; property real startY: 0
        onPressed:  (m) => {
            var g = _resizeCorner.mapToGlobal(m.x, m.y)
            startW = root.width; startH = root.height
            startX = g.x;        startY = g.y
        }
        onPositionChanged: (m) => {
            if (_resizeCorner.pressed) {
                var g = _resizeCorner.mapToGlobal(m.x, m.y)
                root.width  = Math.max(180, startW + (g.x - startX))
                root.height = Math.max(120, startH + (g.y - startY))
            }
        }
    }
}
