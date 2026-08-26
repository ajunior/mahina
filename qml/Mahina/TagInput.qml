pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Chip-based tag input — press Enter or comma to add, Backspace to remove last.
//
// Usage:
//   TagInput {
//       tags: ["design", "ux"]
//       onTagAdded:   (t) => console.log("added:", t)
//       onTagRemoved: (t) => console.log("removed:", t)
//   }
Item {
    id: root

    property var    tags:             []
    property string placeholder:      "Add tag…"
    property string label:            ""
    property string helper:           ""
    property int    maxTags:          0   // 0 = unlimited

    property alias inputPlaceholder: root.placeholder

    signal tagAdded(string tag)
    signal tagRemoved(string tag)

    implicitWidth:  300
    implicitHeight: Math.max(40, _flow.implicitHeight + 10)

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: _ti.activeFocus ? Theme.primary : Theme.border
        border.width: _ti.activeFocus ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 100 } }
        clip: true

        Flow {
            id:    _flow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 5 }
            spacing: 4

            Repeater {
                model: root.tags
                delegate: Rectangle {
                    id: _rq1
                    required property string modelData
                    required property int    index
                    height: 26
                    width:  _tagRow.implicitWidth + 14
                    radius: Theme.radiusSm
                    color:  Qt.rgba(Qt.color(Theme.primary).r,
                                   Qt.color(Theme.primary).g,
                                   Qt.color(Theme.primary).b, 0.12)

                    Row {
                        id:      _tagRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text:           _rq1.modelData
                            color:          Theme.primary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }

                        Text {
                            text:  "✕"
                            color: Theme.primary
                            font.pixelSize: 8
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var copy = root.tags.slice()
                                    copy.splice(_rq1.index, 1)
                                    root.tags = copy
                                    root.tagRemoved(_rq1.modelData)
                                }
                            }
                        }
                    }
                }
            }

            // Inline text input
            Item {
                width:  Math.max(80, _ti.contentWidth + 12)
                height: 28

                Text {
                    visible: _ti.text === "" && root.tags.length === 0
                    anchors { left: parent.left; leftMargin: 2; verticalCenter: parent.verticalCenter }
                    text:           root.placeholder
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }

                TextInput {
                    id:    _ti
                    anchors { left: parent.left; right: parent.right
                              leftMargin: 2; verticalCenter: parent.verticalCenter }
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    Keys.onReturnPressed: _addTag()
                    Keys.onPressed: (e) => {
                        if (e.key === Qt.Key_Comma) { e.accepted = true; _addTag(); return }
                        if (e.key === Qt.Key_Backspace && text === "" && root.tags.length > 0) {
                            var copy    = root.tags.slice()
                            var removed = copy.pop()
                            root.tags   = copy
                            root.tagRemoved(removed)
                        }
                    }
                    function _addTag(): var {
                        var t = text.trim().replace(/,/g, "")
                        if (t === "") return
                        if (root.maxTags > 0 && root.tags.length >= root.maxTags) return
                        if (root.tags.indexOf(t) >= 0) { text = ""; return }
                        var copy = root.tags.slice()
                        copy.push(t)
                        root.tags = copy
                        root.tagAdded(t)
                        text = ""
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: _ti.forceActiveFocus()
        }
    }
}
