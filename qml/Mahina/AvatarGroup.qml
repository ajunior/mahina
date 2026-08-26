pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Overlapping avatar stack with "+N more" overflow chip.
//
// Usage:
//   AvatarGroup {
//       model: [
//           { name: "Alice Chen",  color: "#5B8DF6" },
//           { name: "Bob Smith",   color: "#59A14F" },
//           { name: "Carol White", color: "#F28E2B" },
//           { name: "Dan Brown",   color: "#E15759" },
//       ]
//       max:  3
//       size: 36
//   }
//
// Each item: { name, color?, src? }
Item {
    id: root

    property var model:   []
    property int max:     5
    property int size:    32
    property int overlap: 8     // px each avatar overlaps the previous

    readonly property int _shown:    Math.min(root.model.length, root.max)
    readonly property int _overflow: root.model.length - root._shown

    implicitWidth:  _shown * (root.size - root.overlap) + root.overlap +
                    (_overflow > 0 ? (root.size - root.overlap) : 0)
    implicitHeight: root.size

    Repeater {
        model: root._shown
        delegate: Item {
            required property int index

            x: index * (root.size - root.overlap)
            z: root._shown - index
            width: root.size; height: root.size

            readonly property var _item: root.model[index] ?? ({})
            readonly property string _initials: {
                var s  = String(_item.name ?? "?")
                var pp = s.split(/\s+/)
                if (pp.length >= 2) return (pp[0][0] + pp[pp.length-1][0]).toUpperCase()
                return s.substring(0, 2).toUpperCase()
            }

            Rectangle {
                anchors.fill:  parent
                radius:        root.size / 2
                color:         _item.color ?? Theme.primary
                border.color:  Theme.surface
                border.width:  2

                Image {
                    anchors.fill:  parent
                    source:        _item.src ?? ""
                    fillMode:      Image.PreserveAspectCrop
                    visible:       (_item.src ?? "") !== "" && status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text:           _initials
                    color:          "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Math.round(root.size * 0.32)
                    font.weight:    Theme.weightSemibold
                }
            }
        }
    }

    // Overflow chip
    Rectangle {
        visible:      root._overflow > 0
        x:            root._shown * (root.size - root.overlap)
        z:            0
        width:        root.size; height: root.size; radius: root.size / 2
        color:        Theme.surfaceVariant
        border.color: Theme.surface; border.width: 2

        Text {
            anchors.centerIn: parent
            text:           "+" + root._overflow
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Math.round(root.size * 0.28)
            font.weight:    Theme.weightSemibold
        }
    }
}
