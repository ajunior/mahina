import QtQuick
import Mahina

// Two-line row for use inside SidebarSection or any sidebar panel.
// Shows a primary label and a secondary detail line.
// severity controls the detail colour: "" | "success" | "warning" | "error"
//
// Usage:
//   SidebarEntry {
//       width:    ListView.view.width
//       label:    modelData.sql
//       detail:   modelData.connectionName + " · " + modelData.elapsedMs + "ms"
//       severity: modelData.ok ? "" : "error"
//       onClicked: querySelected(modelData.sql)
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string label:    ""
    property string detail:   ""
    property string severity: ""   // "" | "success" | "warning" | "error"

    signal clicked()

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitHeight: 44

    // ── Detail colour ─────────────────────────────────────────────────────────
    readonly property color _detailColor: {
        if (severity === "success") return Theme.success
        if (severity === "error")   return Theme.error
        if (severity === "warning") return Theme.warning
        return Theme.textSecondary
    }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        _mouse.containsMouse ? Theme.panel : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    Column {
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin:     Theme.sp4
        anchors.rightMargin:    Theme.sp4
        spacing:                2

        Text {
            width:          parent.width
            text:           root.label
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            elide:          Text.ElideRight
        }

        Text {
            width:          parent.width
            text:           root.detail
            color:          root._detailColor
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            elide:          Text.ElideRight
            visible:        root.detail !== ""

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }
    }

    // ── Interaction ───────────────────────────────────────────────────────────
    MouseArea {
        id:           _mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }
}
