pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string pickedFamily:   Qt.application.font.family
    property int    pickedSize:     12
    property int    pickedWeight:   Font.Normal
    property bool   pickedItalic:   false

    signal fontPicked(string family, int size, int weight, bool italic)

    implicitWidth:  460
    implicitHeight: 44

    readonly property var _weights: [
        { label: "Thin",       value: Font.Thin      },
        { label: "Light",      value: Font.Light     },
        { label: "Regular",    value: Font.Normal    },
        { label: "Medium",     value: Font.Medium    },
        { label: "SemiBold",   value: Font.DemiBold  },
        { label: "Bold",       value: Font.Bold      },
        { label: "ExtraBold",  value: Font.ExtraBold },
        { label: "Black",      value: Font.Black     },
    ]

    function _weightLabel(w) {
        for (var i = 0; i < _weights.length; i++)
            if (_weights[i].value === w) return _weights[i].label
        return "Regular"
    }

    function _emit() {
        root.fontPicked(root.pickedFamily, root.pickedSize, root.pickedWeight, root.pickedItalic)
    }

    Row {
        anchors.fill: parent
        spacing:      Theme.sp2

        // Family dropdown
        Item {
            width:  parent.width - 130 - 100 - 44 - Theme.sp2 * 3
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSm
                color:  Theme.surface
                border.color: _famPop.visible ? Theme.primary : Theme.border
                border.width: _famPop.visible ? 2 : 1
                clip: true

                Row {
                    anchors { left: parent.left; right: _famArrow.left; leftMargin: Theme.sp3
                               verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text {
                        text:  root.pickedFamily
                        color: Theme.textPrimary
                        font { family: root.pickedFamily; pixelSize: Theme.textSm
                               italic: root.pickedItalic; weight: root.pickedWeight }
                        elide: Text.ElideRight
                    }
                }
                Text {
                    id:    _famArrow
                    anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                    text:  _famPop.visible ? "▴" : "▾"
                    color: Theme.textSecondary; font.pixelSize: 10
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { _famPop.visible = !_famPop.visible; _famSearch.forceActiveFocus() }
                }
            }

            // Family popup
            Rectangle {
                id:      _famPop
                visible: false
                parent:  root
                x:       0
                y:       48
                width:   root.width - 130 - 100 - 44 - Theme.sp2 * 3
                height:  260
                z:       200
                radius:  Theme.radiusSm
                color:   Theme.surface
                border.color: Theme.border
                border.width: 1
                clip: true

                Column {
                    anchors.fill: parent

                    Rectangle {
                        width: parent.width; height: 36
                        color: "transparent"
                        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2
                                       rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                            spacing: Theme.sp2
                            Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            TextInput {
                                id:    _famSearch
                                width: parent.width - 20 - Theme.sp2
                                anchors.verticalCenter: parent.verticalCenter
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                onTextChanged:  _famList.query = text
                                Text {
                                    visible: _famSearch.text === ""
                                    text: "Search font…"; color: Theme.textDisabled; font: _famSearch.font
                                }
                            }
                        }
                    }

                    ListView {
                        id:    _famList
                        property string query: ""
                        width:  parent.width
                        height: 224
                        clip:   true
                        model:  Qt.fontFamilies().filter(function(f) {
                                    return query === "" || f.toLowerCase().indexOf(query.toLowerCase()) >= 0
                                })
                        QQC.ScrollBar.vertical: QQC.ScrollBar {}
                        delegate: Rectangle {
                            id: _rq1
                            required property string modelData
                            width:  parent ? parent.width : 0
                            height: 28
                            color:  _ffH.hovered
                                    ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.08)
                                    : (modelData === root.pickedFamily ? Theme.panel : "transparent")
                            HoverHandler { id: _ffH }
                            Text {
                                anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                                text:  _rq1.modelData
                                color: _rq1.modelData === root.pickedFamily ? Theme.primary : Theme.textPrimary
                                font { family: _rq1.modelData; pixelSize: Theme.textSm }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.pickedFamily = _rq1.modelData
                                    _famPop.visible = false
                                    _famSearch.text = ""
                                    root._emit()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Weight dropdown
        Item {
            width:  130
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSm
                color:  Theme.surface
                border.color: _wgtPop.visible ? Theme.primary : Theme.border
                border.width: _wgtPop.visible ? 2 : 1

                Text {
                    anchors { left: parent.left; right: _wgtArr.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    text:  root._weightLabel(root.pickedWeight)
                    color: Theme.textPrimary
                    font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: root.pickedWeight }
                }
                Text {
                    id:    _wgtArr
                    anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                    text:  _wgtPop.visible ? "▴" : "▾"; color: Theme.textSecondary; font.pixelSize: 10
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _wgtPop.visible = !_wgtPop.visible }
            }

            Rectangle {
                id:      _wgtPop
                visible: false
                parent:  root
                x:       root.width - 130 - 100 - 44 - Theme.sp2 * 2 + 130 + Theme.sp2
                y:       48
                width:   130
                height:  root._weights.length * 30 + 2
                z:       200
                radius:  Theme.radiusSm
                color:   Theme.surface
                border.color: Theme.border
                border.width: 1
                clip: true

                ListView {
                    anchors.fill: parent
                    model: root._weights
                    delegate: Rectangle {
                        id: _rq2
                        required property var  modelData
                        width:  parent ? parent.width : 0
                        height: 30
                        color:  _wH.hovered
                                ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.08)
                                : (modelData.value === root.pickedWeight ? Theme.panel : "transparent")
                        HoverHandler { id: _wH }
                        Text {
                            anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            text:  _rq2.modelData.label; color: _rq2.modelData.value === root.pickedWeight ? Theme.primary : Theme.textPrimary
                            font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: _rq2.modelData.value }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { root.pickedWeight = _rq2.modelData.value; _wgtPop.visible = false; root._emit() }
                        }
                    }
                }
            }
        }

        // Size stepper
        Rectangle {
            width:  100
            height: 44
            radius: Theme.radiusSm
            color:  Theme.surface
            border.color: _sizeInput.activeFocus ? Theme.primary : Theme.border
            border.width: 1
            clip: true

            Row {
                anchors.fill: parent

                Rectangle {
                    width:  28; height: parent.height
                    color:  _szDecH.hovered ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _szDecH }
                    Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.pixelSize: 14 }
                    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.pickedSize = Math.max(6, root.pickedSize - 1); _sizeInput.text = root.pickedSize.toString(); root._emit() }
                    }
                }

                TextInput {
                    id:    _sizeInput
                    width: parent.width - 56; height: parent.height
                    text:  root.pickedSize.toString()
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment:   TextInput.AlignVCenter
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    selectByMouse:  true
                    inputMethodHints: Qt.ImhDigitsOnly
                    onEditingFinished: {
                        var v = parseInt(text)
                        if (!isNaN(v) && v >= 6 && v <= 144) root.pickedSize = v
                        text = root.pickedSize.toString()
                        root._emit()
                    }
                }

                Rectangle {
                    width:  28; height: parent.height
                    color:  _szIncH.hovered ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _szIncH }
                    Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.pixelSize: 14 }
                    Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.pickedSize = Math.min(144, root.pickedSize + 1); _sizeInput.text = root.pickedSize.toString(); root._emit() }
                    }
                }
            }
        }

        // Italic toggle
        Rectangle {
            width:  44
            height: 44
            radius: Theme.radiusSm
            color:  root.pickedItalic
                    ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.15)
                    : (_iH.hovered ? Theme.panel : Theme.surface)
            border.color: root.pickedItalic ? Theme.primary : Theme.border
            border.width: root.pickedItalic ? 2 : 1
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _iH }

            Text {
                anchors.centerIn: parent
                text:  "I"
                color: root.pickedItalic ? Theme.primary : Theme.textSecondary
                font { family: Theme.fontFamily; pixelSize: Theme.textBase; italic: true; weight: Font.Bold }
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: { root.pickedItalic = !root.pickedItalic; root._emit() }
            }
        }
    }
}
