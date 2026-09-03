pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Two-line row for use inside SidebarSection or any sidebar panel.
// Shows a primary label and a secondary detail line.
// severity controls the detail colour: "" | "success" | "warning" | "error"
//
// Setting actionIcon adds one trailing button, revealed on hover, for the
// per-row verb the list needs — usually removing the row. It stays hidden until
// the pointer is on the row so a long list reads as text rather than as a
// column of buttons, which is also why there is one and not a toolbar.
//
// Usage:
//   SidebarEntry {
//       width:    ListView.view.width
//       label:    modelData.sql
//       detail:   modelData.connectionName + " · " + modelData.elapsedMs + "ms"
//       severity: modelData.ok ? "" : "error"
//       onClicked: querySelected(modelData.sql)
//
//       actionIcon:    Icons.trash
//       actionTooltip: "Remove"
//       onActionClicked: model.remove(modelData.id)
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string label:    ""
    property string detail:   ""
    property string severity: ""   // "" | "success" | "warning" | "error"

    // Trailing hover action. Empty actionIcon (the default) means no button and
    // no reserved space, so every existing row is unchanged.
    property string actionIcon:    ""
    property string actionTooltip: ""

    signal clicked()
    signal actionClicked()

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
    // Hover comes from a HoverHandler rather than the MouseArea below: the
    // trailing button covers part of the row, and a MouseArea beneath it stops
    // reporting containsMouse there. That would blink the row background off
    // and — since the button reveals itself on the same signal — pull the
    // button out from under the pointer. Nested HoverHandlers do not block one
    // another, so the row keeps its hover while the button has its own.
    HoverHandler { id: _hover }

    Rectangle {
        anchors.fill: parent
        color:        _hover.hovered ? Theme.panel : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    Column {
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin:     Theme.sp4
        // Keep the text clear of the trailing button whether or not it is
        // showing: text that reflowed on hover would be worse than a gap.
        anchors.rightMargin:    Theme.sp4 + (root.actionIcon !== ""
                                             ? _action.width + Theme.sp2 : 0)
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
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }

    // ── Trailing action ───────────────────────────────────────────────────────
    // Declared after the MouseArea so it sits above and takes the click itself;
    // otherwise activating the row's own action would also trigger the row.
    Tooltip {
        anchors.right:          parent.right
        anchors.rightMargin:    Theme.sp2
        anchors.verticalCenter: parent.verticalCenter
        text:                   root.actionTooltip
        visible:                root.actionIcon !== "" && _hover.hovered

        Button {
            id:        _action
            iconOnly:  true
            iconName:  root.actionIcon
            size:      Button.Size.Sm
            variant:   Button.Variant.Ghost
            onClicked: root.actionClicked()
        }
    }
}
