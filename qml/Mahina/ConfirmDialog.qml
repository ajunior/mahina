pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Destructive-action confirmation dialog with icon, message and labelled buttons.
//
// Usage:
//   ConfirmDialog {
//       id:              _dlg
//       dialogTitle:     "Delete project?"
//       dialogMessage:   "This action cannot be undone. All files will be permanently deleted."
//       confirmText:     "Delete"
//       isDestructive:   true
//       onConfirmed:     deleteProject()
//       onCancelled:     { /* nothing */ }
//   }
//   Button { onClicked: _dlg.open() }
Item {
    id: root

    property string dialogTitle:   "Are you sure?"
    property string dialogMessage: "This action cannot be undone."
    property string confirmText:   "Confirm"
    property string cancelText:    "Cancel"
    property bool   isDestructive: false
    property string dialogIcon:    ""
    property bool   isOpen:        false

    signal confirmed()
    signal cancelled()

    function open(): void { root.isOpen = true  }
    function close(): void { root.isOpen = false }

    anchors.fill: parent
    visible:      root.isOpen

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color:   Qt.rgba(0, 0, 0, 0.45)
        opacity: root.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        MouseArea { anchors.fill: parent }   // block clicks through
    }

    // Dialog card
    Rectangle {
        anchors.centerIn: parent
        width:  Math.min(420, parent.width - 48)
        height: _dlgCol.implicitHeight + Theme.sp6 * 2
        radius: Theme.radiusLg
        color:  Theme.surface
        border.color: Theme.border; border.width: 1

        scale:   root.isOpen ? 1.0 : 0.92
        opacity: root.isOpen ? 1.0 : 0.0
        Behavior on scale   { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutBack; easing.overshoot: 0.6 } }
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        Column {
            id:    _dlgCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp6 }
            spacing: Theme.sp3

            // Icon (optional)
            Text {
                visible:        root.dialogIcon !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.dialogIcon
                font.pixelSize: 36
            }

            // Title
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                text:                root.dialogTitle
                color:               root.isDestructive ? Theme.error : Theme.textPrimary
                font.family:         Theme.fontFamily
                font.pixelSize:      Theme.textLg
                font.weight:         Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode:            Text.Wrap
            }

            // Message
            Text {
                width: parent.width
                text:                root.dialogMessage
                color:               Theme.textSecondary
                font.family:         Theme.fontFamily
                font.pixelSize:      Theme.textSm
                horizontalAlignment: Text.AlignHCenter
                wrapMode:            Text.Wrap
            }

            // Buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.sp3
                topPadding: Theme.sp2

                // Cancel
                Rectangle {
                    width:  _cancelTxt.implicitWidth + 32; height: 38
                    radius: Theme.radiusMd
                    color:  _canH.hovered ? Theme.panel : Theme.surfaceVariant
                    border.color: Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _canH }
                    Text {
                        id:    _cancelTxt
                        anchors.centerIn: parent
                        text:           root.cancelText
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Font.Medium
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.close(); root.cancelled() }
                    }
                }

                // Confirm
                Rectangle {
                    width:  _confirmTxt.implicitWidth + 32; height: 38
                    radius: Theme.radiusMd
                    color: {
                        var base = root.isDestructive ? Theme.error : Theme.primary
                        return _cfmH.hovered ? Qt.darker(base, 1.12) : base
                    }
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _cfmH }
                    Text {
                        id:    _confirmTxt
                        anchors.centerIn: parent
                        text:           root.confirmText
                        color:          Theme.textOnPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Font.Medium
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.close(); root.confirmed() }
                    }
                }
            }
        }
    }
}
