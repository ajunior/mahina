import QtQuick
import QtQuick.Controls
import QtQuick.Controls as QQC
import Mahina

// Organized shortcut reference overlay, opened with a trigger key.
//
// Usage:
//   KeyboardShortcutsPanel {
//       id: _shortcuts
//       sections: [
//           { heading: "Navigation", shortcuts: [
//               { keys: ["Ctrl", "K"],   desc: "Open command bar"  },
//               { keys: ["?"],           desc: "Show this panel"   },
//           ]},
//           { heading: "Editing", shortcuts: [
//               { keys: ["Ctrl", "Z"],   desc: "Undo"              },
//               { keys: ["Ctrl", "S"],   desc: "Save"              },
//           ]},
//       ]
//   }
//   Shortcut { sequence: "?"; onActivated: _shortcuts.open = true }
Item {
    id: root

    property bool open:        false
    property bool closeOnEsc:  true
    property var  sections:    []

    function show() { open = true }
    function hide() { open = false }

    QQC.Popup {
        anchors.centerIn: Overlay.overlay
        visible:     root.open
        modal:       true
        padding:     0
        width:       560
        height:      Math.min(520, Overlay.overlay ? Overlay.overlay.height * 0.85 : 520)
        closePolicy: (root.closeOnEsc ? QQC.Popup.CloseOnEscape : 0) | QQC.Popup.CloseOnPressOutside
        onClosed:    root.open = false

        background: Rectangle {
            radius:       Theme.radiusLg
            color:        Theme.surface
            border.color: Theme.border
            border.width: 1
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                width: parent.width; height: 52
                color: "transparent"
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp5; rightMargin: Theme.sp4 }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  "Keyboard Shortcuts"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textLg
                        font.weight: Theme.weightSemibold
                    }
                    Item { width: 1; height: 1 }
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: Theme.panel
                        anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "✕"; color: Theme.textSecondary; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; onClicked: root.open = false }
                    }
                }
            }
            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Sections
            QQC.ScrollView {
                width:  parent.width
                height: parent.height - 53
                clip:   true
                contentWidth: availableWidth

                Column {
                    width: parent.width
                    padding: Theme.sp4
                    spacing: Theme.sp5

                    Repeater {
                        model: root.sections
                        delegate: Column {
                            id: _rq1
                            required property var  modelData
                            width: parent.width - Theme.sp4 * 2
                            spacing: Theme.sp2

                            Text {
                                text:  _rq1.modelData.heading ?? ""
                                color: Theme.textDisabled
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight: Theme.weightSemibold
                                bottomPadding: Theme.sp1
                            }

                            Repeater {
                                model: _rq1.modelData.shortcuts ?? []
                                delegate: Rectangle {
                                    id: _rq2
                                    required property var  modelData
                                    required property int  index
                                    width:  parent.width; height: 36
                                    radius: Theme.radiusSm
                                    color:  index % 2 === 0 ? "transparent" : Qt.rgba(Qt.color(Theme.panel).r, Qt.color(Theme.panel).g, Qt.color(Theme.panel).b, 0.5)

                                    Row {
                                        anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text:  _rq2.modelData.desc ?? ""
                                            color: Theme.textSecondary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.textSm
                                            width: parent.width - _keysRow.implicitWidth
                                        }

                                        Row {
                                            id:     _keysRow
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Theme.sp1

                                            Repeater {
                                                model: _rq2.modelData.keys ?? []
                                                delegate: ShortcutHint {
                                                    required property string modelData
                                                    keys:  [modelData]
                                                    size:  "sm"
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
    }
}
