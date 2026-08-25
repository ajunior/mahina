import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string noteTitle: "Notes"
    property string noteText:  ""
    property bool   readOnly:  false

    signal noteSaved(string text)

    implicitWidth:  320
    implicitHeight: 240

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1

        Column {
            anchors.fill: parent
            spacing: 0

            // Title bar
            Rectangle {
                width:  parent.width
                height: 36
                radius: Theme.radiusMd
                color:  Theme.panel
                // Square bottom corners
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: Theme.radiusMd
                    color:  parent.color
                }

                Row {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                               leftMargin: Theme.sp3; rightMargin: Theme.sp2 }
                    spacing: Theme.sp2

                    Text {
                        text:  "📝"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id:    _titleInput
                        width: parent.width - 30 - Theme.sp2
                        anchors.verticalCenter: parent.verticalCenter
                        text:           root.noteTitle
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Font.Medium
                        readOnly:       root.readOnly
                        onEditingFinished: root.noteTitle = text
                    }
                }
            }

            Rectangle {
                width:  parent.width
                height: 1
                color:  Theme.border
            }

            // Body
            Flickable {
                id:    _flick
                width: parent.width
                height: root.height - 37
                contentWidth:  width
                contentHeight: Math.max(height, _edit.contentHeight + Theme.sp4)
                clip: true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                TextEdit {
                    id:      _edit
                    width:   _flick.width
                    padding: Theme.sp3
                    text:    root.noteText
                    color:   Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    wrapMode:  TextEdit.Wrap
                    readOnly:  root.readOnly
                    selectByMouse: true
                    Keys.onPressed: (e) => {
                        if ((e.modifiers & Qt.ControlModifier) && e.key === Qt.Key_S) {
                            root.noteText = text
                            root.noteSaved(text)
                            e.accepted = true
                        }
                    }
                    onTextChanged: root.noteText = text

                    Text {
                        visible: _edit.text === ""
                        anchors { left: parent.left; top: parent.top; margins: Theme.sp3 }
                        text:  "Start typing…"
                        color: Theme.textDisabled
                        font:  _edit.font
                    }
                }
            }
        }
    }
}
