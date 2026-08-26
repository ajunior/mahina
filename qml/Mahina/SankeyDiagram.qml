pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Sankey flow diagram. Nodes are assigned to columns via the `group` field.
//
// Usage:
//   SankeyDiagram {
//       nodes: [
//           { id: "visits",  label: "Visits",   group: 0, color: Theme.primary },
//           { id: "signup",  label: "Sign-ups",  group: 1, color: Theme.success },
//           { id: "paid",    label: "Paid",      group: 2, color: Theme.info    },
//           { id: "churned", label: "Churned",   group: 1, color: Theme.error   },
//       ]
//       links: [
//           { source: "visits",  target: "signup",  value: 800 },
//           { source: "visits",  target: "churned", value: 200 },
//           { source: "signup",  target: "paid",    value: 300 },
//           { source: "signup",  target: "churned", value: 500 },
//       ]
//   }
Item {
    id: root

    property var nodes: []
    property var links: []
    property int nodeWidth: 14

    implicitWidth:  480
    implicitHeight: 280

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onNodesChanged()  { _canvas.requestPaint() }
            function onLinksChanged()  { _canvas.requestPaint() }
            function onWidthChanged()  { _canvas.requestPaint() }
            function onHeightChanged() { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (root.nodes.length === 0) return

            var padL = 56, padR = 56, padT = 16, padB = 24
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var nw    = root.nodeWidth
            var gap   = 14

            // Index nodes by id
            var nodeIndex = {}
            root.nodes.forEach(function(n) { nodeIndex[n.id] = n })

            // Group nodes into columns
            var colMap = {}
            var maxGroup = 0
            root.nodes.forEach(function(n) {
                var g = n.group || 0
                if (g > maxGroup) maxGroup = g
                if (!colMap[g]) colMap[g] = []
                colMap[g].push(n)
            })
            var numCols = maxGroup + 1

            function colX(g) {
                return padL + (numCols <= 1 ? plotW/2 : g * plotW / (numCols - 1))
            }

            // Compute per-node flow totals for height proportions
            var nodeFlow = {}
            root.nodes.forEach(function(n) { nodeFlow[n.id] = 0 })
            root.links.forEach(function(l) {
                nodeFlow[l.source] = (nodeFlow[l.source] || 0) + l.value
                nodeFlow[l.target] = (nodeFlow[l.target] || 0) + l.value
            })

            // Position nodes within each column
            var nodeRects = {}
            var defaultColors = [Theme.primary, Theme.success, Theme.warning, Theme.error, Theme.info]

            for (var gi = 0; gi <= maxGroup; gi++) {
                var gNodes = colMap[gi] || []
                var totalFlow = 0
                gNodes.forEach(function(n) { totalFlow += nodeFlow[n.id] || 1 })
                var availH = plotH - gap * Math.max(0, gNodes.length - 1)
                var cy = padT

                gNodes.forEach(function(n, ni) {
                    var nflow = nodeFlow[n.id] || 1
                    var nh = Math.max(12, availH * nflow / totalFlow)
                    var nc = n.color || defaultColors[ni % defaultColors.length]
                    nodeRects[n.id] = { x: colX(gi) - nw/2, y: cy, w: nw, h: nh, color: nc, label: n.label || n.id }
                    cy += nh + gap
                })
            }

            // Track output/input offsets per node for stacking multiple links
            var outOffset = {}, inOffset = {}
            root.nodes.forEach(function(n) { outOffset[n.id] = 0; inOffset[n.id] = 0 })

            // Draw links as filled bezier paths
            root.links.forEach(function(l) {
                var src = nodeRects[l.source], tgt = nodeRects[l.target]
                if (!src || !tgt) return

                var totalSrcFlow = nodeFlow[l.source] || 1
                var totalTgtFlow = nodeFlow[l.target] || 1
                var lhSrc = src.h * (l.value / totalSrcFlow)
                var lhTgt = tgt.h * (l.value / totalTgtFlow)
                var lh = Math.max(2, Math.min(lhSrc, lhTgt))

                var sy0 = src.y + outOffset[l.source]
                var ty0 = tgt.y + inOffset[l.target]
                outOffset[l.source] += lh + 1
                inOffset[l.target]  += lh + 1

                var sx = src.x + nw, sy = sy0 + lh/2
                var tx = tgt.x,      ty = ty0 + lh/2
                var cp = (tx - sx) * 0.5

                var srcCol = Qt.color(src.color)
                ctx.beginPath()
                ctx.moveTo(sx, sy0)
                ctx.bezierCurveTo(sx+cp, sy0, tx-cp, ty0, tx, ty0)
                ctx.lineTo(tx, ty0+lh)
                ctx.bezierCurveTo(tx-cp, ty0+lh, sx+cp, sy0+lh, sx, sy0+lh)
                ctx.closePath()
                ctx.fillStyle = Qt.rgba(srcCol.r, srcCol.g, srcCol.b, 0.22).toString()
                ctx.fill()
            })

            // Draw nodes
            for (var nid in nodeRects) {
                var nr   = nodeRects[nid]
                var ncol = Qt.color(nr.color)
                ctx.fillStyle = ncol.toString()
                ctx.beginPath(); ctx.rect(nr.x, nr.y, nr.w, nr.h); ctx.fill()

                // Label
                ctx.fillStyle = Qt.color(Theme.textPrimary).toString()
                ctx.font = "11px '" + Theme.fontFamily + "'"
                if (nr.x < width / 2) {
                    ctx.textAlign = "right"
                    ctx.fillText(nr.label, nr.x - 6, nr.y + nr.h/2 + 4)
                } else {
                    ctx.textAlign = "left"
                    ctx.fillText(nr.label, nr.x + nw + 6, nr.y + nr.h/2 + 4)
                }
            }
        }
    }
}
