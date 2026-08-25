import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string currentPath:   "/"
    // fileEntries: [{name, type: "file"|"dir", size, modified, icon}]
    property var    fileEntries:   []
    property string sortField:     "name"
    property bool   sortAscending: true
    property var    selectedFiles: []
    property bool   showHidden:    false

    signal fileActivated(string name)
    signal directoryChanged(string path)
    signal selectionChanged(var files)

    implicitWidth:  540
    implicitHeight: 400

    readonly property var _sorted: {
        var items = root.fileEntries.filter(function(f) {
            return root.showHidden || !f.name.startsWith(".")
        })
        return items.slice().sort(function(a, b) {
            // Dirs first
            if (a.type === "dir" && b.type !== "dir") return -1
            if (a.type !== "dir" && b.type === "dir") return  1
            var va = a[root.sortField] || ""
            var vb = b[root.sortField] || ""
            var r = va < vb ? -1 : va > vb ? 1 : 0
            return root.sortAscending ? r : -r
        })
    }

    function _fileIcon(f) {
        if (f.icon) return f.icon
        if (f.type === "dir") return "📁"
        var ext = f.name.split(".").pop().toLowerCase()
        var map = { js: "📜", ts: "📜", qml: "📄", json: "{ }", md: "📝",
                    png: "🖼", jpg: "🖼", svg: "🖼", gif: "🖼",
                    mp4: "🎬", mp3: "🎵", wav: "🎵",
                    zip: "🗜", tar: "🗜", gz: "🗜",
                    pdf: "📕", txt: "📝", xml: "📄", html: "🌐", css: "🎨" }
        return map[ext] || "📄"
    }

    function _fmtSize(bytes) {
        if (!bytes) return ""
        if (bytes < 1024)   return bytes + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / 1048576).toFixed(1) + " MB"
    }

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Breadcrumb toolbar
            Rectangle {
                width: parent.width; height: 40
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2; topMargin: 6; bottomMargin: 6 }
                    spacing: Theme.sp2

                    // Back button
                    Rectangle {
                        width: 28; height: 28; radius: Theme.radiusSm
                        color: _backH.hovered ? Theme.panel : "transparent"
                        border.color: _backH.hovered ? Theme.border : "transparent"; border.width: 1
                        HoverHandler { id: _backH }
                        Text { anchors.centerIn: parent; text: "←"; color: Theme.textSecondary; font.pixelSize: 14 }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var parts = root.currentPath.split("/").filter(function(p) { return p !== "" })
                                if (parts.length > 0) {
                                    parts.pop()
                                    root.currentPath = "/" + parts.join("/")
                                    root.directoryChanged(root.currentPath)
                                }
                            }
                        }
                    }

                    // Path display
                    Rectangle {
                        width:  parent.width - 28 - 28 - 28 - Theme.sp2 * 3
                        height: 28; radius: Theme.radiusSm
                        color:  Theme.surface
                        border.color: Theme.border; border.width: 1
                        Row {
                            anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                            spacing: 2
                            Repeater {
                                model: {
                                    var parts = root.currentPath.split("/").filter(function(p) { return p !== "" })
                                    var out = [{ label: "⊟", path: "/" }]
                                    var built = ""
                                    for (var i = 0; i < parts.length; i++) {
                                        built += "/" + parts[i]
                                        out.push({ label: parts[i], path: built })
                                    }
                                    return out
                                }
                                delegate: Row {
                                    id: _rq1
                                    required property var  modelData
                                    required property int  index
                                    spacing: 2
                                    Text {
                                        visible: _rq1.index > 0
                                        text: "›"; color: Theme.textDisabled; font.pixelSize: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text:  _rq1.modelData.label
                                        color: Theme.textPrimary
                                        font { family: Theme.fontFamily; pixelSize: Theme.textSm }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { root.currentPath = _rq1.modelData.path; root.directoryChanged(_rq1.modelData.path) }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Refresh
                    Rectangle {
                        width: 28; height: 28; radius: Theme.radiusSm
                        color: _rfH.hovered ? Theme.panel : "transparent"
                        border.color: _rfH.hovered ? Theme.border : "transparent"; border.width: 1
                        HoverHandler { id: _rfH }
                        Text { anchors.centerIn: parent; text: "⟳"; color: Theme.textSecondary; font.pixelSize: 14 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.directoryChanged(root.currentPath) }
                    }

                    // Show hidden toggle
                    Rectangle {
                        width: 28; height: 28; radius: Theme.radiusSm
                        color: root.showHidden
                               ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                               : (_hidH.hovered ? Theme.panel : "transparent")
                        border.color: root.showHidden ? Theme.primary : (_hidH.hovered ? Theme.border : "transparent"); border.width: 1
                        HoverHandler { id: _hidH }
                        Text { anchors.centerIn: parent; text: "◌"; color: root.showHidden ? Theme.primary : Theme.textSecondary; font.pixelSize: 13 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showHidden = !root.showHidden }
                    }
                }
            }

            // Column headers
            Rectangle {
                width: parent.width; height: 28
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: 36 + Theme.sp2; rightMargin: Theme.sp3 }
                    Repeater {
                        model: [
                            { field: "name", label: "Name",     flex: 1    },
                            { field: "size", label: "Size",     width: 72  },
                            { field: "modified", label: "Modified", width: 110 },
                        ]
                        delegate: Rectangle {
                            id: _rq2
                            required property var  modelData
                            required property int  index
                            width:  modelData.width || (parent.width - 72 - 110)
                            height: parent.height
                            color:  _colH.hovered ? Theme.panel : "transparent"
                            HoverHandler { id: _colH }
                            Row {
                                anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text:  _rq2.modelData.label
                                    color: root.sortField === _rq2.modelData.field ? Theme.primary : Theme.textSecondary
                                    font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                                }
                                Text {
                                    visible: root.sortField === _rq2.modelData.field
                                    text:    root.sortAscending ? "▴" : "▾"
                                    color:   Theme.primary; font.pixelSize: 9
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.sortField === _rq2.modelData.field) root.sortAscending = !root.sortAscending
                                    else { root.sortField = _rq2.modelData.field; root.sortAscending = true }
                                }
                            }
                        }
                    }
                }
            }

            // File list
            ListView {
                width:  parent.width
                height: root.height - 40 - 28
                model:  root._sorted
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Rectangle {
                    id: _rq3
                    required property var  modelData
                    required property int  index
                    width:  parent ? parent.width : 0; height: 32
                    color:  root.selectedFiles.indexOf(modelData.name) >= 0
                            ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                            : (_fmH.hovered ? Theme.panel : "transparent")
                    HoverHandler { id: _fmH }
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                    Row {
                        anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2

                        Text {
                            width: 24
                            text:  root._fileIcon(_rq3.modelData)
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width:  parent.width - 24 - 72 - 110 - Theme.sp2 * 3
                            text:   _rq3.modelData.name || ""
                            color:  _rq3.modelData.type === "dir" ? Theme.primary : Theme.textPrimary
                            font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: _rq3.modelData.type === "dir" ? Font.Medium : Font.Normal }
                            elide:  Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width:  72
                            text:   _rq3.modelData.type === "dir" ? "—" : root._fmtSize(_rq3.modelData.size)
                            color:  Theme.textDisabled
                            font { family: Theme.fontFamily; pixelSize: 11 }
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width:  110
                            text:   _rq3.modelData.modified || "—"
                            color:  Theme.textDisabled
                            font { family: Theme.fontFamily; pixelSize: 11 }
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var sel = root.selectedFiles.slice()
                            var idx = sel.indexOf(_rq3.modelData.name)
                            if (idx >= 0) sel.splice(idx, 1)
                            else sel.push(_rq3.modelData.name)
                            root.selectedFiles = sel
                            root.selectionChanged(sel)
                        }
                        onDoubleClicked: {
                            if (_rq3.modelData.type === "dir") {
                                root.currentPath = root.currentPath.replace(/\/$/, "") + "/" + _rq3.modelData.name
                                root.directoryChanged(root.currentPath)
                            } else {
                                root.fileActivated(_rq3.modelData.name)
                            }
                        }
                    }
                }
            }
        }
    }
}
