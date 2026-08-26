pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Dims and locks content for users without the required permission.
//
// Usage:
//   PermissionGate {
//       locked:      !currentUser.isPro
//       lockMessage: "Upgrade to Pro to access this feature"
//       lockIcon:    "🔒"
//       onUnlockClicked: showUpgradeDialog()
//       Text { text: "Premium content" }
//   }
Item {
    id: root

    property bool   locked:      true
    property string lockMessage: "Upgrade to unlock"
    property string lockIcon:    "🔒"
    property string lockCta:     "Upgrade"

    signal unlockClicked()

    default property alias content: _gateContent.data

    implicitWidth:  300
    implicitHeight: 200

    // Content (dimmed when locked)
    Item {
        id:      _gateContent
        anchors.fill: parent
        opacity: root.locked ? 0.25 : 1.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
    }

    // Lock overlay
    Rectangle {
        anchors.fill: parent
        visible:  root.locked
        color:    Qt.rgba(Qt.color(Theme.surface).r,
                          Qt.color(Theme.surface).g,
                          Qt.color(Theme.surface).b, 0.6)
        opacity:  root.locked ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        Column {
            anchors.centerIn: parent
            spacing: Theme.sp3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.lockIcon
                font.pixelSize: 36
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.lockMessage
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Font.Medium
                horizontalAlignment: Text.AlignHCenter
                wrapMode:       Text.Wrap
                width:          root.width * 0.7
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width:  _ctaTxt.implicitWidth + 24; height: 36; radius: Theme.radiusMd
                color:  _ctaH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: _ctaH }
                Text {
                    id: _ctaTxt
                    anchors.centerIn: parent
                    text:           root.lockCta
                    color:          Theme.textOnPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Font.Medium
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.unlockClicked()
                }
            }
        }
    }
}
