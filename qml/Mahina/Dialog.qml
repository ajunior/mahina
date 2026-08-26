pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Modal dialog with backdrop, animated open/close, header, content, and footer.
//
// Usage:
//   Dialog {
//       id: dlg
//       title:    "Delete item"
//       subtitle: "This action cannot be undone."
//
//       Text { text: "Are you sure you want to delete this item?" }
//
//       footer: Row {
//           spacing: Theme.sp2
//           Button { text: "Cancel"; variant: Button.Variant.Ghost;  onClicked: dlg.close() }
//           Button { text: "Delete"; variant: Button.Variant.Danger; onClicked: { doDelete(); dlg.close() } }
//       }
//   }
//
//   Button { text: "Open"; onClicked: dlg.open() }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title:          ""
    property string subtitle:       ""
    property bool   closeable:      true
    property int    preferredWidth: 480

    default property alias content: _body.data
    property alias  footer: _footer.data

    signal closed()

    function open() {
        root.visible = true
        _openAnim.start()
    }

    function close() {
        _closeAnim.start()
    }

    // ── Root covers the whole parent ──────────────────────────────────────────
    anchors.fill: parent
    visible:      false
    z:            1000

    // ── Backdrop ──────────────────────────────────────────────────────────────
    Rectangle {
        id:           _backdrop
        anchors.fill: parent
        color:        Theme.overlay
        opacity:      0

        MouseArea {
            anchors.fill: parent
            onClicked:    if (root.closeable) root.close()
        }
    }

    // ── Dialog box ────────────────────────────────────────────────────────────
    Rectangle {
        id:             _box
        anchors.centerIn: parent
        width:          Math.min(root.preferredWidth, root.width - Theme.sp8 * 2)
        height:         _col.implicitHeight
        color:          Theme.surface
        radius:         Theme.radiusLg
        border.color:   Theme.border
        border.width:   1
        opacity:        0
        scale:          0.96

        ColumnLayout {
            id:      _col
            width:   parent.width
            spacing: 0

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.leftMargin:   Theme.sp6
                Layout.rightMargin:  Theme.sp4
                Layout.topMargin:    Theme.sp5
                Layout.bottomMargin: Theme.sp5
                spacing: Theme.sp3

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sp1

                    Text {
                        text:           root.title
                        visible:        root.title !== ""
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textLg
                        font.weight:    Theme.weightSemibold
                        Layout.fillWidth: true
                    }

                    Text {
                        text:           root.subtitle
                        visible:        root.subtitle !== ""
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        wrapMode:       Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                // Close button
                Rectangle {
                    visible: root.closeable
                    width:   28
                    height:  28
                    radius:  Theme.radiusSm
                    color:   _closeMouse.containsMouse ? Theme.border : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text:             "×"
                        color:            Theme.textSecondary
                        font.pixelSize:   18
                    }

                    MouseArea {
                        id:           _closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.close()
                    }
                }
            }

            // Header / content divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color:  Theme.border
            }

            // ── Content ───────────────────────────────────────────────────────
            // Column sizes itself to its children — no binding loop
            Column {
                id:               _body
                Layout.fillWidth: true
                Layout.margins:   Theme.sp6
                spacing:          Theme.sp3
            }

            // Footer divider — only shown when footer has children
            Rectangle {
                visible:          _footer.children.length > 0
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
            }

            // ── Footer ────────────────────────────────────────────────────────
            // Right-aligned action buttons
            Row {
                id:                  _footer
                spacing:             Theme.sp2
                Layout.alignment:    Qt.AlignRight
                Layout.rightMargin:  Theme.sp4
                Layout.bottomMargin: Theme.sp4
                Layout.topMargin:    Theme.sp4
                visible:             _footer.children.length > 0
            }
        }
    }

    // ── Animations ────────────────────────────────────────────────────────────
    ParallelAnimation {
        id: _openAnim
        NumberAnimation { target: _backdrop; property: "opacity"; to: 1.0; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
        NumberAnimation { target: _box;      property: "opacity"; to: 1.0; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
        NumberAnimation { target: _box;      property: "scale";   to: 1.0; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: _closeAnim
        ParallelAnimation {
            NumberAnimation { target: _backdrop; property: "opacity"; to: 0.0; duration: Theme.durationNormal; easing.type: Easing.InCubic }
            NumberAnimation { target: _box;      property: "opacity"; to: 0.0; duration: Theme.durationNormal; easing.type: Easing.InCubic }
            NumberAnimation { target: _box;      property: "scale";   to: 0.96; duration: Theme.durationNormal; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { root.visible = false; root.closed() } }
    }
}
