pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // shortcutCategories: [{category, shortcuts: [{id, label, binding}]}]
    property var    shortcutCategories: []
    property string searchText:         ""

    signal shortcutChanged(string id, string newBinding)
    signal resetRequested()

    implicitWidth:  460
    implicitHeight: 400

    property string _recordingId: ""

    function _flatten(): var {
        var out = []
        var q = root.searchText.toLowerCase()
        for (var i = 0; i < root.shortcutCategories.length; i++) {
            var cat = root.shortcutCategories[i]
            var items = []
            for (var j = 0; j < cat.shortcuts.length; j++) {
                var s = cat.shortcuts[j]
                if (q === "" || s.label.toLowerCase().indexOf(q) >= 0 || s.binding.toLowerCase().indexOf(q) >= 0)
                    items.push(s)
            }
            if (items.length > 0) {
                out.push({ isHeader: true, label: cat.category })
                for (var k = 0; k < items.length; k++) out.push({ isHeader: false, item: items[k] })
            }
        }
        return out
    }

    readonly property var _rows: _flatten()

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

            // Header
            Rectangle {
                width: parent.width; height: 44
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; topMargin: 6; bottomMargin: 6 }
                    spacing: Theme.sp2

                    Rectangle {
                        width: parent.width - 72 - Theme.sp2; height: 32
                        radius: Theme.radiusSm; color: Theme.surface
                        border.color: _scSearch.activeFocus ? Theme.primary : Theme.border; border.width: 1
                        Row {
                            anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                            spacing: Theme.sp2
                            Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            TextInput {
                                id:    _scSearch
                                width: parent.width - 20 - Theme.sp2
                                anchors.verticalCenter: parent.verticalCenter
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                onTextChanged:  root.searchText = text
                                Text { visible: _scSearch.text === ""; text: "Search…"; color: Theme.textDisabled; font: _scSearch.font }
                            }
                        }
                    }

                    Rectangle {
                        width: 72; height: 32
                        radius: Theme.radiusSm
                        color:  _rstH.hovered ? Theme.hover : "transparent"
                        border.color: Theme.border; border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _rstH }
                        Text { anchors.centerIn: parent; text: "Reset"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.resetRequested() }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 44
                model:  root._rows
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Loader {
                    required property var  modelData
                    required property int  index
                    width: parent ? parent.width : 0
                    sourceComponent: modelData.isHeader ? _headerComp : _rowComp
                    property var rowData: modelData
                }

                Component {
                    id: _headerComp
                    Rectangle {
                        width:  parent ? parent.width : 0
                        height: 28
                        color:  Theme.panel
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                        Text {
                            anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            text:  (parent as Loader) ? (parent as Loader).rowData.label : ""
                            color: Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: 11
                            font.weight:    Font.Medium
                        }
                    }
                }

                Component {
                    id: _rowComp
                    Rectangle {
                        id:     _scRowRect
                        width:  parent ? parent.width : 0
                        height: 40
                        property var item: (parent as Loader) ? (parent as Loader).rowData.item : ({})
                        color:  _scH.hovered ? Theme.hover : "transparent"
                        HoverHandler { id: _scH }
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp4; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            spacing: Theme.sp3

                            Text {
                                width:  parent.width - 160 - Theme.sp3
                                text:   _scRowRect.item.label || ""
                                color:  Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                id:     _bindingRect
                                width:  160; height: 28
                                radius: Theme.radiusSm
                                color:  root._recordingId === _scRowRect.item.id
                                        ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10)
                                        : Theme.surface
                                border.color: root._recordingId === _scRowRect.item.id ? Theme.primary : Theme.border
                                border.width: root._recordingId === _scRowRect.item.id ? 2 : 1
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text:  root._recordingId === _scRowRect.item.id
                                           ? "Press keys…"
                                           : (_scRowRect.item.binding || "—")
                                    color: root._recordingId === _scRowRect.item.id ? Theme.primary : Theme.textPrimary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                }

                                Item {
                                    id:    _captureItem
                                    anchors.fill: parent
                                    focus: root._recordingId === _scRowRect.item.id
                                    Keys.onPressed: (e) => {
                                        if (root._recordingId !== _scRowRect.item.id) return
                                        e.accepted = true
                                        if (e.key === Qt.Key_Escape) { root._recordingId = ""; return }
                                        if (e.key === Qt.Key_Control || e.key === Qt.Key_Shift ||
                                            e.key === Qt.Key_Alt || e.key === Qt.Key_Meta) return
                                        var parts = []
                                        if (e.modifiers & Qt.ControlModifier) parts.push("Ctrl")
                                        if (e.modifiers & Qt.AltModifier)     parts.push("Alt")
                                        if (e.modifiers & Qt.ShiftModifier)   parts.push("Shift")
                                        if (e.key >= Qt.Key_A && e.key <= Qt.Key_Z) parts.push(String.fromCharCode(e.key))
                                        else if (e.key >= Qt.Key_F1 && e.key <= Qt.Key_F12) parts.push("F" + (e.key - Qt.Key_F1 + 1))
                                        if (parts.length > 0) {
                                            var b = parts.join("+")
                                            root.shortcutChanged(_scRowRect.item.id, b)
                                        }
                                        root._recordingId = ""
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root._recordingId = _scRowRect.item.id
                                        _captureItem.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
