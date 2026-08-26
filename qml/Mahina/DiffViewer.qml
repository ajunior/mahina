pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Diff display for two text blocks. Computes a line-level diff internally.
// Supports unified (default) and side-by-side modes.
//
// Usage:
//   DiffViewer {
//       original: originalText
//       modified: modifiedText
//   }
//
//   DiffViewer {
//       original: before; modified: after
//       mode: "split"
//       showLineNumbers: true
//   }
//
// Or pass pre-computed lines:
//   DiffViewer {
//       lines: [{ type: "context", text: "…" },
//               { type: "remove",  text: "- old line" },
//               { type: "add",     text: "+ new line" }]
//   }
Item {
    id: root

    property string original: ""
    property string modified: ""
    property var    lines:    null   // overrides original/modified if set
    property string mode:     "unified"  // "unified" | "split"
    property bool   showLineNumbers: true
    property real   fontSize: Theme.textSm

    implicitWidth:  500
    implicitHeight: 360

    // ── LCS-based line diff ───────────────────────────────────────────────────
    function _computeDiff(a: var, b: var): var {
        var aL = a === "" ? [] : a.split("\n")
        var bL = b === "" ? [] : b.split("\n")
        var m  = aL.length, n = bL.length

        // DP table (only need two rows)
        var prev = new Array(n + 1).fill(0)
        var curr = new Array(n + 1).fill(0)
        var tbl  = []
        for (var i = 0; i <= m; i++) {
            tbl.push(prev.slice())
            var tmp = new Array(n + 1).fill(0)
            for (var j = 1; j <= n; j++) {
                if (i > 0 && aL[i-1] === bL[j-1]) tmp[j] = tbl[i-1][j-1] + 1
                else tmp[j] = Math.max(j > 0 ? tmp[j-1] : 0, tbl[i] ? tbl[i][j] : 0)
            }
            prev = tmp
            tbl[i] = tbl[i].slice()
        }
        // rebuild full table
        tbl = []
        for (var i2 = 0; i2 <= m; i2++) {
            tbl.push(new Array(n+1).fill(0))
            for (var j2 = 0; j2 <= n; j2++) {
                if (i2 === 0 || j2 === 0) { tbl[i2][j2] = 0; continue }
                if (aL[i2-1] === bL[j2-1]) tbl[i2][j2] = tbl[i2-1][j2-1] + 1
                else tbl[i2][j2] = Math.max(tbl[i2-1][j2], tbl[i2][j2-1])
            }
        }

        var result = []
        var pi = m, pj = n
        while (pi > 0 || pj > 0) {
            if (pi > 0 && pj > 0 && aL[pi-1] === bL[pj-1]) {
                result.unshift({ type: "context", text: aL[pi-1] })
                pi--; pj--
            } else if (pj > 0 && (pi === 0 || tbl[pi][pj-1] >= tbl[pi-1][pj])) {
                result.unshift({ type: "add", text: bL[pj-1] })
                pj--
            } else {
                result.unshift({ type: "remove", text: aL[pi-1] })
                pi--
            }
        }
        return result
    }

    readonly property var _lines: {
        if (root.lines) return root.lines
        return _computeDiff(root.original, root.modified)
    }

    // Line numbers per side
    readonly property var _lineNums: {
        var aLine = 1, bLine = 1, result = []
        for (var i = 0; i < _lines.length; i++) {
            var t = _lines[i].type
            if      (t === "context") { result.push({ a: aLine++, b: bLine++ }) }
            else if (t === "remove")  { result.push({ a: aLine++, b: null }) }
            else                      { result.push({ a: null, b: bLine++ }) }
        }
        return result
    }

    function _lineColor(type: var): var {
        switch (type) {
            case "add":    return Qt.rgba(0.15, 0.64, 0.24, 0.15)
            case "remove": return Qt.rgba(0.88, 0.30, 0.34, 0.15)
            default:       return "transparent"
        }
    }
    function _lineTextColor(type: var): var {
        switch (type) {
            case "add":    return "#3fb950"
            case "remove": return "#f85149"
            default:       return Theme.textPrimary
        }
    }
    function _prefix(type: var): var {
        switch (type) { case "add": return "+"; case "remove": return "-"; default: return " " }
    }

    Rectangle {
        anchors.fill: parent
        color:        Theme.surface
        radius:       Theme.radiusMd
        border.color: Theme.border
        border.width: 1
        clip:         true

        ListView {
            id:           _list
            anchors.fill: parent
            anchors.margins: 1
            model:        root._lines
            clip:         true
            boundsBehavior: Flickable.StopAtBounds

            QQC.ScrollBar.vertical: QQC.ScrollBar {
                contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
                background:  Rectangle { color: "transparent" }
            }
            QQC.ScrollBar.horizontal: QQC.ScrollBar {
                policy:      QQC.ScrollBar.AsNeeded
                contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
                background:  Rectangle { color: "transparent" }
            }

            delegate: Rectangle {
                id: _rq1
                required property var modelData
                required property int index

                width:  Math.max(_list.width, _lineRow.implicitWidth + Theme.sp3 * 2)
                height: _lineText.implicitHeight + 4
                color:  root._lineColor(modelData.type)

                Row {
                    id:      _lineRow
                    x:       Theme.sp3
                    y:       2
                    spacing: 0

                    // Line numbers
                    Text {
                        visible:        root.showLineNumbers
                        width:          32
                        horizontalAlignment: Text.AlignRight
                        text:           root._lineNums[_rq1.index] ? (root._lineNums[_rq1.index].a ?? "") : ""
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: root.fontSize
                    }
                    Item { visible: root.showLineNumbers; width: Theme.sp2; height: 1 }
                    Text {
                        visible:        root.showLineNumbers && root.mode === "split"
                        width:          32
                        horizontalAlignment: Text.AlignRight
                        text:           root._lineNums[_rq1.index] ? (root._lineNums[_rq1.index].b ?? "") : ""
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: root.fontSize
                    }
                    Item { visible: root.showLineNumbers; width: Theme.sp2; height: 1 }

                    // Prefix
                    Text {
                        text:           root._prefix(_rq1.modelData.type)
                        color:          root._lineTextColor(_rq1.modelData.type)
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: root.fontSize
                        font.weight:    Theme.weightBold
                    }
                    Item { width: Theme.sp2; height: 1 }

                    Text {
                        id:             _lineText
                        text:           _rq1.modelData.text ?? ""
                        color:          root._lineTextColor(_rq1.modelData.type)
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: root.fontSize
                        wrapMode:       Text.NoWrap
                    }
                }

                // Bottom divider for context lines at boundaries
                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height:  1
                    color:   Theme.border
                    visible: _rq1.modelData.type === "context" && _rq1.index > 0 &&
                             (root._lines[_rq1.index-1].type !== "context")
                }
            }
        }
    }
}
