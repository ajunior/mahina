import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Chronological activity / notification feed with avatars, actions, and timestamps.
//
// Usage:
//   ActivityFeed {
//       events: [
//           { user: "Alice", avatar: "", action: "pushed to main",    time: "2m ago",  color: Theme.success },
//           { user: "Bob",   avatar: "", action: "opened a PR",       time: "14m ago", color: Theme.primary },
//           { user: "CI",    avatar: "", action: "build failed",      time: "32m ago", color: Theme.danger  },
//       ]
//   }
Item {
    id: root

    property var events:    []
    property bool showDividers: true
    property int  avatarSize:   32

    implicitWidth:  360
    implicitHeight: 400

    QQC.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        Column {
            width: parent.width
            spacing: 0

            Repeater {
                model: root.events
                delegate: Item {
                    id: _rq1
                    required property var  modelData
                    required property int  index

                    width: parent.width
                    height: _row.implicitHeight + Theme.sp3 * 2

                    // Divider
                    Rectangle {
                        visible:     root.showDividers && _rq1.index > 0
                        width:       parent.width; height: 1
                        color:       Theme.border
                        anchors.top: parent.top
                    }

                    Row {
                        id:     _row
                        anchors {
                            left: parent.left; right: parent.right
                            leftMargin: Theme.sp4; rightMargin: Theme.sp4
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: Theme.sp3

                        // Avatar circle
                        Rectangle {
                            width:  root.avatarSize; height: root.avatarSize; radius: root.avatarSize / 2
                            color:  _rq1.modelData.color ?? Theme.primary
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text:           (_rq1.modelData.avatar ?? "") !== "" ? _rq1.modelData.avatar
                                                : (_rq1.modelData.user ?? "?").charAt(0).toUpperCase()
                                color:          "#ffffff"
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                font.weight:    Theme.weightBold
                            }
                        }

                        // Text area
                        Column {
                            spacing: Theme.sp1
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - root.avatarSize - Theme.sp3

                            Row {
                                spacing: Theme.sp1
                                width: parent.width

                                Text {
                                    text:           _rq1.modelData.user ?? ""
                                    color:          Theme.textPrimary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                    font.weight:    Theme.weightSemibold
                                }
                                Text {
                                    text:           _rq1.modelData.action ?? ""
                                    color:          Theme.textSecondary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                    width:          parent.width - _userText.implicitWidth - _timeText.implicitWidth - Theme.sp2 * 2
                                    elide:          Text.ElideRight
                                }
                            }

                            Text {
                                id:             _timeText
                                text:           _rq1.modelData.time ?? ""
                                color:          Theme.textDisabled
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                            }
                        }
                    }

                    // Hidden ref to avoid duplicate id warning
                    Text { id: _userText; visible: false; text: _rq1.modelData.user ?? ""; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                }
            }
        }
    }
}
