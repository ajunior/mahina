pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Force-directed node-edge graph. Runs a spring simulation to position nodes.
//
// Drag the background to pan, wheel to zoom; `resetView()` puts it back.
// Labels appear only when the nodes have enough room on screen to carry one
// without landing on each other, so zooming in reveals them rather than a
// switch turning them on over a thicket.
//
// The simulation compares every node against every other node on each of its
// 60 ticks, which is fine into the low hundreds of nodes and is not fine at a
// thousand: the cost is quadratic and it runs on the GUI thread, so past that
// the window stops repainting until it settles. A host with an unbounded node
// count should decide what to draw before handing it over.
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

    // ── View transform ────────────────────────────────────────────────────────
    property real zoom:    1.0
    property real panX:    0
    property real panY:    0
    property real minZoom: 0.25
    property real maxZoom: 4.0

    signal nodeSelected(var node)

    function resetView(): void { root.zoom = 1.0; root.panX = 0; root.panY = 0 }

    // Zoom by `factor` keeping the graph point under (x, y) where it is, so the
    // thing you pointed at is the thing you zoomed into.
    function zoomAt(x: real, y: real, factor: real): void {
        const next = Math.max(root.minZoom, Math.min(root.maxZoom, root.zoom * factor))
        if (next === root.zoom) return
        root.panX = x - (x - root.panX) * (next / root.zoom)
        root.panY = y - (y - root.panY) * (next / root.zoom)
        root.zoom = next
    }

    // Zoom about the middle of the view — what a toolbar button does.
    function zoomBy(factor: real): void { root.zoomAt(root.width / 2, root.height / 2, factor) }

    implicitWidth:  400
    implicitHeight: 300

    property var nodePos: []

    // Graph coordinates → view coordinates.
    function _sx(v: real): real { return v * root.zoom + root.panX }
    function _sy(v: real): real { return v * root.zoom + root.panY }

    // A label is about 70×14 px on screen and sits under its node, so it needs
    // roughly 4000 px² to itself before it stops overlapping its neighbours.
    // The area each node has is the view, times zoom², over the node count —
    // which is why zooming in brings the labels back.
    readonly property bool _labelsVisible:
        root.showLabels && root.nodes.length > 0 &&
        (root.width * root.height * root.zoom * root.zoom) / root.nodes.length > 4000

    onNodesChanged:  _initPositions()
    onWidthChanged:  { if (width > 0 && height > 0 && nodePos.length !== nodes.length) _initPositions() }
    onHeightChanged: { if (width > 0 && height > 0 && nodePos.length !== nodes.length) _initPositions() }
    onZoomChanged:   _canvas.requestPaint()
    onPanXChanged:   _canvas.requestPaint()
    onPanYChanged:   _canvas.requestPaint()

    function _initPositions(): void {
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

    function _relax(): var {
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

    // Pan. The nodes carry a MouseArea each, so a drag that starts on one is
    // a drag on the background as far as this is concerned — the handler takes
    // the grab once the press turns out to be a drag, and the node keeps the
    // clicks.
    DragHandler {
        target: null
        cursorShape: Qt.ClosedHandCursor
        property real _fromX: 0
        property real _fromY: 0
        onActiveChanged: {
            if (active) { _fromX = root.panX; _fromY = root.panY }
        }
        onTranslationChanged: {
            if (!active) return
            root.panX = _fromX + activeTranslation.x
            root.panY = _fromY + activeTranslation.y
        }
    }

    WheelHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y === 0) return
            root.zoomAt(event.x, event.y, event.angleDelta.y > 0 ? 1.15 : 1 / 1.15)
        }
    }

    // Edges are painted at view resolution with the transform applied to the
    // context rather than to the item, so a zoomed-in line is drawn sharp
    // instead of a magnified 1.5 px one.
    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onNodePosChanged(): void { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var pos = root.nodePos
            if (pos.length === 0) return
            ctx.save()
            ctx.translate(root.panX, root.panY)
            ctx.scale(root.zoom, root.zoom)
            ctx.strokeStyle = root.edgeColor.toString()
            ctx.lineWidth   = 1.5 / root.zoom
            for (var e = 0; e < root.edges.length; e++) {
                var s = root.edges[e].source
                var t = root.edges[e].target
                if (s < 0 || s >= pos.length || t < 0 || t >= pos.length) continue
                ctx.beginPath()
                ctx.moveTo(pos[s].x, pos[s].y)
                ctx.lineTo(pos[t].x, pos[t].y)
                ctx.stroke()
            }
            ctx.restore()
        }
    }

    Repeater {
        model: root.nodePos.length
        delegate: Item {
            id: _dg
            required property int index
            property var npos:  index < root.nodePos.length ? root.nodePos[index] : ({x:0, y:0})
            property var ndata: index < root.nodes.length   ? root.nodes[index]   : null
            readonly property real r: root.nodeRadius * root.zoom
            x: root._sx(npos.x) - r
            y: root._sy(npos.y) - r
            width:  r * 2
            height: r * 2

            Rectangle {
                anchors.fill: parent
                radius:       width / 2
                color:        _dg.ndata && _dg.ndata.color ? _dg.ndata.color : Theme.primary
                border.color: Theme.background
                border.width: 2
            }
            Text {
                visible:        root._labelsVisible && _dg.ndata !== null
                text:           _dg.ndata ? (_dg.ndata.label ?? "") : ""
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
                onClicked:    if (_dg.ndata) root.nodeSelected(_dg.ndata)
            }
        }
    }
}
