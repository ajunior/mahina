pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Slide-in overlay panel from any screen edge.
//
// Usage:
//   Drawer {
//       id:    drawer
//       title: "Navigation"
//       // Content via default property:
//       Sidebar { ... }
//   }
//   Button { text: "Open"; onClicked: drawer.open() }
//
//   // Right-side settings panel:
//   Drawer { id: settings; title: "Settings"; position: Drawer.Position.Right; width: 400; ... }
//
// Place as a direct child of your root Window or full-screen Item.
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Position { Left, Right, Top, Bottom }

    property string title:    ""
    property bool   closeable: true
    property int    position: Drawer.Position.Left

    // Panel dimensions — the relevant one is used based on position
    property real panelWidth:  300
    property real panelHeight: 300

    default property alias content: _body.data

    signal opened()
    signal closed()

    function open() {
        root.visible = true
        _panel.x = _openX()
        _panel.y = _openY()
        _backdrop.opacity = 1
        root.opened()
    }

    function close() {
        _panel.x = _closedX()
        _panel.y = _closedY()
        _backdrop.opacity = 0
    }

    function _openX() {
        switch (root.position) {
            case Drawer.Position.Right: return root.width - root.panelWidth
            default:                    return 0
        }
    }
    function _closedX() {
        switch (root.position) {
            case Drawer.Position.Left:  return -root.panelWidth
            case Drawer.Position.Right: return root.width
            default:                    return 0
        }
    }
    function _openY() {
        switch (root.position) {
            case Drawer.Position.Bottom: return root.height - root.panelHeight
            default:                     return 0
        }
    }
    function _closedY() {
        switch (root.position) {
            case Drawer.Position.Top:    return -root.panelHeight
            case Drawer.Position.Bottom: return root.height
            default:                     return 0
        }
    }

    // ── Root ─────────────────────────────────────────────────────────────────
    anchors.fill: parent
    visible:      false
    z:            900

    // ── Backdrop ──────────────────────────────────────────────────────────────
    Rectangle {
        id:           _backdrop
        anchors.fill: parent
        color:        Theme.overlay
        opacity:      0

        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked:    if (root.closeable) root.close()
        }
    }

    // ── Panel ─────────────────────────────────────────────────────────────────
    Rectangle {
        id:     _panel
        width:  root.position === Drawer.Position.Left || root.position === Drawer.Position.Right
                ? root.panelWidth : root.width
        height: root.position === Drawer.Position.Top  || root.position === Drawer.Position.Bottom
                ? root.panelHeight : root.height
        color:  Theme.surface

        // Initial off-screen position (set without animation)
        Component.onCompleted: { x = Qt.binding(root._closedX); y = Qt.binding(root._closedY) }

        Behavior on x { NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic } }

        // Edge shadow hint
        Rectangle {
            visible: root.position === Drawer.Position.Left
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            width: 1; color: Theme.border
        }
        Rectangle {
            visible: root.position === Drawer.Position.Right
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            width: 1; color: Theme.border
        }
        Rectangle {
            visible: root.position === Drawer.Position.Top
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1; color: Theme.border
        }
        Rectangle {
            visible: root.position === Drawer.Position.Bottom
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1; color: Theme.border
        }

        ColumnLayout {
            anchors.fill: parent
            spacing:      0

            // ── Header ────────────────────────────────────────────────────────
            RowLayout {
                visible:              root.title !== "" || root.closeable
                Layout.fillWidth:     true
                Layout.leftMargin:    Theme.sp5
                Layout.rightMargin:   Theme.sp4
                Layout.topMargin:     Theme.sp4
                Layout.bottomMargin:  Theme.sp4
                spacing:              Theme.sp3

                Text {
                    text:             root.title
                    visible:          root.title !== ""
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textLg
                    font.weight:      Theme.weightSemibold
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible:  root.closeable
                    width:    28; height: 28
                    radius:   Theme.radiusSm
                    color:    _xHov.containsMouse ? Theme.border : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _xHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.close()
                    }
                    Text { anchors.centerIn: parent; text: "×"; color: Theme.textSecondary; font.pixelSize: 18 }
                }
            }

            Rectangle {
                visible:          root.title !== "" || root.closeable
                Layout.fillWidth: true
                height:           1; color: Theme.border
            }

            // ── Content ───────────────────────────────────────────────────────
            Item {
                id:               _body
                Layout.fillWidth: true
                Layout.fillHeight:true
            }
        }

        // Hide root when panel finishes sliding out
        onXChanged: if (Math.round(x) === Math.round(root._closedX()) && root.position !== Drawer.Position.Top && root.position !== Drawer.Position.Bottom) { root.visible = false; root.closed() }
        onYChanged: if (Math.round(y) === Math.round(root._closedY()) && root.position !== Drawer.Position.Left && root.position !== Drawer.Position.Right) { root.visible = false; root.closed() }
    }
}
