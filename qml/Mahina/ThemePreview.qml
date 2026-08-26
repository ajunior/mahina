pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    implicitWidth:  560
    implicitHeight: 420

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Header with dark toggle
            Rectangle {
                width: parent.width; height: 40
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text { text: "◑"; color: Theme.primary; font.pixelSize: 14 }
                    Text { text: "Theme Preview"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium }
                    Text { text: Theme.dark ? "(Dark)" : "(Light)"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                }
                Rectangle {
                    anchors { right: parent.right; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    width: 52; height: 24; radius: Theme.radiusFull
                    color: Theme.dark ? Theme.primary : Theme.border
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: 18; height: 18; radius: Theme.radiusFull; color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                        x: Theme.dark ? 32 : 2
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Theme.dark = !Theme.dark }
                }
            }

            Flickable {
                width:  parent.width
                height: root.height - 40
                contentWidth:  width
                contentHeight: _previewCol.implicitHeight + Theme.sp8
                clip: true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                Column {
                    id:      _previewCol
                    width:   parent.width
                    padding: Theme.sp4
                    spacing: Theme.sp5

                    // Section: Colors
                    Column {
                        width: parent.width - Theme.sp4 * 2
                        spacing: Theme.sp3
                        Text { text: "Colors"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Row {
                            spacing: Theme.sp2
                            Repeater {
                                model: [
                                    { name: "Primary", color: Theme.primary },
                                    { name: "Info",    color: Theme.info    },
                                    { name: "Success", color: Theme.success },
                                    { name: "Warning", color: Theme.warning },
                                    { name: "Error",   color: Theme.error   },
                                    { name: "Border",  color: Theme.border  },
                                    { name: "Panel",   color: Theme.panel   },
                                ]
                                delegate: Column {
                                    id: _rq1
                                    required property var modelData
                                    spacing: 4
                                    Rectangle {
                                        width: 56; height: 32; radius: Theme.radiusSm
                                        color: _rq1.modelData.color; border.color: Theme.border; border.width: 1
                                    }
                                    Text {
                                        text: _rq1.modelData.name; color: Theme.textSecondary
                                        font { family: Theme.fontFamily; pixelSize: 10 }
                                        width: 56; horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }

                    // Section: Typography
                    Column {
                        width: parent.width - Theme.sp4 * 2
                        spacing: Theme.sp3
                        Text { text: "Typography"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Column {
                            spacing: Theme.sp2
                            Text { text: "Heading — 20px Medium";  color: Theme.textPrimary; font { family: Theme.fontFamily; pixelSize: Theme.textXl;   weight: Font.Medium } }
                            Text { text: "Subheading — 17px";       color: Theme.textPrimary; font { family: Theme.fontFamily; pixelSize: Theme.textLg  } }
                            Text { text: "Body — 15px Regular";     color: Theme.textPrimary; font { family: Theme.fontFamily; pixelSize: Theme.textBase } }
                            Text { text: "Small — 13px";            color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: Theme.textSm } }
                            Text { text: "const code = 'monospace'";color: Theme.primary; font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm } }
                        }
                    }

                    // Section: Buttons
                    Column {
                        width: parent.width - Theme.sp4 * 2
                        spacing: Theme.sp3
                        Text { text: "Buttons"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Row {
                            spacing: Theme.sp3
                            Button { text: "Primary";  variant: Button.Variant.Filled   }
                            Button { text: "Outlined"; variant: Button.Variant.Outlined }
                            Button { text: "Ghost";    variant: Button.Variant.Ghost    }
                            Button { text: "Danger";   variant: Button.Variant.Danger   }
                        }
                    }

                    // Section: Badges & Progress
                    Column {
                        width: parent.width - Theme.sp4 * 2
                        spacing: Theme.sp3
                        Text { text: "Badges & Progress"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Column {
                            spacing: Theme.sp3
                            Row {
                                spacing: Theme.sp2
                                Badge { text: "Default";  colorScheme: Badge.Color.Default  }
                                Badge { text: "Primary";  colorScheme: Badge.Color.Primary  }
                                Badge { text: "Success";  colorScheme: Badge.Color.Success  }
                                Badge { text: "Warning";  colorScheme: Badge.Color.Warning  }
                                Badge { text: "Error";    colorScheme: Badge.Color.Error    }
                                Badge { text: "Info";     colorScheme: Badge.Color.Info     }
                            }
                            ProgressBar { value: 0.65; showValue: true; width: parent.width }
                        }
                    }

                    // Section: Surface layers
                    Column {
                        width: parent.width - Theme.sp4 * 2
                        spacing: Theme.sp3
                        Text { text: "Surface Layers"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Row {
                            spacing: Theme.sp3
                            Repeater {
                                model: [
                                    { name: "panel",    color: Theme.panel          },
                                    { name: "surface",  color: Theme.surface        },
                                    { name: "variant",  color: Theme.surfaceVariant },
                                    { name: "border",   color: Theme.border         },
                                ]
                                delegate: Column {
                                    id: _rq2
                                    required property var modelData
                                    spacing: 4
                                    Rectangle {
                                        width: 100; height: 40; radius: Theme.radiusSm
                                        color: _rq2.modelData.color; border.color: Theme.border; border.width: 1
                                        Text { anchors.centerIn: parent; text: _rq2.modelData.name; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11 } }
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
