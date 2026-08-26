pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Blocking confirmation dialog — lighter than Dialog, focused on a single decision.
//
// Usage:
//   AlertDialog {
//       id:          alert
//       title:       "Delete project?"
//       message:     "This will permanently delete the project and all its data."
//       confirmText: "Delete"
//       danger:      true
//       onConfirmed: doDelete()
//   }
//
//   Button { text: "Delete"; onClicked: alert.open() }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title:       ""
    property string message:     ""
    property string confirmText: "Confirm"
    property string cancelText:  "Cancel"
    property bool   danger:      false
    property bool   closeable:   true

    signal confirmed()
    signal cancelled()

    function open()  { root.visible = true;  _openAnim.start() }
    function close() { _closeAnim.start() }

    // ── Overlay ───────────────────────────────────────────────────────────────
    anchors.fill: parent
    visible:      false
    z:            1000

    // Backdrop
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
        id:               _box
        anchors.centerIn: parent
        width:            Math.min(400, root.width - Theme.sp8 * 2)
        height:           _col.implicitHeight
        color:            Theme.surface
        radius:           Theme.radiusLg
        border.color:     Theme.border
        border.width:     1
        opacity:          0
        scale:            0.96

        ColumnLayout {
            id:      _col
            width:   parent.width
            spacing: 0

            // ── Header ────────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth:    true
                Layout.topMargin:    Theme.sp6
                Layout.leftMargin:   Theme.sp6
                Layout.rightMargin:  Theme.sp6
                Layout.bottomMargin: Theme.sp4
                spacing: Theme.sp2

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
                    text:           root.message
                    visible:        root.message !== ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    wrapMode:       Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            // ── Actions ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.alignment:    Qt.AlignRight
                Layout.rightMargin:  Theme.sp4
                Layout.topMargin:    Theme.sp4
                Layout.bottomMargin: Theme.sp4
                spacing: Theme.sp2

                Button {
                    text:    root.cancelText
                    variant: Button.Variant.Ghost
                    onClicked: { root.close(); root.cancelled() }
                }

                Button {
                    text:    root.confirmText
                    variant: root.danger ? Button.Variant.Danger : Button.Variant.Primary
                    onClicked: { root.close(); root.confirmed() }
                }
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
        ScriptAction { script: root.visible = false }
    }
}
