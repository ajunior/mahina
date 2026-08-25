import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import Mahina

// Drag-and-drop file upload area with an optional file list below.
//
// Usage:
//   FileUpload {
//       onFilesChanged: uploadAll(files)
//   }
//
//   FileUpload {
//       multiple:  true
//       accept:    ["image/png", "image/jpeg", ".svg"]
//       maxFiles:  5
//       label:     "Profile photo"
//   }
//
// `files` is a list of strings (local file:// URLs from the OS drag or dialog).
Item {
    id: root

    property var    files:       []
    property bool   multiple:    false
    property var    accept:      []       // MIME types or extensions; empty = any
    property int    maxFiles:    0        // 0 = unlimited
    property string label:       ""
    property string helper:      "Drag files here or click to browse"
    property bool   disabled:    false

    signal fileAdded(string url)
    signal fileRemoved(int index, string url)

    implicitWidth:  320
    implicitHeight: _col.implicitHeight

    readonly property bool _full: root.maxFiles > 0 && root.files.length >= root.maxFiles

    function _addUrl(url) {
        if (root._full) return
        if (!root.multiple && root.files.length > 0) root.files = []
        var newFiles = root.files.slice()
        newFiles.push(url)
        root.files = newFiles
        root.fileAdded(url)
    }

    function _basename(url) {
        var s = url.toString()
        return s.substring(s.lastIndexOf("/") + 1)
    }

    FileDialog {
        id:           _fileDialog
        fileMode:     root.multiple ? FileDialog.OpenFiles : FileDialog.OpenFile
        onAccepted: {
            var urls = root.multiple ? selectedFiles : [selectedFile]
            for (var i = 0; i < urls.length; i++) _addUrl(urls[i])
        }
    }

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // Drop zone
        DropArea {
            id:              _drop
            Layout.fillWidth: true
            height:           120

            onDropped: (drop) => {
                if (!drop.hasUrls) return
                var urls = drop.urls
                for (var i = 0; i < urls.length; i++) _addUrl(urls[i])
            }

            Rectangle {
                anchors.fill:  parent
                radius:        Theme.radiusMd
                color:         _drop.containsDrag ? Theme.primarySubtle
                             : _zoneH.containsMouse ? Theme.panel
                             : "transparent"
                border.color:  _drop.containsDrag ? Theme.primary : Theme.border
                border.width:  _drop.containsDrag ? 2 : 1
                // Dashed border approximation via clip + another rect
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                HoverHandler { id: _zoneH; enabled: !root.disabled }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing:          Theme.sp2

                    Icon {
                        Layout.alignment: Qt.AlignHCenter
                        name:  Icons.uploadSimple
                        size:  32
                        color: _drop.containsDrag ? Theme.primary : Theme.textDisabled
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           root._full ? "Maximum files reached"
                                      : root.helper
                        color:          _drop.containsDrag ? Theme.primary : Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    }

                    Text {
                        visible:          root.accept.length > 0 && !root._full
                        Layout.alignment: Qt.AlignHCenter
                        text:             root.accept.join(", ")
                        color:            Theme.textDisabled
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textXs
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    enabled:      !root.disabled && !root._full
                    onClicked:    _fileDialog.open()
                }
            }
        }

        // File list
        Column {
            visible:         root.files.length > 0
            Layout.fillWidth: true
            spacing:          Theme.sp1

            Repeater {
                model: root.files
                delegate: Rectangle {
                    id: _rq1
                    required property string modelData
                    required property int    index

                    width:  parent.width; height: 40
                    radius: Theme.radiusSm
                    color:  Theme.panel
                    border.color: Theme.border; border.width: 1

                    RowLayout {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                        spacing: Theme.sp2

                        Icon { name: Icons.file; size: 16; color: Theme.textSecondary }

                        Text {
                            text:             root._basename(_rq1.modelData)
                            color:            Theme.textPrimary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textSm
                            elide:            Text.ElideMiddle
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 24; height: 24; radius: Theme.radiusSm
                            color: _rmH.containsMouse ? Theme.errorSubtle : "transparent"
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            HoverHandler { id: _rmH }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var removed = _rq1.modelData
                                    var newFiles = root.files.slice()
                                    newFiles.splice(_rq1.index, 1)
                                    root.files = newFiles
                                    root.fileRemoved(_rq1.index, removed)
                                }
                            }
                            Icon { anchors.centerIn: parent; name: Icons.x; size: 12; color: Theme.error }
                        }
                    }
                }
            }
        }
    }
}
