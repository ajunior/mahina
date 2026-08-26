pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Roster of online/away/offline members with activity status.
//
// Usage:
//   PresenceList {
//       heading: "Team Online"
//       members: [
//           { name: "Alice", initials: "AL", avatarColor: "#6366f1", status: "online",  lastSeen: "now"    },
//           { name: "Bob",   initials: "BO", avatarColor: "#0ea5e9", status: "away",    lastSeen: "5m ago"  },
//           { name: "Carol", initials: "CR", avatarColor: "#22c55e", status: "offline", lastSeen: "2h ago"  },
//       ]
//       onMemberClicked: (m) => openProfile(m)
//   }
Rectangle {
    id: root

    property string heading:    "Online"
    property var    members:    []
    property int    maxVisible: 8

    signal memberClicked(var member)

    function _statusColor(s) {
        switch (s) {
            case "online":       return Theme.success
            case "away":         return Theme.warning
            case "busy":         return Theme.error
            case "offline":      return Theme.textDisabled
            default:             return Theme.textDisabled
        }
    }

    implicitWidth:  240
    implicitHeight: _inner.implicitHeight + Theme.sp4 * 2

    radius: Theme.radiusMd
    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    Column {
        id:    _inner
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp4 }
        spacing: 0

        Row {
            width: parent.width; height: 28
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.heading
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Font.Medium
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width:  _onCnt.implicitWidth + 8; height: 16; radius: 8
                color:  Qt.rgba(Qt.color(Theme.success).r, Qt.color(Theme.success).g,
                                Qt.color(Theme.success).b, 0.15)
                Text {
                    id:             _onCnt
                    anchors.centerIn: parent
                    text: {
                        var c = 0
                        for (var i = 0; i < root.members.length; i++)
                            if (root.members[i].status === "online") c++
                        return c.toString()
                    }
                    color:          Theme.success
                    font.pixelSize: Theme.textXs; font.weight: Font.Bold; font.family: Theme.fontFamily
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        Repeater {
            model: root.members.length > root.maxVisible
                   ? root.members.slice(0, root.maxVisible) : root.members

            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index
                width:  parent.width; height: 40
                color:  _mH.hovered ? Theme.panel : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _mH }

                Row {
                    anchors { fill: parent; leftMargin: 0 }
                    spacing: 10

                    // Avatar + status dot
                    Item {
                        width: 30; height: parent.height

                        Rectangle {
                            width: 28; height: 28; radius: 14
                            anchors.centerIn: parent
                            color: Qt.color(_rq1.modelData.avatarColor || Theme.primary)
                            Text {
                                anchors.centerIn: parent
                                text: _rq1.modelData.initials || "?"
                                color: "white"; font.pixelSize: 10; font.weight: Font.Bold; font.family: Theme.fontFamily
                            }
                        }

                        Rectangle {
                            width: 9; height: 9; radius: 5
                            anchors { right: parent.right; bottom: parent.bottom; rightMargin: -1; bottomMargin: 5 }
                            color: root._statusColor(_rq1.modelData.status || "offline")
                            border.color: Theme.surface; border.width: 2
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            text:           _rq1.modelData.name || ""
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Font.Medium
                        }

                        Text {
                            text:           _rq1.modelData.lastSeen || _rq1.modelData.status || ""
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.memberClicked(_rq1.modelData)
                }
            }
        }

        // "+N more" pill
        Rectangle {
            visible: root.members.length > root.maxVisible
            width: parent.width; height: 32; color: "transparent"
            Text {
                anchors.centerIn: parent
                text:  "+" + (root.members.length - root.maxVisible) + " more"
                color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
            }
        }
    }
}
