pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // tocItems: [{id: string, level: 1|2|3, title: string}]
    property var    tocItems:  []
    property string activeId:  ""
    property int    indentSize: 14

    signal itemSelected(string id)

    implicitWidth:  220
    implicitHeight: 300

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

            Rectangle {
                width: parent.width
                height: 36
                color: Theme.panel
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1; color: Theme.border
                }
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.sp3 }
                    spacing: Theme.sp2
                    Text { text: "≡"; color: Theme.textSecondary; font.pixelSize: 14 }
                    Text {
                        text:  "Contents"
                        color: Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Font.Medium
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 36
                model:  root.tocItems
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    required property int  index
                    width:  parent ? parent.width : 0
                    height: 30
                    color: modelData.id === root.activeId
                           ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10)
                           : (_tocH.hovered ? Theme.hover : "transparent")
                    HoverHandler { id: _tocH }

                    Rectangle {
                        visible: _rq1.modelData.id === root.activeId
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width:  3
                        color:  Theme.primary
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.sp3 + (_rq1.modelData.level - 1) * root.indentSize
                            right: parent.right; rightMargin: Theme.sp3
                            verticalCenter: parent.verticalCenter
                        }
                        text:  _rq1.modelData.title
                        color: _rq1.modelData.id === root.activeId ? Theme.primary
                               : (_rq1.modelData.level === 1 ? Theme.textPrimary : Theme.textSecondary)
                        font.family:    Theme.fontFamily
                        font.pixelSize: _rq1.modelData.level === 1 ? Theme.textSm : 12
                        font.weight:    _rq1.modelData.level === 1 ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeId = _rq1.modelData.id
                            root.itemSelected(_rq1.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
