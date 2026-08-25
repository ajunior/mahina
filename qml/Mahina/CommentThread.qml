import QtQuick
import Mahina

// Nested comment thread (2 levels: top-level comments + replies).
//
// Usage:
//   CommentThread {
//       threadComments: [
//           { id: "1", author: "Alice", initials:"AL", avatarColor:"#6366f1",
//             time: "2h ago", body: "Great work!", likes: 5,
//             replies: [
//               { id:"1a", author:"Bob", initials:"BO", avatarColor:"#0ea5e9",
//                 time:"1h ago", body:"Agreed!", likes:2, replies:[] }
//             ]
//           }
//       ]
//       onReplyClicked: (c) => openReplyBox(c)
//   }
Item {
    id: root

    property var threadComments: []

    signal replyClicked(var comment)
    signal likeClicked(var comment)

    implicitWidth:  480
    implicitHeight: _mainCol.implicitHeight

    // Single helper function avoids repeated logic
    function _avatar(bg, initials, sz) { return Qt.binding(function() { return bg }) }

    Column {
        id:     _mainCol
        width:  parent.width
        spacing: 0

        Repeater {
            model: root.threadComments
            delegate: Item {
                id:              _topLevel
                required property var  modelData
                required property int  index
                width:  root.width
                implicitHeight:  _commentBody.height + _repliesSection.height

                property bool repliesOpen: true

                // ── Comment body ──────────────────────────────────────────────
                Item {
                    id:     _commentBody
                    width:  root.width
                    height: _cbContent.height + 16

                    Item {
                        id:    _cbContent
                        width: root.width - 8
                        x:     4; y: 8
                        height: _cbAvatar.height + _cbTextCol.height + 4

                        Rectangle {
                            id:     _cbAvatar
                            width: 32; height: 32; radius: 16
                            color: Qt.color(_topLevel.modelData.avatarColor || Theme.primary)
                            Text {
                                anchors.centerIn: parent
                                text: _topLevel.modelData.initials || "?"
                                color: "white"; font.pixelSize: 11; font.weight: Font.Bold; font.family: Theme.fontFamily
                            }
                        }

                        Column {
                            id:     _cbTextCol
                            x:      42; y: 0
                            width:  parent.width - 42
                            spacing: 4

                            Row {
                                spacing: 8
                                Text {
                                    text:   _topLevel.modelData.author || ""
                                    color:  Theme.textPrimary
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                                }
                                Text {
                                    text:   _topLevel.modelData.time || ""
                                    color:  Theme.textDisabled
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                }
                            }

                            Text {
                                text:    _topLevel.modelData.body || ""
                                color:   Theme.textPrimary; wrapMode: Text.Wrap
                                font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                width:   parent.width
                            }

                            // Actions
                            Row {
                                spacing: Theme.sp3

                                Item {
                                    width: _likesRow.implicitWidth; height: 18
                                    Row {
                                        id:      _likesRow
                                        spacing: 4
                                        Text { text: "♥"; color: Theme.textDisabled; font.pixelSize: Theme.textXs }
                                        Text {
                                            text:  (_topLevel.modelData.likes || 0).toString()
                                            color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                        }
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.likeClicked(_topLevel.modelData) }
                                }

                                Item {
                                    width: _replyTxt.implicitWidth; height: 18
                                    Text { id: _replyTxt; text: "Reply"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.replyClicked(_topLevel.modelData) }
                                }

                                Item {
                                    visible: (_topLevel.modelData.replies || []).length > 0
                                    width:   _toggleTxt.implicitWidth; height: 18
                                    Text {
                                        id:     _toggleTxt
                                        text:   _topLevel.repliesOpen
                                                ? "Hide replies"
                                                : ((_topLevel.modelData.replies || []).length + " repl" +
                                                   ((_topLevel.modelData.replies || []).length === 1 ? "y" : "ies"))
                                        color:  Theme.primary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _topLevel.repliesOpen = !_topLevel.repliesOpen }
                                }
                            }
                        }
                    }
                }

                // ── Replies ───────────────────────────────────────────────────
                Item {
                    id:     _repliesSection
                    anchors.top: _commentBody.bottom
                    x:       28
                    width:   root.width - 28
                    visible: _topLevel.repliesOpen && (_topLevel.modelData.replies || []).length > 0
                    height:  visible ? _rCol.implicitHeight : 0

                    // Thread line
                    Rectangle {
                        width: 1; height: parent.height; color: Theme.border; x: 16
                    }

                    Column {
                        id:    _rCol
                        width: parent.width

                        Repeater {
                            model: _topLevel.modelData.replies || []
                            delegate: Item {
                                id: _rq1
                                required property var  modelData
                                width:  parent.width
                                height: _rpBody.height + _rpTextCol.height + 24

                                Item {
                                    id:    _rpBody
                                    width: parent.width - 8
                                    x: 8; y: 8
                                    height: 28

                                    Rectangle {
                                        width: 28; height: 28; radius: 14
                                        color: Qt.color(_rq1.modelData.avatarColor || Theme.primary)
                                        Text {
                                            anchors.centerIn: parent
                                            text: _rq1.modelData.initials || "?"; color: "white"
                                            font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily
                                        }
                                    }
                                }

                                Column {
                                    id:    _rpTextCol
                                    anchors.top: _rpBody.top
                                    x:     46
                                    width: parent.width - 46
                                    spacing: 4

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: _rq1.modelData.author || ""; color: Theme.textPrimary
                                            font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                                        }
                                        Text {
                                            text: _rq1.modelData.time || ""; color: Theme.textDisabled
                                            font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                        }
                                    }

                                    Text {
                                        text: _rq1.modelData.body || ""; color: Theme.textPrimary; wrapMode: Text.Wrap
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                        width: parent.width
                                    }

                                    Row {
                                        spacing: Theme.sp3
                                        Item {
                                            width: _rpLikesRow.implicitWidth; height: 18
                                            Row {
                                                id: _rpLikesRow; spacing: 4
                                                Text { text: "♥"; color: Theme.textDisabled; font.pixelSize: Theme.textXs }
                                                Text {
                                                    text:  (_rq1.modelData.likes || 0).toString()
                                                    color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                                }
                                            }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.likeClicked(_rq1.modelData) }
                                        }
                                        Item {
                                            width: _rpReplyTxt.implicitWidth; height: 18
                                            Text { id: _rpReplyTxt; text: "Reply"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.replyClicked(_rq1.modelData) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
