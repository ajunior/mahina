pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // graphNodes: [{id, label, x, y, color, inputs: [{label}], outputs: [{label}]}]
    // graphEdges: [{fromNode, fromPort, toNode, toPort}]
    property var graphNodes: []
    property var graphEdges: []

    signal nodeSelected(string id)
    signal nodeMoved(string id, real x, real y)
    signal connectionRequested(string fromNode, int fromPort, string toNode, int toPort)

    implicitWidth:  600
    implicitHeight: 400

    property string _selectedId: ""

    readonly property int _nodeW:    140
    readonly property int _portH:    20
    readonly property int _headerH:  28

    function _nodeHeight(n: var): var {
        var rows = Math.max((n.inputs || []).length, (n.outputs || []).length)
        return root._headerH + Math.max(1, rows) * root._portH + 8
    }

    function _portY(n: var, portIdx: var, isOutput: var): var {
        var ports = isOutput ? (n.outputs || []) : (n.inputs || [])
        return n.y + root._headerH + portIdx * root._portH + root._portH / 2
    }

    function _portX(n: var, isOutput: var): var {
        return isOutput ? n.x + root._nodeW : n.x
    }

    Rectangle {
        anchors.fill: parent
        color:  Theme.dark ? "#0a0f18" : "#f0f2f5"
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        // Pan/zoom surface
        Flickable {
            id:    _canvas
            anchors.fill: parent
            contentWidth:  1200
            contentHeight: 800
            QQC.ScrollBar.horizontal: QQC.ScrollBar {}
            QQC.ScrollBar.vertical:   QQC.ScrollBar {}

            // Edge connections (Canvas)
            Canvas {
                id:    _edgeCanvas
                width: parent.contentWidth; height: parent.contentHeight
                z: 0
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    for (var e = 0; e < root.graphEdges.length; e++) {
                        var edge = root.graphEdges[e]
                        var fn = null; var tn = null
                        for (var i = 0; i < root.graphNodes.length; i++) {
                            if (root.graphNodes[i].id === edge.fromNode) fn = root.graphNodes[i]
                            if (root.graphNodes[i].id === edge.toNode)   tn = root.graphNodes[i]
                        }
                        if (!fn || !tn) continue
                        var x1 = root._portX(fn, true)
                        var y1 = root._portY(fn, edge.fromPort || 0, true)
                        var x2 = root._portX(tn, false)
                        var y2 = root._portY(tn, edge.toPort || 0, false)
                        var cp = Math.abs(x2 - x1) * 0.5
                        ctx.beginPath()
                        ctx.moveTo(x1, y1)
                        ctx.bezierCurveTo(x1 + cp, y1, x2 - cp, y2, x2, y2)
                        ctx.strokeStyle = Theme.primary.toString()
                        ctx.lineWidth   = 2
                        ctx.globalAlpha = 0.7
                        ctx.stroke()
                        ctx.globalAlpha = 1
                        // Output dot
                        ctx.beginPath()
                        ctx.arc(x1, y1, 5, 0, Math.PI * 2)
                        ctx.fillStyle = Theme.primary.toString()
                        ctx.fill()
                    }
                }
            }

            // Node items
            Repeater {
                model: root.graphNodes
                delegate: Rectangle {
                    required property var  modelData
                    required property int  index
                    id:     _nd
                    x:      modelData.x || 80 + index * 180
                    y:      modelData.y || 80 + (index % 2) * 120
                    width:  root._nodeW
                    height: root._nodeHeight(modelData)
                    radius: Theme.radiusMd
                    color:  root._selectedId === modelData.id ? Theme.surface : Theme.surface
                    border.color: root._selectedId === modelData.id ? Theme.primary : Theme.border
                    border.width: root._selectedId === modelData.id ? 2 : 1
                    z: 1

                    // Shadow effect
                    Rectangle {
                        x: 3; y: 3; width: parent.width; height: parent.height
                        radius: parent.radius
                        color: Qt.rgba(0, 0, 0, 0.15)
                        z: -1
                    }

                    // Header
                    Rectangle {
                        width: parent.width; height: root._headerH
                        radius: Theme.radiusMd; color: _nd.modelData.color || Theme.primary
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: Theme.radiusMd; color: _nd.modelData.color || Theme.primary }
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Qt.darker(_nd.modelData.color || Theme.primary, 1.2) }
                        Text {
                            anchors { left: parent.left; right: parent.right; leftMargin: 8; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            text:  _nd.modelData.label || "Node"
                            color: "#ffffff"
                            font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: Font.Medium }
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            anchors.fill: parent
                            drag.target: _nd
                            onClicked: {
                                root._selectedId = _nd.modelData.id
                                root.nodeSelected(_nd.modelData.id)
                            }
                            onReleased: root.nodeMoved(_nd.modelData.id, _nd.x, _nd.y)
                            onPositionChanged: _edgeCanvas.requestPaint()
                        }
                    }

                    // Ports
                    Item {
                        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: root._headerH; bottom: parent.bottom }

                        // Input ports (left)
                        Column {
                            anchors { left: parent.left; top: parent.top; topMargin: 4 }
                            spacing: 0
                            Repeater {
                                model: _nd.modelData.inputs || []
                                delegate: Row {
                                    id: _rq1
                                    required property var  modelData
                                    required property int  index
                                    height: root._portH; spacing: 4

                                    // Port dot
                                    Rectangle {
                                        width: 10; height: 10; radius: 5; color: Theme.border
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: -5
                                        border.color: Theme.textDisabled; border.width: 1
                                    }
                                    Text {
                                        text:  _rq1.modelData.label || ("in" + (_rq1.index + 1))
                                        color: Theme.textSecondary
                                        font { family: Theme.fontFamily; pixelSize: 10 }
                                        anchors.verticalCenter: parent.verticalCenter
                                        leftPadding: 10
                                    }
                                }
                            }
                        }

                        // Output ports (right)
                        Column {
                            anchors { right: parent.right; top: parent.top; topMargin: 4 }
                            spacing: 0
                            Repeater {
                                model: _nd.modelData.outputs || []
                                delegate: Row {
                                    id: _rq2
                                    required property var  modelData
                                    required property int  index
                                    height: root._portH; spacing: 4
                                    layoutDirection: Qt.RightToLeft

                                    Rectangle {
                                        width: 10; height: 10; radius: 5; color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 5
                                    }
                                    Text {
                                        text:  _rq2.modelData.label || ("out" + (_rq2.index + 1))
                                        color: Theme.textSecondary
                                        font { family: Theme.fontFamily; pixelSize: 10 }
                                        anchors.verticalCenter: parent.verticalCenter
                                        rightPadding: 10
                                    }
                                }
                            }
                        }
                    }

                    onXChanged: _edgeCanvas.requestPaint()
                    onYChanged: _edgeCanvas.requestPaint()
                }
            }

            // Background click to deselect
            MouseArea {
                anchors.fill: parent; z: -1
                onClicked: root._selectedId = ""
            }
        }

        // Zoom controls
        Column {
            anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }
            spacing: Theme.sp2

            Repeater {
                model: [{ label: "+", delta: 0.2 }, { label: "−", delta: -0.2 }, { label: "⊡", delta: 0 }]
                delegate: Rectangle {
                    id: _rq3
                    required property var  modelData
                    required property int  index
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: _zmH.hovered ? Theme.primary : Theme.surface
                    border.color: _zmH.hovered ? Theme.primary : Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _zmH }
                    Text { anchors.centerIn: parent; text: _rq3.modelData.label; color: _zmH.hovered ? "#fff" : Theme.textPrimary; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (_rq3.modelData.delta === 0) { _canvas.contentX = 0; _canvas.contentY = 0 }
                        }
                    }
                }
            }
        }
    }

    onGraphNodesChanged: _edgeCanvas.requestPaint()
    onGraphEdgesChanged: _edgeCanvas.requestPaint()
}
