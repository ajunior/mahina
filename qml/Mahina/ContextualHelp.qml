pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Small ? button that opens an inline help popover on click.
//
// Usage:
//   Row {
//       Text { text: "API Key" }
//       ContextualHelp {
//           title: "What is an API key?"
//           body:  "A secret token used to authenticate requests. Keep it private."
//       }
//   }
Item {
    id: root

    property string title:    ""
    property string body:     ""
    property int    maxWidth: 260

    implicitWidth:  20
    implicitHeight: 20

    Rectangle {
        anchors.fill:  parent
        radius:        10
        color:         _hh.hovered ? Theme.hover : "transparent"
        border.color:  _hh.hovered ? Theme.border : "transparent"
        border.width:  1
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        HoverHandler { id: _hh }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: _pop.open()
        }

        Text {
            anchors.centerIn: parent
            text:           "?"
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Theme.weightSemibold
        }
    }

    QQC.Popup {
        id:          _pop
        parent:      root
        y:           root.height + Theme.sp2
        x:           -(root.maxWidth / 2 - root.width / 2)
        width:       root.maxWidth
        padding:     0
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        background: Rectangle {
            radius:       Theme.radiusMd
            color:        Theme.surface
            border.color: Theme.border; border.width: 1
        }

        Column {
            width: parent.width; padding: Theme.sp3; spacing: Theme.sp2

            Text {
                visible:        root.title !== ""
                width:          parent.width - Theme.sp3 * 2
                text:           root.title
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
                wrapMode:       Text.Wrap
            }

            Text {
                width:          parent.width - Theme.sp3 * 2
                text:           root.body
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                wrapMode:       Text.Wrap
                lineHeight:     1.5
                lineHeightMode: Text.ProportionalHeight
            }
        }
    }
}
