import QtQuick
import Mahina

// Slack-style message bubble with inline reactions and reply count.
//
// Usage:
//   ThreadedMessage {
//       author:      "Alice"
//       initials:    "AL"
//       avatarColor: "#6366f1"
//       body:        "Just deployed the new component library 🚀"
//       time:        "10:34 AM"
//       msgReactions: [{ emoji:"🚀", count:4, active:true }, { emoji:"❤️", count:2, active:false }]
//       replyCount:  3
//       onReplyClicked: openThread()
//   }
Item {
    id: root

    property string author:       ""
    property string initials:     ""
    property color  avatarColor:  Theme.primary
    property string body:         ""
    property string time:         ""
    property bool   isBot:        false
    property var    msgReactions: []
    property int    replyCount:   0

    signal replyClicked()
    signal reactionClicked(string emoji)

    implicitWidth:  480
    implicitHeight: _msgContent.implicitHeight + 12

    // Hover to show actions
    property bool hovered: false
    HoverHandler { onHoveredChanged: root.hovered = hovered }

    Item {
        id:    _msgContent
        width: parent.width
        implicitHeight: _avatarRect.height + _bodyCol.implicitHeight + 8 +
                        (root.msgReactions.length > 0 ? _reactionRow.height + 4 : 0) +
                        (root.replyCount > 0 ? _replyBtn.height + 4 : 0)

        Rectangle {
            id:     _avatarRect
            width:  32; height: 32; radius: root.isBot ? 8 : 16
            color:  root.avatarColor
            x: 0; y: 4
            Text {
                anchors.centerIn: parent
                text:           root.isBot ? "⚙" : root.initials
                color:          "white"
                font.pixelSize: 11; font.weight: Font.Bold; font.family: Theme.fontFamily
            }
        }

        Column {
            id:    _bodyCol
            x:     44; y: 0
            width: parent.width - 44
            spacing: 2

            Row {
                spacing: 8
                Text {
                    text:           root.author
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Font.Medium
                }
                Rectangle {
                    visible: root.isBot
                    anchors.verticalCenter: parent.verticalCenter
                    width: _botTag.implicitWidth + 6; height: 14; radius: 3
                    color: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                   Qt.color(Theme.primary).b, 0.15)
                    Text { id: _botTag; anchors.centerIn: parent; text: "APP"; color: Theme.primary; font.pixelSize: 8; font.weight: Font.Bold }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           root.time
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
            }

            Text {
                text:           root.body
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                wrapMode:       Text.Wrap
                width:          parent.width
            }
        }

        // Reactions
        Row {
            id:      _reactionRow
            visible: root.msgReactions.length > 0
            x:       44
            anchors.top: _bodyCol.bottom; anchors.topMargin: 4
            spacing: 4

            Repeater {
                model: root.msgReactions
                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    height: 24; width: _rLbl.implicitWidth + 12; radius: 12
                    color: modelData.active
                           ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                     Qt.color(Theme.primary).b, 0.12)
                           : Theme.surfaceVariant
                    border.color: modelData.active ? Theme.primary : Theme.border; border.width: 1

                    Row {
                        id: _rLbl; anchors.centerIn: parent; spacing: 4
                        Text { text: _rq1.modelData.emoji || ""; font.pixelSize: 13 }
                        Text {
                            text: (_rq1.modelData.count || 0).toString()
                            color: _rq1.modelData.active ? Theme.primary : Theme.textSecondary
                            font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; font.weight: Font.Medium
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.reactionClicked(_rq1.modelData.emoji || "") }
                }
            }
        }

        // Reply count button
        Item {
            id:      _replyBtn
            visible: root.replyCount > 0
            x:       44
            anchors.top: root.msgReactions.length > 0 ? _reactionRow.bottom : _bodyCol.bottom
            anchors.topMargin: 4
            width:   _replyRow.implicitWidth; height: 20

            Row {
                id: _replyRow; spacing: 4
                Text { text: "↩"; color: Theme.primary; font.pixelSize: 11 }
                Text {
                    text: root.replyCount + " repl" + (root.replyCount === 1 ? "y" : "ies")
                    color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; font.weight: Font.Medium
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.replyClicked() }
        }
    }
}
