pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property var    hexBytes:   []      // array of ints 0-255
    property int    columns:    16
    property bool   showAscii:  true
    property int    rowHeight:  22
    property int    selectedOffset: -1  // highlighted byte offset

    signal byteSelected(int offset, int value)

    implicitWidth:  620
    implicitHeight: 340

    readonly property int _addrW:  52
    readonly property int _hexW:   root.columns * 26
    readonly property int _gapW:   16
    readonly property int _asciiW: root.showAscii ? root.columns * 9 : 0
    readonly property int _rows:   Math.ceil(root.hexBytes.length / root.columns)

    function _toHex2(n: var): var {
        var s = n.toString(16).toUpperCase()
        return s.length < 2 ? "0" + s : s
    }

    function _isPrint(n: var): var { return n >= 0x20 && n < 0x7f }

    Rectangle {
        anchors.fill: parent
        color:  Theme.dark ? "#0d1117" : "#f6f8fa"
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent

            // Column headers
            Rectangle {
                width: parent.width; height: 24
                color: Theme.dark ? "#161b22" : "#eaeef2"
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { left: parent.left; leftMargin: root._addrW + 8; verticalCenter: parent.verticalCenter }
                    spacing: 0
                    Repeater {
                        model: root.columns
                        delegate: Text {
                            required property int index
                            width: 26
                            horizontalAlignment: Text.AlignHCenter
                            text:  root._toHex2(index)
                            color: Theme.textDisabled
                            font { family: Theme.fontFamilyMono; pixelSize: 10 }
                        }
                    }
                    Item { width: root._gapW; height: 1; visible: root.showAscii }
                    Text {
                        visible: root.showAscii
                        text:   "ASCII"
                        color:  Theme.textDisabled
                        font { family: Theme.fontFamilyMono; pixelSize: 10 }
                    }
                }
            }

            // Scrollable hex rows
            Flickable {
                width:  parent.width
                height: root.height - 24
                contentWidth:  width
                contentHeight: root._rows * root.rowHeight + 8
                clip: true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                Column {
                    topPadding: 4; spacing: 0; width: parent.width

                    Repeater {
                        model: root._rows
                        delegate: Row {
                            id: _rq1
                            required property int index
                            height: root.rowHeight
                            width:  parent ? parent.width : 0

                            // Address
                            Rectangle {
                                width: root._addrW + 8; height: parent.height
                                color: "transparent"
                                Text {
                                    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                    text:  {
                                        var addr = _rq1.index * root.columns
                                        var s = addr.toString(16).toUpperCase()
                                        while (s.length < 6) s = "0" + s
                                        return s
                                    }
                                    color: Theme.textDisabled
                                    font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                                }
                            }

                            // Hex bytes
                            Row {
                                spacing: 0; height: parent.height
                                Repeater {
                                    model: root.columns
                                    delegate: Rectangle {
                                        id: _dg
                                        required property int index
                                        property int offset: _rq1.index * root.columns + _dg.index
                                        property bool valid:  offset < root.hexBytes.length
                                        width: 26; height: root.rowHeight
                                        color: offset === root.selectedOffset
                                               ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.15)
                                               : (_hvH.hovered && valid ? Theme.panel : "transparent")
                                        HoverHandler { id: _hvH }
                                        Text {
                                            anchors.centerIn: parent
                                            text:  _dg.valid ? root._toHex2(root.hexBytes[_dg.offset]) : ""
                                            color: {
                                                if (!_dg.valid) return "transparent"
                                                var v = root.hexBytes[_dg.offset]
                                                if (v === 0) return Theme.textDisabled
                                                if (v < 0x20 || v >= 0x7f) return Theme.warning
                                                return _dg.offset === root.selectedOffset ? Theme.primary : Theme.textPrimary
                                            }
                                            font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            visible: _dg.valid
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.selectedOffset = _dg.offset
                                                root.byteSelected(_dg.offset, root.hexBytes[_dg.offset])
                                            }
                                        }
                                    }
                                }
                            }

                            // Gap
                            Item { width: root._gapW; height: parent.height; visible: root.showAscii }

                            // ASCII column
                            Row {
                                visible: root.showAscii
                                spacing: 0; height: parent.height
                                Repeater {
                                    model: root.columns
                                    delegate: Text {
                                        id: _asciiCell
                                        required property int index
                                        property int offset: _rq1.index * root.columns + _asciiCell.index
                                        property bool valid:  offset < root.hexBytes.length
                                        width: 9
                                        text: {
                                            if (!valid) return ""
                                            var v = root.hexBytes[offset]
                                            return root._isPrint(v) ? String.fromCharCode(v) : "·"
                                        }
                                        color: {
                                            if (!valid) return "transparent"
                                            if (offset === root.selectedOffset) return Theme.primary
                                            return root._isPrint(root.hexBytes[offset]) ? Theme.textPrimary : Theme.textDisabled
                                        }
                                        font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                                        anchors.verticalCenter: parent.verticalCenter
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
