pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // element: {tag, id, properties: [{name, value, type, category}]}
    property var    element:    null
    property string searchText: ""

    signal propertyClicked(string name, var value)

    implicitWidth:  280
    implicitHeight: 360

    readonly property var _grouped: {
        if (!root.element || !root.element.properties) return []
        var q    = root.searchText.toLowerCase()
        var cats = {}
        var ord  = []
        var props = root.element.properties
        for (var i = 0; i < props.length; i++) {
            var p = props[i]
            if (q && p.name.toLowerCase().indexOf(q) < 0) continue
            var cat = p.category || "General"
            if (!cats[cat]) { cats[cat] = []; ord.push(cat) }
            cats[cat].push(p)
        }
        var out = []
        for (var j = 0; j < ord.length; j++) {
            out.push({ isHeader: true, label: ord[j] })
            var items = cats[ord[j]]
            for (var k = 0; k < items.length; k++) out.push({ isHeader: false, prop: items[k] })
        }
        return out
    }

    function _valueColor(type: var): var {
        if (type === "number")  return Theme.info
        if (type === "boolean") return Theme.warning
        if (type === "color")   return Theme.success
        if (type === "string")  return Theme.primary
        return Theme.textPrimary
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

            // Element header
            Rectangle {
                width: parent.width; height: 52
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Column {
                    anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: 2
                    Text {
                        text:  root.element ? ("<" + (root.element.tag || "unknown") + ">") : "No element"
                        color: Theme.primary
                        font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm; weight: Font.Bold }
                    }
                    Text {
                        text:  root.element ? (root.element.id ? "#" + root.element.id : "anonymous") : ""
                        color: Theme.textDisabled
                        font { family: Theme.fontFamilyMono; pixelSize: 11 }
                    }
                }
            }

            // Search
            Rectangle {
                width: parent.width; height: 36
                color: "transparent"
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    TextInput {
                        id:    _ipSearch
                        width: parent.width - 20 - Theme.sp2
                        anchors.verticalCenter: parent.verticalCenter
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        onTextChanged:  root.searchText = text
                        Text { visible: _ipSearch.text === ""; text: "Filter…"; color: Theme.textDisabled; font: _ipSearch.font }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: root.height - 52 - 36
                model:  root._grouped
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                delegate: Loader {
                    required property var  modelData
                    required property int  index
                    width: parent ? parent.width : 0
                    property var rowData: modelData
                    sourceComponent: modelData.isHeader ? _ipHeader : _ipRow
                }

                Component {
                    id: _ipHeader
                    Rectangle {
                        width:  parent ? parent.width : 0; height: 24
                        color:  Theme.panel
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                        Text {
                            anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            text:  (parent as Loader) ? (parent as Loader).rowData.label : ""
                            color: Theme.textSecondary
                            font { family: Theme.fontFamily; pixelSize: 10; weight: Font.Medium }
                        }
                    }
                }

                Component {
                    id: _ipRow
                    Rectangle {
                        id:    _ipRowR
                        width: parent ? parent.width : 0; height: 30
                        property var prop: (parent as Loader) ? (parent as Loader).rowData.prop : ({})
                        color: _ipH.hovered ? Theme.panel : "transparent"
                        HoverHandler { id: _ipH }
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                        Row {
                            anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            spacing: Theme.sp3

                            Text {
                                width:  parent.width * 0.45
                                text:  _ipRowR.prop.name || ""
                                color: Theme.textSecondary
                                font { family: Theme.fontFamilyMono; pixelSize: 11 }
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Color swatch for color type
                            Rectangle {
                                visible: _ipRowR.prop.type === "color"
                                width: 14; height: 14; radius: 3
                                color:  _ipRowR.prop.value || "#000000"
                                border.color: Theme.border; border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width:  parent.width * 0.55 - (_ipRowR.prop.type === "color" ? 18 : 0) - Theme.sp3
                                text:   {
                                    var v = _ipRowR.prop.value
                                    if (v === null || v === undefined) return "null"
                                    if (typeof v === "boolean") return v ? "true" : "false"
                                    return v.toString()
                                }
                                color:  root._valueColor(_ipRowR.prop.type)
                                font { family: Theme.fontFamilyMono; pixelSize: 11 }
                                elide:  Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.propertyClicked(_ipRowR.prop.name, _ipRowR.prop.value)
                        }
                    }
                }
            }
        }
    }
}
