import QtQuick
import QtQuick.Layouts
import Mahina

Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title: ""
    property alias  trailing: _trailing.data

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitHeight: 60
    implicitWidth:  400

    // ── Appearance ────────────────────────────────────────────────────────────
    color:        Theme.surface

    // Bottom hairline
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height: 1
        color:  Theme.border
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill:        parent
        anchors.leftMargin:  Theme.sp6
        anchors.rightMargin: Theme.sp6
        spacing:             Theme.sp4

        Text {
            text:             root.title
            visible:          root.title !== ""
            color:            Theme.textPrimary
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.textLg
            font.weight:      Theme.weightSemibold
        }

        Item { Layout.fillWidth: true }

        // Trailing actions slot (buttons, icons, etc.)
        RowLayout {
            id: _trailing
            spacing: Theme.sp2
        }
    }
}
