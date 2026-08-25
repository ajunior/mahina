import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // layers: [{id, name, type: "group"|"shape"|"text"|"image", visible, locked, children: [...]}]
    property var    layers:        []
    property string activeLayerId: ""
    property int    rowHeight:     32

    signal layerSelected(string id)
    signal visibilityToggled(string id, bool visible)
    signal lockToggled(string id, bool locked)
    signal layerRenamed(string id, string newName)

    implicitWidth:  260
    implicitHeight: 340

    // Flatten tree to rows
    function _flatten(list, depth) {
        var out = []
        for (var i = 0; i < list.length; i++) {
            var item = list[i]
            out.push({ id: item.id, name: item.name, type: item.type || "shape",
                       visible: item.visible !== false, locked: item.locked === true,
                       depth: depth, hasChildren: (item.children && item.children.length > 0) })
            if (item.children && item.children.length > 0)
                out = out.concat(_flatten(item.children, depth + 1))
        }
        return out
    }

    readonly property var _rows: _flatten(root.layers, 0)

    function _typeIcon(t) {
        if (t === "group") return "▸"
        if (t === "text")  return "T"
        if (t === "image") return "⬜"
        return "◻"
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

            // Header
            Rectangle {
                width: parent.width; height: 36
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text { text: "⊞"; color: Theme.textSecondary; font.pixelSize: 13 }
                    Text {
                        text: "Layers"; color: Theme.textPrimary
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 36
                model:  root._rows
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    required property int  index
                    width:  parent ? parent.width : 0
                    height: root.rowHeight
                    color:  modelData.id === root.activeLayerId
                            ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                            : (_layH.hovered ? Theme.panel : "transparent")
                    HoverHandler { id: _layH }

                    Row {
                        anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2 + _rq1.modelData.depth * 16; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2

                        // Visibility eye
                        Rectangle {
                            width: 22; height: 22; radius: 4
                            color: _eyeH.hovered ? Theme.panel : "transparent"
                            HoverHandler { id: _eyeH }
                            Text {
                                anchors.centerIn: parent
                                text:  _rq1.modelData.visible ? "👁" : "○"
                                color: _rq1.modelData.visible ? Theme.textPrimary : Theme.textDisabled
                                font.pixelSize: 12
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.visibilityToggled(_rq1.modelData.id, !_rq1.modelData.visible)
                            }
                        }

                        // Type icon
                        Rectangle {
                            width: 18; height: 18; radius: 3
                            color: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text:  root._typeIcon(_rq1.modelData.type)
                                color: Theme.primary
                                font { family: Theme.fontFamily; pixelSize: 9; weight: Font.Bold }
                            }
                        }

                        // Name
                        Text {
                            text:  _rq1.modelData.name
                            color: _rq1.modelData.id === root.activeLayerId ? Theme.primary
                                   : (_rq1.modelData.visible ? Theme.textPrimary : Theme.textDisabled)
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _rq1.modelData.id === root.activeLayerId ? Font.Medium : Font.Normal
                            elide: Text.ElideRight
                            width: parent.width - 22 - 18 - 22 - Theme.sp2 * 3
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Lock icon
                        Rectangle {
                            width: 22; height: 22; radius: 4
                            color: _lkH.hovered ? Theme.panel : "transparent"
                            HoverHandler { id: _lkH }
                            Text {
                                anchors.centerIn: parent
                                text:  _rq1.modelData.locked ? "🔒" : "🔓"
                                color: _rq1.modelData.locked ? Theme.warning : Theme.textDisabled
                                font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.lockToggled(_rq1.modelData.id, !_rq1.modelData.locked)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.activeLayerId = _rq1.modelData.id
                            root.layerSelected(_rq1.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
