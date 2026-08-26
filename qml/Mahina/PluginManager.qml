pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // plugins: [{id, name, version, description, author, enabled, official}]
    property var    plugins:    []
    property string searchText: ""

    signal pluginToggled(string id, bool enabled)
    signal pluginUninstalled(string id)
    signal installRequested()

    implicitWidth:  480
    implicitHeight: 400

    readonly property var _filtered: {
        var q = root.searchText.toLowerCase()
        if (q === "") return root.plugins
        return root.plugins.filter(function(p) {
            return p.name.toLowerCase().indexOf(q) >= 0 ||
                   (p.description && p.description.toLowerCase().indexOf(q) >= 0) ||
                   (p.author && p.author.toLowerCase().indexOf(q) >= 0)
        })
    }

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

            // Toolbar
            Rectangle {
                width: parent.width; height: 44
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; topMargin: 6; bottomMargin: 6 }
                    spacing: Theme.sp2

                    Rectangle {
                        width: parent.width - 90 - Theme.sp2; height: 32
                        radius: Theme.radiusSm
                        color:  Theme.surface
                        border.color: _pmSearch.activeFocus ? Theme.primary : Theme.border
                        border.width: 1
                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                            spacing: Theme.sp2
                            Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            TextInput {
                                id:    _pmSearch
                                width: parent.width - 20 - Theme.sp2
                                anchors.verticalCenter: parent.verticalCenter
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                onTextChanged:  root.searchText = text
                                Text {
                                    visible: _pmSearch.text === ""
                                    text: "Search plugins…"; color: Theme.textDisabled; font: _pmSearch.font
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 90; height: 32
                        radius: Theme.radiusSm
                        color: _instH.hovered ? Theme.primary : Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _instH }
                        Text {
                            anchors.centerIn: parent
                            text:  "+ Install"
                            color: _instH.hovered ? "#ffffff" : Theme.primary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Font.Medium
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.installRequested() }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 44
                model:  root._filtered
                clip:   true
                spacing: 0
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    required property int  index
                    width:  parent ? parent.width : 0
                    height: 72
                    color:  _pmH.hovered ? Theme.panel : Theme.surface
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _pmH }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1; color: Theme.border
                    }

                    Row {
                        anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4; topMargin: Theme.sp3; bottomMargin: Theme.sp3 }
                        spacing: Theme.sp3

                        // Icon placeholder
                        Rectangle {
                            width: 40; height: 40; radius: Theme.radiusSm
                            color: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10)
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text:  _rq1.modelData.name ? _rq1.modelData.name.charAt(0).toUpperCase() : "P"
                                color: Theme.primary
                                font { family: Theme.fontFamily; pixelSize: 18; weight: Font.Bold }
                            }
                        }

                        Column {
                            width:  parent.width - 40 - 60 - Theme.sp3 * 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: Theme.sp2
                                Text {
                                    text:  _rq1.modelData.name || "Unknown"
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                                }
                                Rectangle {
                                    visible: _rq1.modelData.official === true
                                    width:  _offTxt.implicitWidth + 8; height: 16; radius: Theme.radiusFull
                                    color:  Theme.info; anchors.verticalCenter: parent.verticalCenter
                                    Text { id: _offTxt; anchors.centerIn: parent; text: "official"; color: "#ffffff"; font.pixelSize: 9 }
                                }
                                Text {
                                    text:  "v" + (_rq1.modelData.version || "1.0")
                                    color: Theme.textDisabled
                                    font.family: Theme.fontFamily; font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                width:  parent.width
                                text:   _rq1.modelData.description || ""
                                color:  Theme.textSecondary
                                font.family: Theme.fontFamily; font.pixelSize: 11
                                elide:  Text.ElideRight
                            }

                            Text {
                                text:   _rq1.modelData.author ? "by " + _rq1.modelData.author : ""
                                color:  Theme.textDisabled
                                font.family: Theme.fontFamily; font.pixelSize: 11
                            }
                        }

                        // Toggle
                        Column {
                            width:  60
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.sp2

                            Rectangle {
                                width: 44; height: 24; radius: Theme.radiusFull
                                color: _rq1.modelData.enabled ? Theme.primary : Theme.border
                                Behavior on color { ColorAnimation { duration: 150 } }
                                anchors.horizontalCenter: parent.horizontalCenter

                                Rectangle {
                                    width: 18; height: 18; radius: Theme.radiusFull
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: _rq1.modelData.enabled ? 24 : 3
                                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.pluginToggled(_rq1.modelData.id, !_rq1.modelData.enabled)
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:  _rq1.modelData.enabled ? "On" : "Off"
                                color: _rq1.modelData.enabled ? Theme.primary : Theme.textDisabled
                                font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}
