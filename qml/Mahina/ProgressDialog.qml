pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Controls as QQC
import Mahina

// Modal dialog with a progress bar, step label, and optional cancel.
//
// Usage:
//   ProgressDialog {
//       id: _pd
//       title:   "Uploading files"
//       message: "Uploading 3 of 12…"
//       progress: 0.25
//       cancelable: true
//       onCancelClicked: upload.cancel()
//   }
//   _pd.open()
Item {
    id: root

    property string title:      "Please wait"
    property string message:    ""
    property real   progress:   0      // 0..1
    property bool   indeterminate: false
    property bool   cancelable: false
    property bool   open:       false

    signal cancelClicked()

    function show() { root.open = true }
    function close() { root.open = false }

    QQC.Popup {
        anchors.centerIn: Overlay.overlay
        visible:     root.open
        modal:       true
        padding:     0
        width:       340
        closePolicy: QQC.Popup.NoAutoClose

        onClosed: root.open = false

        background: Rectangle {
            radius: Theme.radiusLg
            color:  Theme.surface
            border.color: Theme.border; border.width: 1
        }

        Column {
            width: parent.width
            padding: Theme.sp5
            spacing: Theme.sp4

            Text {
                text:           root.title
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textLg
                font.weight:    Theme.weightSemibold
                width:          parent.width - parent.padding * 2
            }

            ProgressBar {
                width:         parent.width - parent.padding * 2
                value:         root.indeterminate ? 0.5 : root.progress
                indeterminate: root.indeterminate
            }

            Row {
                width: parent.width - parent.padding * 2
                spacing: Theme.sp2

                Text {
                    visible:        root.message !== ""
                    text:           root.message
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    width:          root.cancelable ? parent.width - 80 - Theme.sp2 : parent.width
                    elide:          Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    visible: !root.indeterminate
                    text:    Math.round(root.progress * 100) + "%"
                    color:   Theme.textDisabled
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 }

                Rectangle {
                    visible: root.cancelable
                    width: 70; height: 28; radius: Theme.radiusMd
                    color: Theme.panel
                    Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                    MouseArea { anchors.fill: parent; onClicked: root.cancelClicked() }
                }
            }
        }
    }
}
