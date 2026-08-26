pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// File path display with browse button and clear control.
//
// Usage:
//   FilePicker {
//       filePath:    "/home/user/doc.pdf"
//       buttonText:  "Browse…"
//       onBrowseClicked: openNativeFilePicker()
//       onCleared:       filePath = ""
//   }
Item {
    id: root

    property string filePath:    ""
    property string placeholder: "No file selected"
    property string buttonText:  "Browse…"

    signal browseClicked()
    signal cleared()

    implicitWidth:  320
    implicitHeight: 36

    Rectangle {
        id:    _pathBox
        anchors { left: parent.left; right: _browseBtn.left; top: parent.top; bottom: parent.bottom; rightMargin: 6 }
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        clip: true

        // Icon
        Text {
            id:    _fileIcon
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            text:           root.filePath !== "" ? "📄" : "📁"
            font.pixelSize: 13
        }

        Text {
            anchors { left: _fileIcon.right; right: _clrBtn.left
                      leftMargin: 6; rightMargin: 4; verticalCenter: parent.verticalCenter }
            text:  root.filePath !== "" ? root.filePath : root.placeholder
            color: root.filePath !== "" ? Theme.textPrimary : Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            elide: Text.ElideLeft
        }

        // Clear button
        Rectangle {
            id:      _clrBtn
            visible: root.filePath !== ""
            anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
            width: 18; height: 18; radius: 9
            color: _fpClH.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _fpClH }
            Text { anchors.centerIn: parent; text: "✕"; color: Theme.textDisabled; font.pixelSize: 8 }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: { root.filePath = ""; root.cleared() }
            }
        }
    }

    Rectangle {
        id:    _browseBtn
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: _brwTxt.implicitWidth + 20
        radius: Theme.radiusSm
        color:  _brwH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary
        Behavior on color { ColorAnimation { duration: 100 } }
        HoverHandler { id: _brwH }

        Text {
            id:    _brwTxt
            anchors.centerIn: parent
            text:           root.buttonText
            color:          Theme.textOnPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: root.browseClicked()
        }
    }
}
