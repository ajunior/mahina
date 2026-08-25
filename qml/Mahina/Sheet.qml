import QtQuick
import QtQuick.Layouts
import Mahina

// Desktop-style side panel — slides in from left or right with no dimming backdrop.
// Less intrusive than Drawer; typically used for inspector/detail panels that coexist
// with the main content.
//
// Usage:
//   Sheet {
//       id: _details; side: Sheet.Side.Right; title: "Details"
//       ColumnLayout { /* inspector content */ }
//   }
//   Button { text: "Details"; onClicked: _details.toggle() }
//
// Pair with SplitPane when you want the main content to shrink rather than overlap.
Item {
    id: root

    enum Side { Left, Right }

    default property alias content: _body.data
    property int    side:       Sheet.Side.Right
    property real   panelWidth: 320
    property string title:      ""
    property bool   closeable:  true
    property bool   isOpen:     false

    signal opened()
    signal closed()

    function open()   { root.isOpen = true;  root.opened() }
    function close()  { root.isOpen = false; root.closed() }
    function toggle() { root.isOpen ? close() : open() }

    // Zero-size host — panel is anchored inside parent
    width: 0; height: 0

    // ── Panel ─────────────────────────────────────────────────────────────────
    Rectangle {
        id:     _panel
        parent: root.parent ?? root    // sibling to the page content
        width:  root.panelWidth
        height: parent ? parent.height : 600
        color:  Theme.surface
        z:      100

        anchors.top:    parent ? parent.top    : undefined
        anchors.bottom: parent ? parent.bottom : undefined

        // Position: off-screen when closed, on-screen when open
        readonly property real _openX:   root.side === Sheet.Side.Right
                                         ? parent.width - root.panelWidth
                                         : 0
        readonly property real _closedX: root.side === Sheet.Side.Right
                                         ? parent.width
                                         : -root.panelWidth

        x: root.isOpen ? _openX : _closedX
        Behavior on x { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        // Edge shadow/border
        Rectangle {
            anchors {
                top: parent.top; bottom: parent.bottom
                left: root.side === Sheet.Side.Right ? parent.left : undefined
                right: root.side === Sheet.Side.Left  ? parent.right : undefined
            }
            width: 1; color: Theme.border
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header
            RowLayout {
                Layout.fillWidth:   true
                Layout.leftMargin:  Theme.sp5
                Layout.rightMargin: Theme.sp4
                Layout.topMargin:   Theme.sp4
                Layout.bottomMargin:Theme.sp3
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

                Item { Layout.fillWidth: true; visible: root.title === "" }

                Rectangle {
                    visible: root.closeable
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: _xH.containsMouse ? Theme.border : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _xH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                    Icon { anchors.centerIn: parent; name: Icons.x; size: 14; color: Theme.textSecondary }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            // Content
            Item {
                id:                   _body
                Layout.fillWidth:     true
                Layout.fillHeight:    true
                Layout.leftMargin:    Theme.sp5
                Layout.rightMargin:   Theme.sp5
                Layout.topMargin:     Theme.sp4
                Layout.bottomMargin:  Theme.sp5
                implicitHeight:       childrenRect.height
            }
        }
    }
}
