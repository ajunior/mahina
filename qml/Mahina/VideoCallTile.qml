pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Video call participant tile with mute/camera state overlays.
//
// Usage:
//   VideoCallTile {
//       participantName: "Alice Nguyen"
//       initials:        "AN"
//       avatarColor:     "#6366f1"
//       muted:           true
//       videoOff:        false
//       isSpeaking:      true
//   }
Rectangle {
    id: root

    property string participantName: ""
    property string initials:        ""
    property color  avatarColor:     Theme.primary
    property bool   muted:           false
    property bool   videoOff:        true
    property bool   isSpeaking:      false
    property bool   isPinned:        false
    property bool   isLocal:         false

    implicitWidth:  200
    implicitHeight: 150

    radius: Theme.radiusMd
    color:  "#1a1a2e"
    clip:   true

    // Speaking ring
    Rectangle {
        anchors.fill: parent; radius: parent.radius
        border.color: root.isSpeaking ? Theme.success : "transparent"
        border.width: 3; color: "transparent"
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Video off: show avatar
    Column {
        visible: root.videoOff
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            width: 56; height: 56; radius: 28
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.avatarColor

            Text {
                anchors.centerIn: parent
                text:           root.initials
                color:          "white"
                font.pixelSize: 20; font.weight: Font.Bold; font.family: Theme.fontFamily
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           root.participantName
            color:          "white"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Font.Medium
        }
    }

    // Overlay bar (bottom)
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 32
        color:  Qt.rgba(0, 0, 0, 0.5)

        Row {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            spacing: 6

            // Mute icon
            Rectangle {
                visible: root.muted
                anchors.verticalCenter: parent.verticalCenter
                width: 18; height: 18; radius: 9
                color: Theme.error
                Text { anchors.centerIn: parent; text: "✕"; color: "white"; font.pixelSize: 9; font.weight: Font.Bold }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.participantName
                color:          "white"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                elide:          Text.ElideRight
                width:          parent.width - 60
            }

            Item { width: 1; height: 1 }

            // "You" badge
            Rectangle {
                visible: root.isLocal
                anchors.verticalCenter: parent.verticalCenter
                width: _youTxt.implicitWidth + 6; height: 14; radius: 3; color: Theme.primary
                Text { id: _youTxt; anchors.centerIn: parent; text: "You"; color: "white"; font.pixelSize: 8; font.weight: Font.Bold }
            }

            // Pinned badge
            Rectangle {
                visible: root.isPinned
                anchors.verticalCenter: parent.verticalCenter
                width: 18; height: 18; radius: 4; color: Theme.warning
                Text { anchors.centerIn: parent; text: "📌"; font.pixelSize: 9 }
            }
        }
    }

    // Speaking animation dots
    Row {
        visible: root.isSpeaking && !root.videoOff
        anchors { top: parent.top; right: parent.right; margins: 8 }
        spacing: 3

        Repeater {
            model: 3
            delegate: Rectangle {
                id: _rq1
                required property int index
                width: 4; height: 4; radius: 2
                color: Theme.success

                SequentialAnimation on opacity {
                    loops: Animation.Infinite; running: root.isSpeaking
                    PauseAnimation      { duration: _rq1.index * 100 }
                    NumberAnimation     { to: 1;   duration: 200 }
                    NumberAnimation     { to: 0.2; duration: 200 }
                    PauseAnimation      { duration: (2 - _rq1.index) * 100 }
                }
            }
        }
    }
}
