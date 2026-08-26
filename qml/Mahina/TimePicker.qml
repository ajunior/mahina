pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Hour/minute selector popup, complement to DatePicker.
//
// Usage:
//   TimePicker { label: "Start time"; onTimeSelected: (h, m) => applyTime(h, m) }
//   TimePicker { hour: 9; minute: 30; use24h: false }
//   TimePicker { disabled: true; helper: "Set in account settings" }
Item {
    id: root

    property int    hour:      0     // 0–23
    property int    minute:    0     // 0–59
    property bool   use24h:    true
    property string label:     ""
    property string helper:    ""
    property string errorText: ""
    property bool   disabled:  false

    signal timeSelected(int hour, int minute)

    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    readonly property bool _hasError: root.errorText !== ""

    // Formatted display string
    readonly property string _display: {
        if (root.use24h) {
            return String(root.hour).padStart(2, "0") + ":" + String(root.minute).padStart(2, "0")
        } else {
            var h = root.hour % 12
            if (h === 0) h = 12
            var ampm = root.hour < 12 ? "AM" : "PM"
            return String(h).padStart(2, "0") + ":" + String(root.minute).padStart(2, "0") + " " + ampm
        }
    }

    // Popup state tracks editing copies
    property int _editHour:   root.hour
    property int _editMinute: root.minute
    property bool _isAM:      root.hour < 12

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

        // Trigger field
        Rectangle {
            id:           _trigger
            Layout.fillWidth: true
            height:       40
            color:        root.disabled ? Theme.panel : Theme.surface
            radius:       Theme.radiusMd
            border.color: root._hasError ? Theme.error : _popup.opened ? Theme.primary : Theme.border
            border.width: _popup.opened || root._hasError ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                spacing: Theme.sp2

                Text {
                    text:           root._display
                    color:          root.disabled ? Theme.textDisabled : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightMedium
                    Layout.fillWidth: true
                }

                Icon { name: Icons.clock; size: 16; color: Theme.textSecondary }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                enabled:      !root.disabled
                onClicked: {
                    root._editHour   = root.hour
                    root._editMinute = root.minute
                    root._isAM       = root.hour < 12
                    _popup.open()
                }
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

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      _trigger
        y:           _trigger.height + Theme.sp1
        x:           0
        width:       root.use24h ? 180 : 220
        padding:     Theme.sp4
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast } }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: Theme.sp4

            // Spinners row
            RowLayout {
                spacing: Theme.sp2
                Layout.fillWidth: true

                // Hour spinner
                ColumnLayout {
                    spacing: Theme.sp1
                    Layout.fillWidth: true

                    Text {
                        text:           "Hour"
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Up button
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 28; radius: Theme.radiusSm
                        color: _uhH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _uhH }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var max = root.use24h ? 23 : 11
                                root._editHour = (root._editHour + 1) > max ? 0 : root._editHour + 1
                            }
                        }
                        Icon { anchors.centerIn: parent; name: Icons.caretUp; size: 14; color: Theme.textSecondary }
                    }

                    // Hour display
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 40; radius: Theme.radiusMd
                        color: Theme.panel; border.color: Theme.border; border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: {
                                var h = root._editHour
                                if (!root.use24h) { h = h % 12; if (h === 0) h = 12 }
                                return String(h).padStart(2, "0")
                            }
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textLg
                            font.weight:    Theme.weightSemibold
                        }
                    }

                    // Down button
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 28; radius: Theme.radiusSm
                        color: _dhH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _dhH }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var max = root.use24h ? 23 : 11
                                root._editHour = (root._editHour - 1) < 0 ? max : root._editHour - 1
                            }
                        }
                        Icon { anchors.centerIn: parent; name: Icons.caretDown; size: 14; color: Theme.textSecondary }
                    }
                }

                // Separator
                Text {
                    text:  ":"
                    color: Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXl
                    font.weight:    Theme.weightBold
                    Layout.alignment: Qt.AlignVCenter
                }

                // Minute spinner
                ColumnLayout {
                    spacing: Theme.sp1
                    Layout.fillWidth: true

                    Text {
                        text:           "Minute"
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 28; radius: Theme.radiusSm
                        color: _umH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _umH }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._editMinute = (root._editMinute + 5) % 60
                            }
                        }
                        Icon { anchors.centerIn: parent; name: Icons.caretUp; size: 14; color: Theme.textSecondary }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 40; radius: Theme.radiusMd
                        color: Theme.panel; border.color: Theme.border; border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text:           String(root._editMinute).padStart(2, "0")
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textLg
                            font.weight:    Theme.weightSemibold
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 28; radius: Theme.radiusSm
                        color: _dmH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _dmH }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._editMinute = (root._editMinute - 5 + 60) % 60
                            }
                        }
                        Icon { anchors.centerIn: parent; name: Icons.caretDown; size: 14; color: Theme.textSecondary }
                    }
                }

                // AM/PM toggle (12h mode)
                ColumnLayout {
                    visible:          !root.use24h
                    spacing:          Theme.sp1
                    Layout.fillWidth: true

                    Text {
                        text:           " "
                        font.pixelSize: Theme.textXs
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Repeater {
                        model: ["AM", "PM"]
                        delegate: Rectangle {
                            id: _rq1
                            required property string modelData
                            required property int    index

                            readonly property bool _sel: index === 0 ? root._isAM : !root._isAM

                            Layout.alignment: Qt.AlignHCenter
                            width:  44; height: 28; radius: Theme.radiusSm
                            color:  _sel ? Theme.primary : (_amH.hovered ? Theme.hover : "transparent")
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            HoverHandler { id: _amH }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root._isAM = (_rq1.index === 0)
                                    // Adjust hour to match AM/PM
                                    var h = root._editHour % 12
                                    root._editHour = root._isAM ? h : h + 12
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                text:           _rq1.modelData
                                color:          parent._sel ? "#ffffff" : Theme.textSecondary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight:    Theme.weightMedium
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Apply button
            Rectangle {
                Layout.fillWidth: true
                height:           36; radius: Theme.radiusMd
                color:            _apH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                HoverHandler { id: _apH }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.hour   = root._editHour
                        root.minute = root._editMinute
                        root.timeSelected(root.hour, root.minute)
                        _popup.close()
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text:           "Apply"
                    color:          "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightMedium
                }
            }
        }
    }
}
