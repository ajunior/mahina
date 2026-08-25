import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Chat message list with bubbles aligned left (received) or right (sent).
//
// Usage:
//   Chat {
//       selfId: "alice"
//       messages: [
//           { sender: "bob",   text: "Hey, how's it going?",    timestamp: "10:41 AM" },
//           { sender: "alice", text: "Pretty good! You?",       timestamp: "10:42 AM" },
//           { sender: "bob",   text: "Great, just shipped v2.", timestamp: "10:43 AM" },
//       ]
//   }
//
// Each message: { sender, text, timestamp?, avatar? }
Item {
    id: root

    property string selfId:   ""
    property var    messages: []
    property bool   showTimestamps: true
    property bool   showAvatars:    true
    property bool   showSenderName: true

    implicitWidth:  400
    implicitHeight: 400

    ListView {
        id:           _list
        anchors.fill: parent
        clip:         true
        model:        root.messages
        spacing:      Theme.sp2
        topMargin:    Theme.sp3
        bottomMargin: Theme.sp3

        QQC.ScrollBar.vertical: QQC.ScrollBar {
            contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
            background:  Rectangle { color: "transparent" }
        }

        onCountChanged: Qt.callLater(() => positionViewAtEnd())

        delegate: Item {
            id: _rq1
            required property var modelData
            required property int index

            readonly property bool _isSelf: modelData.sender === root.selfId
            readonly property bool _showName: root.showSenderName && !_isSelf
            readonly property string _initials: {
                var s = String(modelData.sender ?? "?")
                var parts = s.split(/\s+/)
                if (parts.length >= 2) return (parts[0][0] + parts[parts.length-1][0]).toUpperCase()
                return s.substring(0, 2).toUpperCase()
            }

            width:  _list.width
            height: _bubble.height + (_showName ? _nameText.height + Theme.sp1 : 0) +
                    (root.showTimestamps ? _tsText.height + 2 : 0) + Theme.sp2

            // Sender name (received only)
            Text {
                id:             _nameText
                visible:        _showName
                anchors {
                    top:        parent.top
                    left:       parent.left
                    leftMargin: root.showAvatars ? 44 : Theme.sp3
                }
                text:           _rq1.modelData.sender ?? ""
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                font.weight:    Theme.weightMedium
            }

            // Avatar
            Rectangle {
                id:      _avatar
                visible: root.showAvatars && !_isSelf
                anchors {
                    bottom: _bubble.bottom
                    left:   parent.left
                    leftMargin: Theme.sp3
                }
                width:  32; height: 32; radius: 16
                color:  Theme.primary

                Text {
                    anchors.centerIn: parent
                    text:           _initials
                    color:          "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightSemibold
                }
            }

            // Bubble
            Rectangle {
                id:      _bubble
                anchors {
                    top:        _showName ? _nameText.bottom : parent.top
                    topMargin:  _showName ? Theme.sp1 : 0
                    left:       _isSelf ? undefined : (root.showAvatars ? _avatar.right : parent.left)
                    right:      _isSelf ? parent.right : undefined
                    leftMargin: _isSelf ? 0 : Theme.sp2
                    rightMargin: _isSelf ? Theme.sp3 : 0
                }
                width:  Math.min(_msgText.implicitWidth + Theme.sp4 * 2,
                                 _list.width * 0.72 - (root.showAvatars && !_isSelf ? 44 : Theme.sp3))
                height: _msgText.implicitHeight + Theme.sp3 * 2
                radius: Theme.radiusLg
                color:  _isSelf ? Theme.primary : Theme.surface
                border.color: _isSelf ? "transparent" : Theme.border
                border.width: _isSelf ? 0 : 1

                Text {
                    id:      _msgText
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top; bottom: parent.bottom
                        margins: Theme.sp3
                    }
                    text:           _rq1.modelData.text ?? ""
                    color:          _isSelf ? "#ffffff" : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    wrapMode:       Text.Wrap
                    lineHeight:     1.5
                    lineHeightMode: Text.ProportionalHeight
                }
            }

            // Timestamp
            Text {
                id:      _tsText
                visible: root.showTimestamps
                anchors {
                    top:         _bubble.bottom
                    topMargin:   2
                    left:        _isSelf ? undefined : _bubble.left
                    right:       _isSelf ? _bubble.right : undefined
                }
                text:           _rq1.modelData.timestamp ?? ""
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }
}
