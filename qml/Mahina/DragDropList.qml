import QtQuick
import Mahina

// Reorderable list with drag handles.
//
// Usage:
//   DragDropList {
//       listItems: [
//           { label: "First item"  },
//           { label: "Second item" },
//           { label: "Third item"  },
//       ]
//       onReordered: (items) => console.log("New order:", JSON.stringify(items))
//   }
Item {
    id: root

    property var listItems:    []
    property int draggedIndex: -1
    property int dropIndex:    -1

    signal reordered(var newItems)

    implicitWidth:  300
    implicitHeight: _col.implicitHeight

    Column {
        id:    _col
        width: parent.width
        spacing: 3

        Repeater {
            model: root.listItems
            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                width:  parent.width
                height: 44

                readonly property bool isDragged:    root.draggedIndex === index
                readonly property bool isDropTarget: root.dropIndex === index && root.draggedIndex !== index

                z: isDragged ? 10 : 0

                // Drop indicator line above
                Rectangle {
                    visible: isDropTarget && root.dropIndex < root.draggedIndex
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    height: 2; color: Theme.primary; radius: 1
                }

                Rectangle {
                    anchors { fill: parent; topMargin: 1; bottomMargin: 1 }
                    radius: Theme.radiusMd
                    color:  isDragged
                            ? Theme.panel
                            : (isDropTarget
                               ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.07)
                               : Theme.surface)
                    border.color: isDragged ? Theme.primary : Theme.border
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }

                    Row {
                        anchors { left: parent.left; right: parent.right
                                  leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp3

                        // Drag handle
                        Item {
                            width: 24; height: parent.height

                            Text {
                                anchors.centerIn: parent
                                text:  "⠿"
                                color: _dhH.hovered ? Theme.textSecondary : Theme.textDisabled
                                font.pixelSize: 18
                            }
                            HoverHandler { id: _dhH }

                            MouseArea {
                                id:          _dragArea
                                anchors.fill: parent
                                cursorShape: Qt.SizeVerCursor
                                property real startY:   0
                                property int  startIdx: 0
                                // Global coordinates: the row is reparented and
                                // moved while it is being dragged.
                                onPressed: (m) => {
                                    startY   = _dragArea.mapToGlobal(m.x, m.y).y
                                    startIdx = _rq1.index
                                    root.draggedIndex = _rq1.index
                                    root.dropIndex    = _rq1.index
                                }
                                onPositionChanged: (m) => {
                                    if (!pressed) return
                                    var dy     = _dragArea.mapToGlobal(m.x, m.y).y - startY
                                    var newIdx = Math.max(0, Math.min(root.listItems.length - 1,
                                                          startIdx + Math.round(dy / 47)))
                                    root.dropIndex = newIdx
                                }
                                onReleased: {
                                    if (root.draggedIndex >= 0 && root.dropIndex >= 0
                                            && root.draggedIndex !== root.dropIndex) {
                                        var copy = root.listItems.slice()
                                        var item = copy.splice(root.draggedIndex, 1)[0]
                                        copy.splice(root.dropIndex, 0, item)
                                        root.listItems = copy
                                        root.reordered(root.listItems)
                                    }
                                    root.draggedIndex = -1
                                    root.dropIndex    = -1
                                }
                            }
                        }

                        Text {
                            width: parent.width - 32
                            text:           _rq1.modelData.label || _rq1.modelData.toString()
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                    }
                }

                // Drop indicator line below
                Rectangle {
                    visible: isDropTarget && root.dropIndex >= root.draggedIndex
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 2; color: Theme.primary; radius: 1
                }
            }
        }
    }
}
