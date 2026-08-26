pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Bell icon with badge and bounce animation on new notification.
//
// Usage:
//   NotificationBell {
//       bellCount: 5
//       onClicked: showNotificationPanel()
//   }
Item {
    id: root

    property int  bellCount: 0
    property bool hasNew:    false

    signal clicked()

    implicitWidth:  36
    implicitHeight: 36

    // Trigger bounce when count increases
    property int prevCount: 0
    onBellCountChanged: {
        if (root.bellCount > root.prevCount) {
            root.hasNew = true
            _bounceAnim.restart()
        }
        root.prevCount = root.bellCount
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  _bellH.hovered ? Theme.panel : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }
        HoverHandler { id: _bellH }

        Text {
            id:             _bellIcon
            anchors.centerIn: parent
            text:           "🔔"
            font.pixelSize: 18
            transformOrigin: Item.Top

            SequentialAnimation {
                id: _bounceAnim
                NumberAnimation { target: _bellIcon; property: "rotation"; from: 0; to: 15;  duration: 80 }
                NumberAnimation { target: _bellIcon; property: "rotation"; from: 15; to: -15; duration: 100 }
                NumberAnimation { target: _bellIcon; property: "rotation"; from: -15; to: 10; duration: 80 }
                NumberAnimation { target: _bellIcon; property: "rotation"; from: 10; to: -8;  duration: 60 }
                NumberAnimation { target: _bellIcon; property: "rotation"; from: -8; to: 0;   duration: 60 }
            }
        }

        // Badge
        Rectangle {
            visible:  root.bellCount > 0
            anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 4 }
            width:   _badgeNum.implicitWidth + 5
            height:  15; radius: 8
            color:   root.hasNew ? Theme.error : Theme.textDisabled
            Behavior on color { ColorAnimation { duration: 300 } }

            Text {
                id:             _badgeNum
                anchors.centerIn: parent
                text:           root.bellCount > 99 ? "99+" : root.bellCount.toString()
                color:          "white"
                font.pixelSize: 8; font.weight: Font.Bold; font.family: Theme.fontFamily
            }
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.hasNew = false
                root.clicked()
            }
        }
    }
}
