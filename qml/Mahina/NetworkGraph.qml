pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Force-directed node-edge graph. Runs a spring simulation to position nodes.
//
// Usage:
//   NetworkGraph {
//       nodes: [
//           { id: 0, label: "Alice",   color: Theme.primary },
//           { id: 1, label: "Bob",     color: Theme.success },
//           { id: 2, label: "Charlie", color: Theme.warning },
//       ]
//       edges: [{ source: 0, target: 1 }, { source: 1, target: 2 }]
//       onNodeSelected: (n) => console.log(n.label)
//   }
Item {
    id: root

    property var  nodes:      []
    property var  edges:      []
    property real nodeRadius: 14
    property bool showLabels: true
    property color edgeColor: Theme.border

    signal nodeSelected(var node)

    implicitWidth:  400
    implicitHeight: 300

    property var nodePos: []

    onNodesChanged:  _initPositions()
    onWidthChanged:  { if (width > 0 && height > 0 && nodePos.length !== nodes.length) _initPositions() }
    onHeightChanged: { if (width > 0 && height > 0 && nodePos.length !== nodes.length) _initPositions() }

    function _initPositions() {
        if (width <= 0 || height <= 0 || nodes.length === 0) return
        var pos = []
        for (var i = 0; i < nodes.length; i++) {
            var angle = (2 * Math.PI * i) / Math.max(1, nodes.length)
            pos.push({
                x: width  / 2 + (width  * 0.35) * Math.cos(angle),
                y: height / 2 + (height * 0.35) * Math.sin(angle)
            })
        }
        nodePos = pos
        _simTimer.restart()
    }

    function _relax() {
        if (nodePos.length === 0 || width <= 0) return
        var pos = nodePos.slice().map(function(p) { return { x: p.x, y: p.y } })
        var repel = 1000
        var spring = 80
        var dt = 0.7

        for (var i = 0; i < pos.length; i++) {
            var fx = 0, fy = 0
            for (var j = 0; j < pos.length; j++) {
                if (i === j) continue
                var dx = pos[i].x - pos[j].x
                var dy = pos[i].y - pos[j].y
                var d2 = dx*dx + dy*dy
                if (d2 < 0.1) d2 = 0.1
                fx += repel * dx / d2
                fy += repel * dy / d2
            }
            for (var e = 0; e < root.edges.length; e++) {
                var s = root.edges[e].source
                var t = root.edges[e].target
                var other = s === i ? t : (t === i ? s : -1)
                if (other < 0 || other >= pos.length) continue
                var edx = pos[other].x - pos[i].x
                var edy = pos[other].y - pos[i].y
                var ed  = Math.sqrt(edx*edx + edy*edy)
                if (ed < 0.1) ed = 0.1
                var f = (ed - spring) * 0.04
                fx += f * edx / ed
                fy += f * edy / ed
            }
            // Center gravity
            fx += 0.015 * (width  / 2 - pos[i].x)
            fy += 0.015 * (height / 2 - pos[i].y)

            pos[i].x = Math.max(nodeRadius, Math.min(width  - nodeRadius, pos[i].x + fx * dt))
            pos[i].y = Math.max(nodeRadius, Math.min(height - nodeRadius, pos[i].y + fy * dt))
        }
        nodePos = pos
        _canvas.requestPaint()
    }

    Timer {
        id:       _simTimer
        interval: 40
        repeat:   true
        property int iterCount: 0
        onTriggered: {
            root._relax()
            iterCount++
            if (iterCount > 60) { stop(); iterCount = 0 }
        }
        onRunningChanged: if (running) iterCount = 0
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onNodePosChanged() { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var pos = root.nodePos
            if (pos.length === 0) return
            ctx.strokeStyle = root.edgeColor.toString()
            ctx.lineWidth   = 1.5
            for (var e = 0; e < root.edges.length; e++) {
                var s = root.edges[e].source
                var t = root.edges[e].target
                if (s < 0 || s >= pos.length || t < 0 || t >= pos.length) continue
                ctx.beginPath()
                ctx.moveTo(pos[s].x, pos[s].y)
                ctx.lineTo(pos[t].x, pos[t].y)
                ctx.stroke()
            }
        }
    }

    Repeater {
        model: root.nodePos.length
        delegate: Item {
            required property int index
            property var npos:  index < root.nodePos.length ? root.nodePos[index] : ({x:0, y:0})
            property var ndata: index < root.nodes.length   ? root.nodes[index]   : null
            x: npos.x - root.nodeRadius
            y: npos.y - root.nodeRadius
            width:  root.nodeRadius * 2
            height: root.nodeRadius * 2

            Rectangle {
                anchors.fill: parent
                radius:       width / 2
                color:        ndata && ndata.color ? ndata.color : Theme.primary
                border.color: Theme.background
                border.width: 2
            }
            Text {
                visible:        root.showLabels && ndata !== null
                text:           ndata ? (ndata.label ?? "") : ""
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:              parent.bottom
                anchors.topMargin:        3
            }
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (ndata) root.nodeSelected(ndata)
            }
        }
    }
}
