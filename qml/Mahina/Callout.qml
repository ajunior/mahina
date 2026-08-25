import QtQuick
import QtQuick.Layouts
import Mahina

// Documentation-style callout box with icon, title, and rich body content.
//
// Usage:
//   Callout { title: "Note"; message: "This API is experimental." }
//   Callout { type: Callout.Type.Warning; title: "Caution"
//       Text { text: "Changing this setting requires a restart." }
//   }
//   Callout { type: Callout.Type.Tip; message: "Press ⌘K to open the command palette." }
Item {
    id: root

    enum Type { Note, Tip, Warning, Danger }

    default property alias content: _body.data
    property int    type:    Callout.Type.Note
    property string title:   ""
    property string message: ""    // shorthand; or use children for rich content

    implicitWidth:  300
    implicitHeight: _col.implicitHeight + Theme.sp4 * 2

    readonly property color _accent: {
        switch (root.type) {
            case Callout.Type.Tip:     return Theme.success
            case Callout.Type.Warning: return Theme.warning
            case Callout.Type.Danger:  return Theme.error
            default:                   return Theme.info
        }
    }
    readonly property color _subtle: {
        switch (root.type) {
            case Callout.Type.Tip:     return Theme.successSubtle
            case Callout.Type.Warning: return Theme.warningSubtle
            case Callout.Type.Danger:  return Theme.errorSubtle
            default:                   return Theme.infoSubtle
        }
    }
    readonly property string _icon: {
        switch (root.type) {
            case Callout.Type.Tip:     return Icons.lightbulb
            case Callout.Type.Warning: return Icons.warningCircle
            case Callout.Type.Danger:  return Icons.xCircle
            default:                   return Icons.info
        }
    }
    readonly property string _label: {
        switch (root.type) {
            case Callout.Type.Tip:     return "Tip"
            case Callout.Type.Warning: return "Warning"
            case Callout.Type.Danger:  return "Danger"
            default:                   return "Note"
        }
    }

    Rectangle {
        anchors.fill:  parent
        color:         root._subtle
        radius:        Theme.radiusMd
        border.color:  root._accent
        border.width:  1
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width:  4
        radius: Theme.radiusMd
        color:  root._accent
    }

    ColumnLayout {
        id:      _col
        anchors {
            left:   parent.left
            right:  parent.right
            top:    parent.top
            topMargin:    Theme.sp4
            leftMargin:   Theme.sp4 + 4
            rightMargin:  Theme.sp4
        }
        spacing: Theme.sp2

        // Header
        RowLayout {
            spacing: Theme.sp2

            Icon { name: root._icon; size: 16; color: root._accent }

            Text {
                text:           root.title !== "" ? root.title : root._label
                color:          root._accent
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
            }
        }

        // Short message
        Text {
            visible:          root.message !== ""
            text:             root.message
            color:            Theme.textSecondary
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.textSm
            wrapMode:         Text.WordWrap
            Layout.fillWidth: true
        }

        // Rich content slot
        Item {
            id:               _body
            visible:          children.length > 0
            implicitHeight:   childrenRect.height
            Layout.fillWidth: true
        }
    }
}
