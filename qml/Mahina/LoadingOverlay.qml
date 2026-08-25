import QtQuick
import Mahina

// Full-area dim + spinner overlay. Place over any content to block interaction.
//
// Usage:
//   Item {
//       SomeContent { }
//       LoadingOverlay { visible: isLoading; message: "Saving…" }
//   }
Item {
    id: root

    property string message:    ""
    property bool   cancelable: false
    property color  overlayColor: Qt.rgba(0, 0, 0, 0.45)

    signal cancelClicked()

    visible: false

    Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
    opacity: visible ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color:        root.overlayColor
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.sp4

        Spinner {
            anchors.horizontalCenter: parent.horizontalCenter
            size: 40
            color: "#ffffff"
        }

        Text {
            visible:          root.message !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            text:             root.message
            color:            "#ffffff"
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.textSm
            font.weight:      Theme.weightMedium
        }

        Rectangle {
            visible:    root.cancelable
            anchors.horizontalCenter: parent.horizontalCenter
            width:  80; height: 30; radius: Theme.radiusMd
            color:  Qt.rgba(1, 1, 1, 0.15)

            Text {
                anchors.centerIn: parent
                text:  "Cancel"
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            MouseArea { anchors.fill: parent; onClicked: root.cancelClicked() }
        }
    }

    MouseArea { anchors.fill: parent }  // block click-through
}
