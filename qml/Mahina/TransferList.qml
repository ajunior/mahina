pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property var    available:      []
    property var    selected:       []
    property string availableLabel: "Available"
    property string selectedLabel:  "Selected"

    signal selectionChanged(var newSelected)

    implicitWidth:  480
    implicitHeight: 300

    // Internal checked sets
    property var _availChecked: []
    property var _selChecked:   []

    function _moveToSelected(): void {
        var avail = root.available.slice()
        var sel   = root.selected.slice()
        var remaining = []
        for (var i = 0; i < avail.length; i++) {
            if (root._availChecked.indexOf(avail[i]) >= 0) sel.push(avail[i])
            else remaining.push(avail[i])
        }
        root.available = remaining
        root.selected  = sel
        root._availChecked = []
        root.selectionChanged(root.selected)
    }

    function _moveToAvailable(): void {
        var avail = root.available.slice()
        var sel   = root.selected.slice()
        var remaining = []
        for (var i = 0; i < sel.length; i++) {
            if (root._selChecked.indexOf(sel[i]) >= 0) avail.push(sel[i])
            else remaining.push(sel[i])
        }
        root.available = avail
        root.selected  = remaining
        root._selChecked = []
        root.selectionChanged(root.selected)
    }

    function _moveAllToSelected(): void {
        var sel = root.selected.concat(root.available)
        root.selected  = sel
        root.available = []
        root._availChecked = []
        root.selectionChanged(root.selected)
    }

    function _moveAllToAvailable(): void {
        var avail = root.available.concat(root.selected)
        root.available = avail
        root.selected  = []
        root._selChecked = []
        root.selectionChanged(root.selected)
    }

    Row {
        anchors.fill: parent
        spacing: Theme.sp3

        // Available list
        TListPanel {
            id: _availPanel
            width:  (parent.width - 60 - Theme.sp3 * 2) / 2
            height: parent.height
            panelLabel: root.availableLabel
            items:      root.available
            checked:    root._availChecked
            onCheckedUpdated: (c) => root._availChecked = c
        }

        // Buttons column
        Column {
            width:  60
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.sp2

            Repeater {
                model: [
                    { label: "›",  tooltip: "Move selected right", action: function() { root._moveToSelected() } },
                    { label: "»",  tooltip: "Move all right",      action: function() { root._moveAllToSelected() } },
                    { label: "‹",  tooltip: "Move selected left",  action: function() { root._moveToAvailable() } },
                    { label: "«",  tooltip: "Move all left",       action: function() { root._moveAllToAvailable() } },
                ]
                delegate: Rectangle {
                    id: _rq2
                    required property var  modelData
                    width:  60; height: 32
                    radius: Theme.radiusSm
                    color:  _btnH.hovered ? Theme.primary : Theme.surface
                    border.color: _btnH.hovered ? Theme.primary : Theme.border
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _btnH }
                    Text {
                        anchors.centerIn: parent
                        text:  _rq2.modelData.label
                        color: _btnH.hovered ? Theme.textOnPrimary : Theme.textPrimary
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: _rq2.modelData.action()
                    }
                }
            }
        }

        // Selected list
        TListPanel {
            id: _selPanel
            width:  (parent.width - 60 - Theme.sp3 * 2) / 2
            height: parent.height
            panelLabel: root.selectedLabel
            items:      root.selected
            checked:    root._selChecked
            onCheckedUpdated: (c) => root._selChecked = c
        }
    }

    // Internal panel component
    component TListPanel: Rectangle {
        id: _dg
        property string panelLabel: ""
        property var    items:      []
        property var    checked:    []

        signal checkedUpdated(var newChecked)

        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                width: parent.width; height: 32
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text {
                        text:  _dg.panelLabel
                        color: Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Font.Medium
                    }
                    Rectangle {
                        width:  _dg.items.length > 0 ? _cntTxt.implicitWidth + 8 : 0
                        height: 18; radius: Theme.radiusFull
                        color:  Theme.primary; visible: _dg.items.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id:    _cntTxt
                            anchors.centerIn: parent
                            text:  _dg.items.length.toString()
                            color: "#ffffff"
                            font.family:    Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: parent.parent.height - 32
                model:  _dg.items
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}
                delegate: Rectangle {
                    id: _rq1
                    required property string modelData
                    required property int    index
                    width:  parent ? parent.width : 0; height: 32
                    color:  _dg.checked.indexOf(modelData) >= 0
                            ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                            : (_tpH.hovered ? Theme.hover : "transparent")
                    HoverHandler { id: _tpH }
                    Row {
                        anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2
                        Rectangle {
                            width: 16; height: 16; radius: 3
                            color:   _dg.checked.indexOf(_rq1.modelData) >= 0 ? Theme.primary : "transparent"
                            border.color: _dg.checked.indexOf(_rq1.modelData) >= 0 ? Theme.primary : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                visible: _dg.checked.indexOf(_rq1.modelData) >= 0
                                text: "✓"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.Bold
                            }
                        }
                        Text {
                            text:  _rq1.modelData
                            color: Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var c = _dg.checked.slice()
                            var idx = c.indexOf(_rq1.modelData)
                            if (idx >= 0) c.splice(idx, 1)
                            else c.push(_rq1.modelData)
                            _dg.checkedUpdated(c)
                        }
                    }
                }
            }
        }
    }
}
