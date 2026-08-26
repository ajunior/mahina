pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Drag-and-drop Kanban board.
//
// Usage:
//   Kanban {
//       columns: [
//           { title: "To Do",       color: Theme.border,   cards: [
//               { id: "1", title: "Research API",  tag: "backend" },
//           ]},
//           { title: "In Progress", color: Theme.warning, cards: [
//               { id: "2", title: "Build UI",      tag: "design"  },
//           ]},
//           { title: "Done",        color: Theme.success, cards: [] },
//       ]
//       onCardMoved: (cardId, fromCol, toCol) => model.move(cardId, fromCol, toCol)
//   }
Item {
    id: root

    property var  columns:   []
    property real colWidth:  220
    property real colHeight: 400

    signal cardMoved(string cardId, int fromCol, int toCol)

    implicitWidth:  Math.max(1, columns.length) * (colWidth + 12) - 12
    implicitHeight: colHeight + 44

    // Internal mutable state — deep copy of columns
    property var boardData: []

    onColumnsChanged:     _syncBoard()
    Component.onCompleted: _syncBoard()

    function _syncBoard(): void {
        boardData = JSON.parse(JSON.stringify(root.columns))
    }

    // Drag state
    property bool dragging:      false
    property int  dragFromCol:   -1
    property int  dragFromCard:  -1
    property var  dragCardData:  null
    property real ghostX:        0
    property real ghostY:        0
    property int  targetCol:     -1

    // Ghost card that follows mouse during drag
    Rectangle {
        id:      _ghost
        z:       1000
        visible: root.dragging
        x:       root.ghostX - width / 2
        y:       root.ghostY - height / 2
        width:   root.colWidth - Theme.sp4
        height:  Math.max(52, _ghostCol.implicitHeight + Theme.sp3 * 2)
        radius:  Theme.radiusMd
        color:   Theme.surface
        border.color: Theme.primary; border.width: 2
        opacity: 0.9

        Column {
            id:       _ghostCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp3 }
            spacing:  Theme.sp1
            Text {
                text:  root.dragCardData ? (root.dragCardData.title || "") : ""
                color: Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightMedium
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }

    // Global drag tracker — only enabled while dragging
    MouseArea {
        id:           _dragTracker
        anchors.fill: parent
        z:            999
        enabled:      root.dragging
        propagateComposedEvents: true

        onPositionChanged: (mouse) => {
            root.ghostX = mouse.x
            root.ghostY = mouse.y
            // Detect which column we hover
            var found = -1
            for (var ci = 0; ci < _colRepeater.count; ci++) {
                var item = _colRepeater.itemAt(ci)
                if (!item) continue
                var mapped = mapToItem(item, mouse.x, mouse.y)
                if (mapped.x >= 0 && mapped.x <= item.width && mapped.y >= 0 && mapped.y <= item.height) {
                    found = ci; break
                }
            }
            root.targetCol = found
        }

        onReleased: (mouse) => {
            if (root.targetCol >= 0 && root.targetCol !== root.dragFromCol && root.dragFromCol >= 0) {
                var bd   = JSON.parse(JSON.stringify(root.boardData))
                var card = bd[root.dragFromCol].cards.splice(root.dragFromCard, 1)[0]
                bd[root.targetCol].cards.push(card)
                root.boardData = bd
                root.cardMoved(card.id || card.title || "", root.dragFromCol, root.targetCol)
            }
            root.dragging     = false
            root.dragFromCol  = -1
            root.dragFromCard = -1
            root.targetCol    = -1
        }
    }

    Row {
        anchors.top:    parent.top
        anchors.left:   parent.left
        spacing: 12

        Repeater {
            id:    _colRepeater
            model: root.boardData

            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                property int colIdx: index
                width:  root.colWidth
                height: root.colHeight + 44

                // Column header
                Rectangle {
                    id:     _colHeader
                    width:  parent.width
                    height: 36
                    radius: Theme.radiusMd
                    color:  Theme.panel

                    Row {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                        spacing: Theme.sp2
                        Rectangle {
                            width: 8; height: 8; radius: 4; color: _rq1.modelData.color || Theme.border
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:  _rq1.modelData.title || ""
                            color: Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Theme.weightSemibold
                        }
                        Item { width: 1; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:  _rq1.modelData.cards ? _rq1.modelData.cards.length : 0
                            color: Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                        }
                    }
                }

                // Column body (drop target highlight)
                Rectangle {
                    id:     _colBody
                    anchors { left: parent.left; right: parent.right; top: _colHeader.bottom; topMargin: 8; bottom: parent.bottom }
                    radius: Theme.radiusMd
                    color:  root.targetCol === _rq1.colIdx && root.dragging
                                ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.06)
                                : Theme.panel
                    border.color: root.targetCol === _rq1.colIdx && root.dragging ? Theme.primary : "transparent"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    QQC.ScrollView {
                        anchors { fill: parent; margins: Theme.sp2 }
                        clip: true
                        contentWidth: availableWidth

                        Column {
                            width:   parent.width
                            spacing: Theme.sp2
                            padding: Theme.sp1

                            Repeater {
                                model: _rq1.modelData.cards || []
                                delegate: Item {
                                    id: _rq2
                                    required property var modelData
                                    required property int index

                                    property int  myCardIdx: index
                                    property int  myColIdx:  _rq1.colIdx
                                    property bool isBeingDragged: root.dragging && root.dragFromCol === _rq1.colIdx && root.dragFromCard === index

                                    width:   parent.width - Theme.sp1 * 2
                                    height:  isBeingDragged ? 4 : _cardRect.implicitHeight
                                    opacity: isBeingDragged ? 0.3 : 1.0
                                    Behavior on height  { NumberAnimation { duration: Theme.durationFast } }
                                    Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

                                    Rectangle {
                                        id:     _cardRect
                                        width:  parent.width
                                        implicitHeight: _cardContent.implicitHeight + Theme.sp3 * 2
                                        radius: Theme.radiusSm
                                        color:  _cardH.containsMouse && !root.dragging ? Theme.surfaceVariant : Theme.surface
                                        border.color: Theme.border; border.width: 1
                                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                                        HoverHandler { id: _cardH }

                                        Column {
                                            id:     _cardContent
                                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp3 }
                                            spacing: Theme.sp1

                                            Text {
                                                text:  _rq2.modelData.title || ""
                                                color: Theme.textPrimary
                                                font.family:    Theme.fontFamily
                                                font.pixelSize: Theme.textSm
                                                font.weight:    Theme.weightMedium
                                                width:          parent.width
                                                wrapMode:       Text.WordWrap
                                            }

                                            Text {
                                                visible: (_rq2.modelData.body ?? "") !== ""
                                                text:    _rq2.modelData.body || ""
                                                color:   Theme.textSecondary
                                                font.family:    Theme.fontFamily
                                                font.pixelSize: Theme.textXs
                                                width:          parent.width
                                                wrapMode:       Text.WordWrap
                                            }

                                            Rectangle {
                                                visible: (_rq2.modelData.tag ?? "") !== ""
                                                width:  _tagTxt.implicitWidth + Theme.sp3
                                                height: 18; radius: 9
                                                color:  Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                                                Text {
                                                    id:     _tagTxt
                                                    anchors.centerIn: parent
                                                    text:  _rq2.modelData.tag || ""
                                                    color: Theme.primary
                                                    font.family:    Theme.fontFamily
                                                    font.pixelSize: Theme.textXs
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape:  Qt.OpenHandCursor

                                            onPressed: (mouse) => {
                                                var g = mapToItem(root, mouse.x, mouse.y)
                                                root.dragCardData  = _rq2.modelData
                                                root.dragFromCol   = _rq2.myColIdx
                                                root.dragFromCard  = _rq2.myCardIdx
                                                root.ghostX        = g.x
                                                root.ghostY        = g.y
                                                root.targetCol     = _rq2.myColIdx
                                                root.dragging      = true
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
