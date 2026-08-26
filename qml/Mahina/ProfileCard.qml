pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// User profile card with avatar, bio, stats, and follow action.
//
// Usage:
//   ProfileCard {
//       name:           "Alice Nguyen"
//       role:           "Senior Designer"
//       bio:            "Crafting beautiful interfaces."
//       avatarInitials: "AN"
//       avatarColor:    "#6366f1"
//       stats:          [{ label: "Posts", value: "128" }, { label: "Followers", value: "4.2k" }]
//       isFollowing:    false
//       onFollowToggled: (f) => updateFollow(f)
//   }
Rectangle {
    id: root

    property string name:           ""
    property string role:           ""
    property string bio:            ""
    property string avatarSrc:      ""
    property string avatarInitials: ""
    property color  avatarColor:    Theme.primary
    property var    stats:          []
    property bool   isFollowing:    false
    property bool   showFollowBtn:  true

    signal followToggled(bool nowFollowing)

    implicitWidth:  280
    implicitHeight: _mainCol.implicitHeight + Theme.sp5 * 2

    radius: Theme.radiusLg
    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    Column {
        id:    _mainCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp5 }
        spacing: Theme.sp3

        // Avatar + name
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.sp2

            // Avatar
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 72; height: 72; radius: 36
                color: root.avatarColor

                Image {
                    anchors.fill: parent
                    source:  root.avatarSrc
                    visible: root.avatarSrc !== ""
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }
                Text {
                    anchors.centerIn: parent
                    visible:        root.avatarSrc === ""
                    text:           root.avatarInitials
                    color:          "white"
                    font.family:    Theme.fontFamily
                    font.pixelSize: 24
                    font.weight:    Font.Bold
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.name
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textBase
                font.weight:    Font.DemiBold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.role
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }
        }

        // Bio
        Text {
            visible:          root.bio !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            text:             root.bio
            color:            Theme.textSecondary
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.textSm
            wrapMode:         Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            width:            parent.width
        }

        // Stats row
        Row {
            visible:        root.stats.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            width: parent.width

            Repeater {
                model: root.stats
                delegate: Column {
                    id: _rq1
                    required property var modelData
                    required property int index
                    width: parent.width / Math.max(root.stats.length, 1)
                    spacing: 1

                    // Divider
                    Rectangle {
                        visible: _rq1.index > 0
                        width: 1; height: 32
                        color: Theme.border
                        anchors.left: parent.left
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           _rq1.modelData.value || "0"
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        font.weight:    Font.Bold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           _rq1.modelData.label || ""
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }
            }
        }

        // Follow button
        Rectangle {
            visible:  root.showFollowBtn
            width:    parent.width; height: 36; radius: Theme.radiusMd
            color:    root.isFollowing
                      ? (_followH.hovered ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.1) : Theme.surfaceVariant)
                      : (_followH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary)
            border.color: root.isFollowing ? Theme.primary : "transparent"; border.width: 1
            Behavior on color { ColorAnimation { duration: 120 } }
            HoverHandler { id: _followH }

            Text {
                anchors.centerIn: parent
                text:           root.isFollowing ? "Following" : "Follow"
                color:          root.isFollowing ? Theme.primary : Theme.textOnPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Font.Medium
            }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.isFollowing = !root.isFollowing
                    root.followToggled(root.isFollowing)
                }
            }
        }
    }
}
