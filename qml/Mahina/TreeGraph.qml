import QtQuick
import Mahina

// Expandable tree structure with animated collapsing nodes.
//
// Usage:
//   TreeGraph {
//       model: [
//           { label: "Root",
//             children: [
//               { label: "Branch A", children: [{ label: "Leaf 1" }, { label: "Leaf 2" }] },
//               { label: "Branch B", children: [] }
//             ]
//           }
//       ]
//   }
Item {
    id: root

    property var    treeModel:  []
    property int    indentSize: 20
    property color  connectorColor: Theme.border
    property int    nodeHeight: 36

    signal nodeClicked(var node)

    implicitWidth:  320
    implicitHeight: _col.implicitHeight

    function _flattenVisible(nodes, depth, result) {
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            var hasChildren = !!(n.children && n.children.length > 0)
            result.push({ node: n, depth: depth, hasChildren: hasChildren, expanded: !!n._expanded })
            if (hasChildren && n._expanded) {
                _flattenVisible(n.children, depth + 1, result)
            }
        }
        return result
    }

    readonly property var flatNodes: {
        var res = []
        _flattenVisible(root.treeModel, 0, res)
        return res
    }

    Column {
        id:    _col
        width: parent.width

        Repeater {
            model: root.flatNodes
            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                width:  root.width
                height: root.nodeHeight

                readonly property int itemDepth:       modelData.depth
                readonly property bool itemHasChildren: modelData.hasChildren
                readonly property bool itemExpanded:   modelData.expanded

                // Connector line
                Rectangle {
                    visible: itemDepth > 0
                    x:      (itemDepth - 1) * root.indentSize + 10
                    y:      0; width: 1; height: parent.height / 2
                    color:  root.connectorColor
                }
                Rectangle {
                    visible: itemDepth > 0
                    x:      (itemDepth - 1) * root.indentSize + 10
                    y:      parent.height / 2; width: root.indentSize - 4; height: 1
                    color:  root.connectorColor
                }

                // Hover background
                Rectangle {
                    anchors.fill: parent
                    color:  _rowH.hovered ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                    HoverHandler { id: _rowH }
                }

                // Expand toggle
                Rectangle {
                    visible: itemHasChildren
                    x:       itemDepth * root.indentSize
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 4
                    color: Theme.surfaceVariant
                    border.color: Theme.border; border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text:           itemExpanded ? "−" : "+"
                        color:          Theme.textSecondary
                        font.pixelSize: 12
                        font.family:    Theme.fontFamily
                    }
                }

                Text {
                    x:                    itemDepth * root.indentSize + (itemHasChildren ? 22 : 4)
                    anchors.verticalCenter: parent.verticalCenter
                    text:               _rq1.modelData.node.label || ""
                    color:              Theme.textPrimary
                    font.family:        Theme.fontFamily
                    font.pixelSize:     Theme.textBase
                    font.weight:        itemHasChildren ? Font.Medium : Font.Normal
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (_rq1.modelData.hasChildren) {
                            _rq1.modelData.node._expanded = !_rq1.modelData.node._expanded
                            var copy = root.treeModel.slice()
                            root.treeModel = copy
                        }
                        root.nodeClicked(_rq1.modelData.node)
                    }
                }
            }
        }
    }
}
