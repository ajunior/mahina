pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Proportional rectangle chart for hierarchical / part-of-whole data.
//
// Usage:
//   TreeMap {
//       nodes: [
//           { label: "React",   value: 42, color: Theme.primary  },
//           { label: "Vue",     value: 28, color: Theme.success  },
//           { label: "Angular", value: 18, color: Theme.warning  },
//           { label: "Svelte",  value: 12, color: Theme.error    },
//       ]
//   }
Item {
    id: root

    property var  nodes: []
    property real gap:   2

    implicitWidth:  400
    implicitHeight: 260

    readonly property real _total: {
        var t = 0
        for (var i = 0; i < nodes.length; i++) t += nodes[i].value ?? 0
        return t || 1
    }

    // Compute squarified layout
    property var _rects: []

    function _layout() {
        var n = nodes.length
        if (n === 0) { _rects = []; return }
        var total = _total
        var rects = []
        var x = 0, y = 0, W = width, H = height
        var sorted = nodes.slice().sort(function(a,b){ return (b.value??0)-(a.value??0) })

        // Simple row-based layout (not full squarify, but good enough)
        var remaining = sorted.slice()
        var rowArea = 0
        while (remaining.length > 0) {
            var rowItems = []
            var shortSide = Math.min(W - x, H - y)
            // Pick items while aspect ratio improves
            var tentArea = 0
            for (var i = 0; i < remaining.length; i++) {
                tentArea += (remaining[i].value ?? 0) / total * width * height
                rowItems.push(remaining[i])
                if (i + 1 >= remaining.length) break
                var nextArea = tentArea + (remaining[i+1].value ?? 0) / total * width * height
                var curRatio  = _worstRatio(rowItems, shortSide, tentArea)
                var nextRatio = _worstRatio(rowItems.concat([remaining[i+1]]), shortSide, nextArea)
                if (nextRatio > curRatio) break
            }
            remaining.splice(0, rowItems.length)

            // Layout this row horizontally or vertically
            var rowSum = 0
            for (var j = 0; j < rowItems.length; j++) rowSum += rowItems[j].value ?? 0

            var isHoriz = (W - x) >= (H - y)
            if (isHoriz) {
                var rowW = (rowSum / (_total)) * (width * height) / (H - y)
                var cy = y
                for (var k = 0; k < rowItems.length; k++) {
                    var frac = (rowItems[k].value ?? 0) / rowSum
                    var rh = frac * (H - y)
                    rects.push({ x: x, y: cy, w: rowW, h: rh, label: rowItems[k].label ?? "", color: rowItems[k].color ?? Theme.primary, value: rowItems[k].value ?? 0 })
                    cy += rh
                }
                x += rowW
            } else {
                var rowH2 = (rowSum / _total) * (width * height) / (W - x)
                var cx2 = x
                for (var k2 = 0; k2 < rowItems.length; k2++) {
                    var frac2 = (rowItems[k2].value ?? 0) / rowSum
                    var rw2 = frac2 * (W - x)
                    rects.push({ x: cx2, y: y, w: rw2, h: rowH2, label: rowItems[k2].label ?? "", color: rowItems[k2].color ?? Theme.primary, value: rowItems[k2].value ?? 0 })
                    cx2 += rw2
                }
                y += rowH2
            }
        }
        _rects = rects
    }

    function _worstRatio(items, shortSide, area) {
        var worst = 0
        for (var i = 0; i < items.length; i++) {
            var frac = (items[i].value ?? 0) / _total
            var itemArea = frac * width * height
            var w = area / shortSide
            var h = itemArea / w
            var r = Math.max(w / h, h / w)
            if (r > worst) worst = r
        }
        return worst
    }

    onNodesChanged:  _layout()
    onWidthChanged:  _layout()
    onHeightChanged: _layout()
    Component.onCompleted: _layout()

    Repeater {
        model: root._rects
        delegate: Rectangle {
            id: _rq1
            required property var modelData
            x:      modelData.x + root.gap / 2
            y:      modelData.y + root.gap / 2
            width:  Math.max(0, modelData.w - root.gap)
            height: Math.max(0, modelData.h - root.gap)
            color:  modelData.color
            radius: Theme.radiusSm
            clip:   true

            HoverHandler { id: _tmHover }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color:  Qt.rgba(0, 0, 0, _tmHover.hovered ? 0.15 : 0)
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            Column {
                anchors { fill: parent; margins: Theme.sp2 }
                spacing: 2
                visible: parent.width > 40 && parent.height > 28

                Text {
                    text:           _rq1.modelData.label
                    color:          "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightSemibold
                    elide:          Text.ElideRight
                    width:          parent.width
                }
                Text {
                    visible:        parent.parent.height > 50
                    text:           _rq1.modelData.value
                    color:          Qt.rgba(1, 1, 1, 0.75)
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                }
            }
        }
    }
}
