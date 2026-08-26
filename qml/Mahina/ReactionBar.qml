pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Emoji reaction bar with counts and an add-reaction picker.
//
// Usage:
//   ReactionBar {
//       reactionItems: [
//           { emoji: "👍", count: 12, active: true  },
//           { emoji: "❤️", count: 5,  active: false },
//           { emoji: "😂", count: 3,  active: false },
//       ]
//       onReactionToggled: (emoji, active) => toggleReaction(emoji, active)
//   }
Item {
    id: root

    property var  reactionItems: []
    property bool showPicker:    false
    property var  pickerEmojis: ["👍","❤️","😂","😮","😢","😡","🎉","🔥","✨","👀","🙌","💯"]

    signal reactionToggled(string emoji, bool active)

    implicitWidth:  _row.implicitWidth
    implicitHeight: 36

    Row {
        id:     _row
        height: parent.height
        spacing: 6

        Repeater {
            model: root.reactionItems
            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index

                height:  30
                width:   _reacLabel.implicitWidth + 22
                radius:  Theme.radiusFull
                anchors.verticalCenter: parent.verticalCenter

                readonly property bool isActive: modelData.active || false

                color: isActive
                       ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                 Qt.color(Theme.primary).b, 0.12)
                       : (_rh.hovered ? Theme.panel : Theme.surfaceVariant)
                border.color: isActive ? Theme.primary : Theme.border; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }

                HoverHandler { id: _rh }

                Row {
                    id:     _reacLabel
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text:           _rq1.modelData.emoji || ""
                        font.pixelSize: 14
                    }
                    Text {
                        text:           (_rq1.modelData.count || 0).toString()
                        color:          _rq1.isActive ? Theme.primary : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Font.Medium
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var copy     = root.reactionItems.slice()
                        var newActive = !copy[_rq1.index].active
                        var delta    = newActive ? 1 : -1
                        copy[_rq1.index]  = Object.assign({}, copy[_rq1.index], {
                            active: newActive,
                            count:  (copy[_rq1.index].count || 0) + delta
                        })
                        root.reactionItems = copy
                        root.reactionToggled(_rq1.modelData.emoji || "", newActive)
                    }
                }
            }
        }

        // Add reaction button
        Rectangle {
            height:  30
            width:   30
            radius:  Theme.radiusFull
            color:   _addH.hovered ? Theme.panel : Theme.surfaceVariant
            border.color: Theme.border; border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 100 } }
            HoverHandler { id: _addH }

            Text {
                anchors.centerIn: parent
                text:           "+"
                color:          Theme.textSecondary
                font.pixelSize: Theme.textBase
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.showPicker = !root.showPicker
            }
        }
    }

    // Emoji picker popup
    Rectangle {
        visible: root.showPicker
        anchors { left: parent.left; bottom: parent.top; bottomMargin: 6 }
        width:  220; height: _pickerFlow.implicitHeight + 16
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        z: 10

        Flow {
            id:      _pickerFlow
            anchors { fill: parent; margins: 8 }
            spacing: 4

            Repeater {
                model: root.pickerEmojis
                delegate: Rectangle {
                    id: _rq2
                    required property string modelData
                    width: 32; height: 32; radius: 6
                    color: _ph.hovered ? Theme.panel : "transparent"
                    HoverHandler { id: _ph }
                    Text {
                        anchors.centerIn: parent
                        text:           _rq2.modelData
                        font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showPicker = false
                            // Find existing or add
                            var copy = root.reactionItems.slice()
                            var found = false
                            for (var i = 0; i < copy.length; i++) {
                                if (copy[i].emoji === _rq2.modelData) {
                                    copy[i] = Object.assign({}, copy[i], {
                                        active: true, count: (copy[i].count || 0) + 1
                                    })
                                    found = true
                                    break
                                }
                            }
                            if (!found) copy.push({ emoji: _rq2.modelData, count: 1, active: true })
                            root.reactionItems = copy
                            root.reactionToggled(_rq2.modelData, true)
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {} // consume to prevent close
        }
    }

    // Click outside to close picker
    MouseArea {
        visible: root.showPicker
        parent:  root.parent
        anchors.fill: parent
        z: -1
        onClicked: root.showPicker = false
    }
}
