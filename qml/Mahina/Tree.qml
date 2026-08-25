import QtQuick
import QtQuick.Layouts
import Mahina

// Collapsible hierarchical data tree.
//
// Usage:
//   Tree {
//       model: [
//           { label: "src", icon: Icons.folder, children: [
//               { label: "Button.qml", icon: Icons.file },
//               { label: "Input.qml",  icon: Icons.file },
//           ]},
//           { label: "CMakeLists.txt", icon: Icons.file },
//       ]
//       onNodeClicked: (node) => openFile(node.label)
//   }
//
// Node shape: { label, icon?, id?, children? }
// Assign a new array (or reassign model) to trigger refresh.
// Toggle expansion programmatically: tree.setExpanded("nodeId", true)
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var model: []
    property real indentWidth: 20
    property real rowHeight:   32

    signal nodeClicked(var node)
    signal nodeToggled(string nodeId, bool expanded)

    function setExpanded(nodeId, expanded) {
        var e = Object.assign({}, root._expanded)
        e[nodeId] = expanded
        root._expanded = e
    }

    function expandAll()  { _setAll(root.model, true) }
    function collapseAll(){ _setAll(root.model, false) }

    function _setAll(nodes, val) {
        if (!nodes) return
        var e = Object.assign({}, root._expanded)
        for (var i = 0; i < nodes.length; i++) {
            e[_nodeId(nodes[i], i)] = val
            if (nodes[i].children) _setAll(nodes[i].children, val)
        }
        root._expanded = e
    }

    // ── Internal ─────────────────────────────────────────────────────────────
    property var _expanded: ({})

    function _nodeId(node, fallback) {
        return node.id ?? (node.label + "@" + fallback)
    }

    // Flatten tree to a list for the ListView
    readonly property var _flat: {
        void root._expanded   // explicit dependency
        return _flatten(root.model, 0)
    }

    function _flatten(nodes, depth) {
        var result = []
        if (!nodes) return result
        for (var i = 0; i < nodes.length; i++) {
            var n   = nodes[i]
            var nid = _nodeId(n, i)
            var hasChildren = !!(n.children && n.children.length > 0)
            var exp = root._expanded[nid] ?? false
            result.push({ label: n.label ?? "", icon: n.icon ?? "", nodeId: nid,
                          depth: depth, hasChildren: hasChildren, expanded: exp,
                          _src: n })
            if (hasChildren && exp)
                result = result.concat(_flatten(n.children, depth + 1))
        }
        return result
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  260
    implicitHeight: root._flat.length * root.rowHeight

    ListView {
        id:           _list
        anchors.fill: parent
        model:        root._flat
        clip:         true
        interactive:  false   // parent handles scrolling

        delegate: Item {
            id:       _rowItem
            required property var modelData
            required property int index

            width:  _list.width
            height: root.rowHeight

            // Hover background
            Rectangle {
                anchors.fill: parent
                radius:       Theme.radiusSm
                color:        _rowHov.containsMouse ? Theme.panel : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            HoverHandler { id: _rowHov }

            RowLayout {
                anchors {
                    fill:        parent
                    leftMargin:  _rowItem.modelData.depth * root.indentWidth + Theme.sp2
                    rightMargin: Theme.sp2
                }
                spacing: Theme.sp2

                // Expand/collapse toggle
                Item {
                    implicitWidth:  16
                    implicitHeight: 16

                    Icon {
                        anchors.fill: parent
                        visible:      _rowItem.modelData.hasChildren
                        name:         _rowItem.modelData.expanded ? Icons.caretDown : Icons.caretRight
                        size:         14
                        color:        Theme.textSecondary
                    }

                    MouseArea {
                        anchors.fill: parent
                        visible:      _rowItem.modelData.hasChildren
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    (e) => {
                            e.accepted = true
                            var nowExp = !_rowItem.modelData.expanded
                            root.setExpanded(_rowItem.modelData.nodeId, nowExp)
                            root.nodeToggled(_rowItem.modelData.nodeId, nowExp)
                        }
                    }
                }

                // Node icon
                Icon {
                    visible: _rowItem.modelData.icon !== ""
                    name:    _rowItem.modelData.icon !== "" ? _rowItem.modelData.icon
                           : _rowItem.modelData.hasChildren ? Icons.folder : Icons.file
                    size:    16
                    color:   _rowItem.modelData.hasChildren ? Theme.warning : Theme.textSecondary
                }

                // Label
                Text {
                    text:             _rowItem.modelData.label
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    elide:            Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.nodeClicked(_rowItem.modelData._src)
            }
        }
    }
}
