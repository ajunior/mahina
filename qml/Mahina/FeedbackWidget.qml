pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Floating feedback button + popup form with rating + text.
//
// Usage:
//   FeedbackWidget {
//       anchors.bottom: parent.bottom
//       anchors.right:  parent.right
//       anchors.margins: 20
//       onSubmitted: (rating, message) => sendFeedback(rating, message)
//   }
Item {
    id: root

    property bool   isOpen:      false
    property string buttonLabel: "Feedback"
    property string placeholder: "Tell us what you think…"

    signal submitted(int rating, string message)

    implicitWidth:  44
    implicitHeight: 44

    property int  feedbackRating:  0
    property bool submitted_ok:    false

    // Trigger button
    Rectangle {
        id:     _trigger
        width:  _trigRow.implicitWidth + 20
        height: 36
        radius: Theme.radiusFull
        color:  _tH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary
        Behavior on color { ColorAnimation { duration: 120 } }
        HoverHandler { id: _tH }

        Row {
            id:      _trigRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text:           "✦"
                color:          Theme.textOnPrimary
                font.pixelSize: Theme.textSm
            }
            Text {
                text:           root.buttonLabel
                color:          Theme.textOnPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: root.isOpen = !root.isOpen
        }
    }

    // Popup card
    Rectangle {
        id:     _popup
        visible: root.isOpen
        width:  300
        height: _popupCol.implicitHeight + Theme.sp4 * 2
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border; border.width: 1

        // Position above trigger
        anchors { bottom: _trigger.top; right: _trigger.right; bottomMargin: 8 }

        opacity: root.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

        Column {
            id:    _popupCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp4 }
            spacing: Theme.sp3

            // Header
            Row {
                width: parent.width
                Text {
                    text:           "Share your feedback"
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Font.Medium
                    width:          parent.width - 24
                }
                Rectangle {
                    width: 20; height: 20; radius: 4
                    color: _closeH.hovered ? Theme.panel : "transparent"
                    HoverHandler { id: _closeH }
                    Text { anchors.centerIn: parent; text: "✕"; color: Theme.textSecondary; font.pixelSize: 10 }
                    MouseArea { anchors.fill: parent; onClicked: root.isOpen = false }
                }
            }

            // Star rating
            Column {
                spacing: 4
                Text {
                    text:           "How would you rate your experience?"
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
                Row {
                    spacing: 4
                    Repeater {
                        model: 5
                        delegate: Item {
                            id: _rq1
                            required property int index
                            width: 28; height: 28
                            Text {
                                anchors.centerIn: parent
                                text:           root.feedbackRating > _rq1.index ? "★" : "☆"
                                color:          root.feedbackRating > _rq1.index ? Theme.warning : Theme.textDisabled
                                font.pixelSize: 22
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.feedbackRating = _rq1.index + 1
                            }
                        }
                    }
                }
            }

            // Text area
            Rectangle {
                width:  parent.width
                height: 80
                radius: Theme.radiusSm
                color:  Theme.surfaceVariant
                border.color: _msgEdit.activeFocus ? Theme.primary : Theme.border
                border.width: 1

                Text {
                    anchors { fill: parent; margins: 8 }
                    text:    root.placeholder
                    visible: _msgEdit.text === ""
                    color:   Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }
                TextEdit {
                    id:             _msgEdit
                    anchors { fill: parent; margins: 8 }
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    wrapMode:       TextEdit.Wrap
                }
            }

            // Submit
            Rectangle {
                width:  parent.width; height: 36; radius: Theme.radiusMd
                color:  _submitH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: _submitH }
                Text {
                    anchors.centerIn: parent
                    text:           "Send feedback"
                    color:          Theme.textOnPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Font.Medium
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.submitted(root.feedbackRating, _msgEdit.text)
                        root.isOpen = false
                        root.feedbackRating = 0
                        _msgEdit.text = ""
                    }
                }
            }
        }
    }
}
