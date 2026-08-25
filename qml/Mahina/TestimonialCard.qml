import QtQuick
import Mahina

// Quote card with avatar, name, role, and star rating.
//
// Usage:
//   TestimonialCard {
//       quote:  "Mahina cut our UI development time in half."
//       name:   "Alice Chen"
//       role:   "CTO, Acme Corp"
//       rating: 5
//       avatarColor: Theme.primary
//   }
Item {
    id: root

    property string quote:       ""
    property string name:        ""
    property string role:        ""
    property int    rating:      5
    property color  avatarColor: Theme.primary
    property string avatarSrc:   ""
    property string avatarInitial: root.name.charAt(0).toUpperCase()

    implicitWidth:  280
    implicitHeight: _inner.implicitHeight + Theme.sp5 * 2

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusLg
        color:         Theme.surface
        border.color:  Theme.border
        border.width:  1

        Column {
            id:     _inner
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp5 }
            spacing: Theme.sp4

            // Stars
            Row {
                spacing: Theme.sp1
                Repeater {
                    model: 5
                    delegate: Text {
                        required property int index
                        text:  "★"
                        color: index < root.rating ? "#F59E0B" : Theme.border
                        font.pixelSize: Theme.textBase
                    }
                }
            }

            // Quote
            Text {
                text:           "\"" + root.quote + "\""
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                wrapMode:       Text.Wrap
                width:          parent.width
                lineHeight:     Theme.lineHeightRelaxed
                lineHeightMode: Text.ProportionalHeight
            }

            // Author row
            Row {
                spacing: Theme.sp3
                width:   parent.width

                // Avatar
                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: root.avatarColor

                    Image {
                        anchors.fill: parent
                        source:       root.avatarSrc
                        fillMode:     Image.PreserveAspectCrop
                        visible:      root.avatarSrc !== ""
                    }

                    Text {
                        visible:        root.avatarSrc === ""
                        anchors.centerIn: parent
                        text:           root.avatarInitial
                        color:          "#ffffff"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        font.weight:    Theme.weightBold
                    }
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text:        root.name
                        color:       Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight: Theme.weightSemibold
                    }
                    Text {
                        visible:     root.role !== ""
                        text:        root.role
                        color:       Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }
            }
        }
    }
}
