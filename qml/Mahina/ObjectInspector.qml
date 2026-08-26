pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Expandable key-value tree for inspecting nested objects (DevTools style).
//
// Usage:
//   ObjectInspector {
//       inspectData: ({
//           name: "Alice", age: 30,
//           address: { city: "Berlin", zip: "10115" },
//           tags: ["ux", "design"]
//       })
//   }
Item {
    id: root

    property var    inspectData: ({})
    property string rootLabel:   "Object"
    property int    rowHeight:   26
    property int    indentSize:  16

    implicitWidth:  320
    implicitHeight: _oiCol.implicitHeight

    function _type(v) {
        if (v === null)             return "null"
        if (Array.isArray(v))       return "array"
        return typeof v
    }

    function _preview(v) {
        var t = _type(v)
        if (t === "null")    return "null"
        if (t === "string")  return '"' + v.substring(0, 40) + (v.length > 40 ? "…" : "") + '"'
        if (t === "number" || t === "boolean") return String(v)
        if (t === "array")   return "[" + v.length + " items]"
        if (t === "object")  return "{" + Object.keys(v).length + " keys}"
        return String(v)
    }

    // Flat list of visible rows
    property var _rows: []

    function _rebuild() {
        var out = []
        _addNode(out, root.rootLabel, root.inspectData, 0)
        root._rows = out
    }

    function _addNode(out, key, val, depth) {
        var t   = _type(val)
        var exp = false
        // Check if previously expanded
        var path = key + "|" + depth
        for (var i = 0; i < out.length; i++) { }   // no-op — expansion tracked separately

        out.push({ key: key, val: val, depth: depth, type: t,
                   path: path, expandable: (t === "object" || t === "array") })
    }

    Component.onCompleted: _buildFlat()

    property var _expanded: ({})

    function _buildFlat() {
        var out = []
        _flattenNode(out, root.rootLabel, root.inspectData, 0)
        root._rows = out
    }

    function _flattenNode(out, key, val, depth) {
        var t   = _type(val)
        var exp = root._expanded[depth + ":" + key] || false
        var leaf = t !== "object" && t !== "array"
        out.push({ key: key, val: val, depth: depth, type: t,
                   expandable: !leaf, expanded: exp,
                   nodeKey: depth + ":" + key })
        if (!leaf && exp) {
            if (t === "array") {
                for (var i = 0; i < val.length; i++)
                    _flattenNode(out, "[" + i + "]", val[i], depth + 1)
            } else {
                var keys = Object.keys(val)
                for (var ki = 0; ki < keys.length; ki++)
                    _flattenNode(out, keys[ki], val[keys[ki]], depth + 1)
            }
        }
    }

    onInspectDataChanged: _buildFlat()

    Column {
        id:    _oiCol
        width: parent.width

        Repeater {
            model: root._rows
            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index

                width:  root.width; height: root.rowHeight
                color:  _oiH.hovered ? Theme.panel : (index % 2 === 0 ? Theme.surface : "transparent")
                Behavior on color { ColorAnimation { duration: 60 } }
                HoverHandler { id: _oiH }

                Row {
                    anchors { left: parent.left; leftMargin: _rq1.modelData.depth * root.indentSize + 6
                              verticalCenter: parent.verticalCenter }
                    spacing: 4

                    // Expand chevron
                    Text {
                        visible:        _rq1.modelData.expandable
                        width:          12
                        text:           _rq1.modelData.expanded ? "▾" : "▸"
                        color:          Theme.textDisabled
                        font.pixelSize: 10
                    }

                    Item { visible: !_rq1.modelData.expandable; width: 12; height: 1 }

                    // Key
                    Text {
                        text:           _rq1.modelData.key
                        color:          _rq1.modelData.type === "array" || _rq1.modelData.type === "object"
                                        ? Theme.primary : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Font.Medium
                    }

                    Text {
                        text:           ":"
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }

                    // Value
                    Text {
                        text: {
                            var t = _rq1.modelData.type
                            if (t === "null")    return "null"
                            if (t === "string")  return '"' + _rq1.modelData.val.substring(0, 30) + (_rq1.modelData.val.length > 30 ? "…" : "") + '"'
                            if (t === "number" || t === "boolean") return String(_rq1.modelData.val)
                            if (t === "array")   return "Array(" + _rq1.modelData.val.length + ")"
                            if (t === "object")  return "Object {" + Object.keys(_rq1.modelData.val).join(", ").substring(0, 30) + "}"
                            return ""
                        }
                        color: {
                            var t = _rq1.modelData.type
                            if (t === "string")  return Theme.success
                            if (t === "number")  return Theme.info
                            if (t === "boolean") return Theme.warning
                            if (t === "null")    return Theme.textDisabled
                            return Theme.textSecondary
                        }
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!_rq1.modelData.expandable) return
                        var nk = _rq1.modelData.nodeKey
                        var exp = root._expanded
                        exp[nk] = !exp[nk]
                        root._expanded = exp
                        root._buildFlat()
                    }
                }
            }
        }
    }
}
