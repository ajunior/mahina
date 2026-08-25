import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Collapsible JSON tree viewer.
//
// Usage:
//   JsonViewer {
//       value: ({ name: "Mahina", version: "1.0", tags: ["qml", "ui"], meta: { dark: true } })
//   }
//
//   JsonViewer { value: JSON.parse(responseText) }
Item {
    id: root

    property var    value:      null
    property int    indentSize: 16
    property bool   expanded:   true    // initial expand state
    property real   fontSize:   Theme.textSm

    implicitWidth:  400
    implicitHeight: _list.contentHeight + 2

    // Flat model rebuilt when value or collapse state changes
    ListModel { id: _model }

    property var _collapsed: ({})   // path → true when collapsed

    function _rebuild() {
        _model.clear()
        _flatten(root.value, null, 0, "root")
    }

    function _flatten(obj, key, depth, path) {
        var isArr = Array.isArray(obj)
        var isObj = typeof obj === "object" && obj !== null && !isArr

        if (isObj || isArr) {
            var childKeys = isArr ? [] : Object.keys(obj)
            var count     = isArr ? obj.length : childKeys.length
            var isColl    = !!_collapsed[path]
            var opener    = isArr ? "[" : "{"
            var closer    = isArr ? "]" : "}"
            _model.append({ key: key ?? "", valueStr: opener, typeStr: isArr ? "array" : "object",
                            depth: depth, path: path, count: count, isCollapsed: isColl, isCloser: false, isKey: false })
            if (!isColl) {
                if (isArr) {
                    for (var i = 0; i < obj.length; i++)
                        _flatten(obj[i], null, depth + 1, path + "/" + i)
                } else {
                    for (var j = 0; j < childKeys.length; j++)
                        _flatten(obj[childKeys[j]], childKeys[j], depth + 1, path + "/" + childKeys[j])
                }
                _model.append({ key: "", valueStr: closer, typeStr: "close",
                                depth: depth, path: path + "__close", count: 0, isCollapsed: false, isCloser: true, isKey: false })
            }
        } else {
            var t   = obj === null ? "null" : typeof obj
            var val = obj === null ? "null" : JSON.stringify(obj)
            _model.append({ key: key ?? "", valueStr: val, typeStr: t,
                            depth: depth, path: path, count: 0, isCollapsed: false, isCloser: false, isKey: false })
        }
    }

    function _typeColor(t) {
        switch (t) {
            case "string":  return "#a6e3a1"
            case "number":  return "#fab387"
            case "boolean": return "#89b4fa"
            case "null":    return "#6c7086"
            case "object": case "array": return Theme.textSecondary
            default:        return Theme.textPrimary
        }
    }

    Component.onCompleted: _rebuild()
    onValueChanged:        _rebuild()

    ListView {
        id:                  _list
        anchors.fill:        parent
        model:               _model
        clip:                true
        interactive:         false     // let parent scroll
        boundsBehavior:      Flickable.StopAtBounds

        delegate: Item {
            width:  _list.width
            height: 22

            readonly property bool _isExpandable: model.typeStr === "object" || model.typeStr === "array"

            Row {
                x:       model.depth * root.indentSize
                y:       3
                spacing: 4

                // Expand/collapse triangle
                Item {
                    width:  14; height: 16
                    visible: _isExpandable && !model.isCloser

                    Text {
                        anchors.centerIn: parent
                        text:   model.isCollapsed ? "▶" : "▼"
                        color:  Theme.textSecondary
                        font.pixelSize: 9
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = model.path
                            var c = Object.assign({}, root._collapsed)
                            if (c[p]) delete c[p]
                            else      c[p] = true
                            root._collapsed = c
                            root._rebuild()
                        }
                    }
                }

                Item { width: _isExpandable && !model.isCloser ? 0 : 14; height: 1 }

                // Key
                Text {
                    visible:        !model.isCloser && model.key !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text:           model.key !== "" ? ('"' + model.key + '": ') : ""
                    color:          "#cba6f7"
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: root.fontSize
                }

                // Value / opener
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           model.isCollapsed
                                    ? model.valueStr + (model.typeStr === "array" ? " " : " ") +
                                      (model.typeStr === "array" ? "…]" : "…}") +
                                      " // " + model.count + " item" + (model.count === 1 ? "" : "s")
                                    : model.valueStr
                    color:          root._typeColor(model.typeStr)
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: root.fontSize
                }
            }
        }
    }
}
