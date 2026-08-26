pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // colorTokens: [{name, value: "#RRGGBB", description}]
    property var    colorTokens: []
    property string activeToken: ""

    signal tokenChanged(string name, string value)
    signal schemeExported(var tokens)

    implicitWidth:  400
    implicitHeight: 360

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

            // Header
            Rectangle {
                width: parent.width; height: 44
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2

                    Text { text: "🎨"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "Color Scheme"; color: Theme.textPrimary
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 80; height: 28
                        radius: Theme.radiusSm
                        color: _expH.hovered ? Theme.primary : Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _expH }
                        Text { anchors.centerIn: parent; text: "Export"; color: _expH.hovered ? Theme.textOnPrimary : Theme.primary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.schemeExported(root.colorTokens) }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 44
                model:  root.colorTokens
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Rectangle {
                    id:       _cseRow
                    required property var  modelData
                    required property int  index
                    width:    parent ? parent.width : 0
                    height:   root.activeToken === modelData.name ? 80 : 48
                    color:    root.activeToken === modelData.name ? Theme.panel : (_cseH.hovered ? Theme.hover : "transparent")
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    HoverHandler { id: _cseH }
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                    Column {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; topMargin: Theme.sp2; bottomMargin: Theme.sp2 }
                        spacing: Theme.sp2

                        Row {
                            width: parent.width
                            spacing: Theme.sp3

                            Rectangle {
                                width: 32; height: 32; radius: Theme.radiusSm
                                color: _cseRow.modelData.value || "#888888"
                                border.color: Theme.border; border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activeToken = (root.activeToken === _cseRow.modelData.name ? "" : _cseRow.modelData.name)
                                }
                            }

                            Column {
                                width: parent.width - 32 - 80 - Theme.sp3 * 2
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                Text {
                                    text:  _cseRow.modelData.name || ""
                                    color: Theme.textPrimary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                    font.weight:    Font.Medium
                                }
                                Text {
                                    text:  _cseRow.modelData.description || _cseRow.modelData.value || ""
                                    color: Theme.textSecondary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: 11
                                }
                            }

                            Rectangle {
                                width: 80; height: 28; radius: Theme.radiusSm
                                color:  Theme.surface; border.color: Theme.border; border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                TextInput {
                                    anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                                    verticalAlignment: TextInput.AlignVCenter
                                    text:  _cseRow.modelData.value || ""
                                    color: Theme.textPrimary
                                    font { family: Theme.fontFamilyMono; pixelSize: 11 }
                                    selectByMouse: true
                                    onEditingFinished: {
                                        var t = text.trim()
                                        if (/^#[0-9A-Fa-f]{3,8}$/.test(t))
                                            root.tokenChanged(_cseRow.modelData.name, t)
                                    }
                                }
                            }
                        }

                        // Expanded color sliders
                        Rectangle {
                            visible: root.activeToken === _cseRow.modelData.name
                            width: parent.width; height: 24
                            color: "transparent"
                            Row {
                                anchors.fill: parent
                                spacing: Theme.sp2
                                Repeater {
                                    model: ["R", "G", "B"]
                                    delegate: Row {
                                        id: _rq1
                                        required property string modelData
                                        required property int    index
                                        spacing: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            text:  _rq1.modelData; color: Theme.textSecondary
                                            font { family: Theme.fontFamilyMono; pixelSize: 11 }
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Rectangle {
                                            width: 80; height: 6; radius: 3
                                            color: Theme.border
                                            anchors.verticalCenter: parent.verticalCenter
                                            Rectangle {
                                                property real ch: {
                                                    var c = Qt.color(_cseRow.modelData.value || "#000000")
                                                    return _rq1.index === 0 ? c.r : _rq1.index === 1 ? c.g : c.b
                                                }
                                                width: parent.width * ch; height: parent.height; radius: parent.radius
                                                color: Theme.primary
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.activeToken = (root.activeToken === _cseRow.modelData.name ? "" : _cseRow.modelData.name)
                    }
                }
            }
        }
    }
}
