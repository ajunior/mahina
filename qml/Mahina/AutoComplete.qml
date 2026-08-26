pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Text input with a suggestion dropdown. Supports static array filtering or
// async suggestions (emit searchChanged and set model dynamically).
//
// Usage (static):
//   AutoComplete {
//       label: "City"
//       model: ["Amsterdam", "Barcelona", "Cairo", "Delhi", "Edinburgh"]
//       onSelected: (item) => setCity(item)
//   }
//
// Usage (async):
//   AutoComplete {
//       id: _search
//       label: "Repository"
//       staticFilter: false
//       model: searchResults   // updated externally on searchChanged
//       onSearchChanged: (q) => fetchRepos(q)
//       onSelected: (item) => openRepo(item)
//   }
//
// Item shape: string  OR  { label, description?, icon? }
Item {
    id: root

    property var    model:         []
    property bool   staticFilter:  true    // false = pass-through; caller filters model
    property string placeholder:   "Search…"
    property string label:         ""
    property string helper:        ""
    property string errorText:     ""
    property bool   disabled:      false
    property int    maxItems:      8

    signal selected(var item)
    signal searchChanged(string query)

    implicitWidth:  260
    implicitHeight: _col.implicitHeight

    readonly property bool _hasError: root.errorText !== ""
    property bool _focused: false
    property string _query: ""

    function _label(item) { return typeof item === "string" ? item : (item.label ?? "") }
    function _desc(item)  { return typeof item === "string" ? "" : (item.description ?? "") }
    function _icon(item)  { return typeof item === "string" ? "" : (item.icon ?? "") }

    readonly property var _suggestions: {
        if (!root.staticFilter) return root.model.slice(0, root.maxItems)
        var q = root._query.toLowerCase()
        if (q === "") return []
        return root.model.filter(function(it) {
            return root._label(it).toLowerCase().indexOf(q) >= 0
        }).slice(0, root.maxItems)
    }

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        Rectangle {
            id:              _trigger
            Layout.fillWidth: true
            height:          40
            color:           root.disabled ? Theme.panel : Theme.surface
            radius:          Theme.radiusMd
            border.color:    root._hasError ? Theme.error
                           : root._focused  ? Theme.primary
                           : Theme.border
            border.width:    root._focused || root._hasError ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                spacing: Theme.sp2

                Icon { name: Icons.magnifyingGlass; size: 16; color: Theme.textSecondary }

                TextInput {
                    id:             _input
                    color:          root.disabled ? Theme.textDisabled : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    enabled:        !root.disabled
                    Layout.fillWidth: true

                    onTextChanged: {
                        root._query = text
                        root.searchChanged(text)
                        if (text !== "") _popup.open()
                        else             _popup.close()
                    }

                    onActiveFocusChanged: root._focused = activeFocus

                    Keys.onEscapePressed: { _popup.close(); root._focused = false }
                    Keys.onReturnPressed: {
                        if (root._suggestions.length > 0) {
                            var it = root._suggestions[0]
                            _input.text = root._label(it)
                            root.selected(it)
                            _popup.close()
                        }
                    }
                }

                // Clear
                Rectangle {
                    visible: _input.text !== ""
                    width: 20; height: 20; radius: 10
                    color: _clH.containsMouse ? Theme.border : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _clH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { _input.text = ""; _popup.close() } }
                    Icon { anchors.centerIn: parent; name: Icons.x; size: 10; color: Theme.textSecondary }
                }
            }

            // Placeholder
            Text {
                visible:        _input.text === ""
                anchors { left: parent.left; leftMargin: Theme.sp3 + 16 + Theme.sp2; verticalCenter: parent.verticalCenter }
                text:           root.placeholder
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }
        }

        Text {
            visible:        root.helper !== "" && !root._hasError
            text:           root.helper
            color:          Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
        Text {
            visible:        root._hasError
            text:           root.errorText
            color:          Theme.error
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    QQC.Popup {
        id:          _popup
        parent:      _trigger
        y:           _trigger.height + Theme.sp1
        x:           0
        width:       _trigger.width
        padding:     Theme.sp1
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast } }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Column {
            Repeater {
                model: root._suggestions

                delegate: Rectangle {
                    id: _rq1
                    required property var modelData

                    width:  _popup.width - Theme.sp2
                    height: root._desc(modelData) !== "" ? 50 : 36
                    radius: Theme.radiusSm
                    color:  _sH.containsMouse ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _sH }

                    RowLayout {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                        spacing: Theme.sp2

                        Icon {
                            visible: root._icon(_rq1.modelData) !== ""
                            name:    root._icon(_rq1.modelData)
                            size:    16; color: Theme.textSecondary
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text:           root._label(_rq1.modelData)
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                Layout.fillWidth: true
                            }
                            Text {
                                visible:        root._desc(_rq1.modelData) !== ""
                                text:           root._desc(_rq1.modelData)
                                color:          Theme.textDisabled
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                Layout.fillWidth: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            _input.text = root._label(_rq1.modelData)
                            root.selected(_rq1.modelData)
                            _popup.close()
                        }
                    }
                }
            }
        }
    }
}
