import QtQuick
import Mahina

// GitHub-style contribution heatmap. Renders a grid of colored cells.
//
// Usage (GitHub calendar style):
//   HeatMap {
//       // data keys are "YYYY-MM-DD" strings; values are counts
//       data: ({ "2025-01-05": 3, "2025-01-12": 7, "2025-02-01": 1 })
//       startDate: "2025-01-01"
//       endDate:   "2025-12-31"
//   }
//
// Usage (generic grid):
//   HeatMap {
//       rows:   [[ 0, 2, 5, 3 ], [ 1, 4, 6, 2 ], [ 3, 0, 1, 5 ]]
//       labels: { rows: ["Mon","Wed","Fri"], cols: ["Q1","Q2","Q3","Q4"] }
//   }
Item {
    id: root

    // Calendar mode (date-keyed object)
    property var    heatData:  null      // { "YYYY-MM-DD": count }
    property string startDate: ""        // "YYYY-MM-DD"
    property string endDate:   ""        // "YYYY-MM-DD"

    // Generic grid mode (overrides calendar mode when set)
    property var    rows:      null      // [[number]]
    property var    labels:    null      // { rows: [], cols: [] }

    property color  colorEmpty:  Theme.surfaceVariant
    property color  colorLow:    "#0e4429"
    property color  colorMid:    "#26a641"
    property color  colorHigh:   "#39d353"
    property int    cellSize:    13
    property int    cellGap:     3
    property string tooltip:     ""     // auto-set on hover

    signal cellHovered(string key, var value)
    signal cellClicked(string key, var value)

    // ── Calendar mode helpers ─────────────────────────────────────────────────
    function _parseDate(s) {
        var p = s.split("-")
        return new Date(parseInt(p[0]), parseInt(p[1])-1, parseInt(p[2]))
    }
    function _dateKey(d) {
        return d.getFullYear() + "-" +
               String(d.getMonth()+1).padStart(2,"0") + "-" +
               String(d.getDate()).padStart(2,"0")
    }
    function _interp(t) {
        var r = t < 0.5
            ? Qt.rgba(Qt.color(colorEmpty).r*(1-2*t) + Qt.color(colorLow).r*(2*t),
                      Qt.color(colorEmpty).g*(1-2*t) + Qt.color(colorLow).g*(2*t),
                      Qt.color(colorEmpty).b*(1-2*t) + Qt.color(colorLow).b*(2*t), 1)
            : Qt.rgba(Qt.color(colorLow).r*(1-(2*t-1)) + Qt.color(colorHigh).r*(2*t-1),
                      Qt.color(colorLow).g*(1-(2*t-1)) + Qt.color(colorHigh).g*(2*t-1),
                      Qt.color(colorLow).b*(1-(2*t-1)) + Qt.color(colorHigh).b*(2*t-1), 1)
        return r
    }

    // Build flat cell array for calendar mode
    readonly property var _calCells: {
        if (!root.heatData || root.startDate === "") return []
        var start = _parseDate(root.startDate)
        var end   = root.endDate !== "" ? _parseDate(root.endDate) : new Date()
        // align start to Sunday
        var dow = start.getDay()
        start.setDate(start.getDate() - dow)

        // find max value for normalization
        var maxV = 0
        var keys = Object.keys(root.heatData)
        for (var i = 0; i < keys.length; i++) if (root.heatData[keys[i]] > maxV) maxV = root.heatData[keys[i]]
        if (maxV === 0) maxV = 1

        var cells = []
        var cur   = new Date(start)
        while (cur <= end) {
            var k = _dateKey(cur)
            var v = root.heatData[k] ?? 0
            cells.push({ key: k, value: v, col: Math.floor(cells.length / 7), row: cells.length % 7, norm: v / maxV })
            cur.setDate(cur.getDate() + 1)
        }
        return cells
    }

    // Build grid cells for generic mode
    readonly property var _gridCells: {
        if (!root.rows) return []
        var flat = [], maxV = 0
        for (var r = 0; r < root.rows.length; r++)
            for (var c = 0; c < root.rows[r].length; c++)
                if (root.rows[r][c] > maxV) maxV = root.rows[r][c]
        if (maxV === 0) maxV = 1
        for (var r2 = 0; r2 < root.rows.length; r2++)
            for (var c2 = 0; c2 < root.rows[r2].length; c2++)
                flat.push({ key: r2 + "," + c2, value: root.rows[r2][c2], row: r2, col: c2, norm: root.rows[r2][c2]/maxV })
        return flat
    }

    readonly property var  _cells: root.rows ? _gridCells : _calCells
    readonly property int  _cols: {
        if (_cells.length === 0) return 0
        var m = 0
        for (var i = 0; i < _cells.length; i++) if (_cells[i].col > m) m = _cells[i].col
        return m + 1
    }
    readonly property int  _rowCount: {
        if (_cells.length === 0) return 0
        var m = 0
        for (var i = 0; i < _cells.length; i++) if (_cells[i].row > m) m = _cells[i].row
        return m + 1
    }

    implicitWidth:  _cols * (cellSize + cellGap) - cellGap
    implicitHeight: _rowCount * (cellSize + cellGap) - cellGap

    Repeater {
        model: root._cells
        delegate: Rectangle {
            id: _rq1
            required property var modelData
            required property int index

            x:      modelData.col * (root.cellSize + root.cellGap)
            y:      modelData.row * (root.cellSize + root.cellGap)
            width:  root.cellSize
            height: root.cellSize
            radius: 2
            color:  modelData.value === 0 ? root.colorEmpty : root._interp(modelData.norm)

            HoverHandler { id: _hh }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:    root.cellClicked(_rq1.modelData.key, _rq1.modelData.value)
                onEntered:    root.cellHovered(_rq1.modelData.key, _rq1.modelData.value)
            }
        }
    }
}
