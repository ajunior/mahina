pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Contextual action toolbar that floats above a target item.
//
// Usage:
//   FloatingToolbar {
//       id:    _toolbar
//       open:  _textEdit.selectedText.length > 0
//       target: _textEdit
//       actions: [
//           { icon: Icons.textBolder,    label: "Bold",        onTriggered: function() { editor.bold() }    },
//           { icon: Icons.textItalic,    label: "Italic",      onTriggered: function() { editor.italic() }  },
//           { icon: Icons.link,          label: "Link",        onTriggered: function() { editor.link() }    },
//           { icon: Icons.copy,          label: "Copy",        onTriggered: function() { editor.copy() }    },
//       ]
//   }
Item {
    id: root

    property bool open:    false
    property Item target:  null
    property var  actions: []

    implicitWidth:  _bar.implicitWidth
    implicitHeight: _bar.implicitHeight

    // Position above target
    x: target ? target.mapToItem(parent, (target.width - _bar.implicitWidth) / 2, 0).x : 0
    y: target ? target.mapToItem(parent, 0, -_bar.implicitHeight - 8).y                : 0

    visible: root.open
    z:       200

    opacity: root.open ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

    // Slight slide-in from below
    property real slideY: root.open ? 0 : 6
    Behavior on slideY   { NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutQuad } }

    transform: Translate { y: root.slideY }

    Rectangle {
        id:     _bar
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        implicitWidth:  _btnRow.implicitWidth  + Theme.sp2 * 2
        implicitHeight: _btnRow.implicitHeight + Theme.sp2 * 2

        // Drop shadow via border glow
        layer.enabled: true

        Row {
            id:      _btnRow
            anchors { fill: parent; margins: Theme.sp2 }
            spacing: 2

            Repeater {
                model: root.actions
                delegate: Item {
                    id: _rq1
                    required property var  modelData
                    required property int  index

                    width:  34; height: 30

                    // Separator before every 4th button
                    Rectangle {
                        visible: _rq1.index > 0 && _rq1.index % 4 === 0
                        width: 1; height: 20
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.border
                    }

                    Rectangle {
                        id:     _btn
                        anchors { fill: parent; leftMargin: (_rq1.index > 0 && _rq1.index % 4 === 0) ? 4 : 0 }
                        radius: Theme.radiusSm
                        color:  _btnH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _btnH }

                        Text {
                            anchors.centerIn: parent
                            text:           _rq1.modelData.icon || ""
                            color:          _btnH.hovered ? Theme.textPrimary : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textBase
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                if (_rq1.modelData.onTriggered) _rq1.modelData.onTriggered()
                            }
                        }

                        // Tooltip on hover
                        Rectangle {
                            visible: _btnH.hovered && (_rq1.modelData.label || "") !== ""
                            anchors { bottom: parent.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
                            width:  _tipText.implicitWidth + Theme.sp3; height: 20; radius: 4
                            color:  Theme.overlay
                            Text {
                                id:     _tipText
                                anchors.centerIn: parent
                                text:           _rq1.modelData.label || ""
                                color:          Theme.textOnPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                            }
                        }
                    }
                }
            }
        }
    }

    // Caret pointer
    Rectangle {
        anchors.horizontalCenter: _bar.horizontalCenter
        anchors.top:              _bar.bottom
        width:  10; height: 6
        rotation: 180
        color: Theme.surface
        Rectangle { anchors.fill: parent; color: Theme.border; z: -1; visible: false }
        // Simple triangle via rotation
        transform: [
            Rotation { angle: 0 }
        ]
    }
}
