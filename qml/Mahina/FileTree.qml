pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// File system tree with folder/file icons and selection.
//
// Usage:
//   FileTree {
//       treeFiles: [
//           { name: "src", isDir: true, children: [
//               { name: "main.qml", isDir: false },
//               { name: "components", isDir: true, children: [
//                   { name: "Button.qml", isDir: false }
//               ]}
//           ]},
//           { name: "CMakeLists.txt", isDir: false },
//       ]
//       onFileSelected: (path) => openFile(path)
//   }
Item {
    id: root

    property var    treeFiles:    []
    property string selectedPath: ""
    property int    rowHeight:    28

    signal fileSelected(string path)
    signal dirToggled(string path, bool expanded)

    implicitWidth:  280
    implicitHeight: _col.implicitHeight

    function _flatten(nodes, depth, parentPath, result) {
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            var p = (parentPath !== "" ? parentPath + "/" : "") + n.name
            result.push({ node: n, depth: depth, path: p, isDir: !!n.isDir, expanded: !!n._expanded })
            if (n.isDir && n._expanded && n.children) {
                _flatten(n.children, depth + 1, p, result)
            }
        }
        return result
    }

    readonly property var flatTree: {
        var r = []
        _flatten(root.treeFiles, 0, "", r)
        return r
    }

    Column {
        id:    _col
        width: parent.width

        Repeater {
            model: root.flatTree
            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index
                width:  root.width; height: root.rowHeight
                color:  modelData.path === root.selectedPath
                        ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                  Qt.color(Theme.primary).b, 0.1)
                        : (_fH.hovered ? Theme.panel : "transparent")
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _fH }

                Row {
                    anchors { left: parent.left; leftMargin: _rq1.modelData.depth * 16 + 6; verticalCenter: parent.verticalCenter }
                    spacing: 5

                    // Expand/collapse chevron for dirs
                    Text {
                        visible:        _rq1.modelData.isDir
                        width:          12
                        text:           _rq1.modelData.expanded ? "▾" : "▸"
                        color:          Theme.textDisabled
                        font.pixelSize: 10
                    }

                    // Icon
                    Text {
                        text: _rq1.modelData.isDir
                              ? (_rq1.modelData.expanded ? "📂" : "📁")
                              : _fileIcon(_rq1.modelData.node.name || "")
                        font.pixelSize: 13
                    }

                    Text {
                        text:           _rq1.modelData.node.name || ""
                        color:          _rq1.modelData.path === root.selectedPath
                                        ? Theme.primary : Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    _rq1.modelData.isDir ? Font.Medium : Font.Normal
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (_rq1.modelData.isDir) {
                            _rq1.modelData.node._expanded = !_rq1.modelData.node._expanded
                            var copy = root.treeFiles.slice()
                            root.treeFiles = copy
                            root.dirToggled(_rq1.modelData.path, _rq1.modelData.node._expanded)
                        } else {
                            root.selectedPath = _rq1.modelData.path
                            root.fileSelected(_rq1.modelData.path)
                        }
                    }
                }
            }
        }
    }

    function _fileIcon(name) {
        var ext = name.split(".").pop().toLowerCase()
        switch (ext) {
            case "qml": case "js": case "ts": return "📜"
            case "json": return "🔧"
            case "md": return "📝"
            case "png": case "jpg": case "svg": return "🖼"
            case "cmake": case "txt": return "📄"
            default: return "📄"
        }
    }
}
