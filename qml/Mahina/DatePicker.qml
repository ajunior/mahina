pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Calendar popup for date selection.
//
// Usage:
//   DatePicker { label: "Start date" }
//   DatePicker { label: "Due date"; selectedDate: new Date(2025, 11, 31) }
//   DatePicker { onDateSelected: (d) => console.log(d.toISOString()) }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    selectedDate: null   // JS Date or null
    property string label:        ""
    property string placeholder:  "Select a date"
    property string helper:       ""
    property string errorText:    ""
    property bool   disabled:     false
    property var    minDate:      null
    property var    maxDate:      null

    readonly property bool hasError: errorText !== ""

    signal dateSelected(var date)

    // ── Formatting ───────────────────────────────────────────────────────────
    readonly property string _displayText: root.selectedDate
        ? _fmt(root.selectedDate) : ""

    function _fmt(d: var): var {
        if (!d) return ""
        return d.getFullYear() + "-"
             + String(d.getMonth() + 1).padStart(2, "0") + "-"
             + String(d.getDate()).padStart(2, "0")
    }

    // ── View state (month/year the popup is showing) ──────────────────────────
    property int _viewYear:  new Date().getFullYear()
    property int _viewMonth: new Date().getMonth()  // 0-based

    readonly property string _monthName: Qt.locale().monthName(_viewMonth)

    // Day grid: 42 cells (6 weeks × 7), 0 = empty/padding
    readonly property var _days: {
        var firstDay  = new Date(_viewYear, _viewMonth, 1).getDay()    // 0=Sun
        var offset    = (firstDay + 6) % 7                              // Mon-first offset
        var daysInMon = new Date(_viewYear, _viewMonth + 1, 0).getDate()
        var cells = []
        for (var i = 0; i < 42; i++) {
            var d = i - offset + 1
            cells.push(d >= 1 && d <= daysInMon ? d : 0)
        }
        return cells
    }

    function _isSelected(day: var): var {
        if (day === 0 || !root.selectedDate) return false
        return root.selectedDate.getFullYear() === root._viewYear
            && root.selectedDate.getMonth()    === root._viewMonth
            && root.selectedDate.getDate()     === day
    }

    function _isToday(day: var): var {
        if (day === 0) return false
        var t = new Date()
        return t.getFullYear() === root._viewYear
            && t.getMonth()    === root._viewMonth
            && t.getDate()     === day
    }

    function _isDisabled(day: var): var {
        if (day === 0) return true
        var d = new Date(root._viewYear, root._viewMonth, day)
        if (root.minDate && d < root.minDate) return true
        if (root.maxDate && d > root.maxDate) return true
        return false
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  240
    implicitHeight: _col.implicitHeight

    readonly property real _fieldH: Theme.textBase + Theme.sp2 * 2 + 2

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        // Label
        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          root.hasError ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Trigger field ─────────────────────────────────────────────────────
        Rectangle {
            id:           _trigger
            Layout.fillWidth: true
            height:       root._fieldH
            color:        Theme.surface
            radius:       Theme.radiusSm
            border.color: root.hasError         ? Theme.error
                        : _popup.opened          ? Theme.primary
                        : _trigHov.hovered ? Theme.borderStrong
                        : Theme.border
            border.width: _popup.opened ? 2 : 1

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _trigHov }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                spacing: Theme.sp2

                Icon { name: Icons.calendarBlank; size: 16; color: Theme.textSecondary }

                Text {
                    text:           root._displayText !== "" ? root._displayText : root.placeholder
                    color:          root._displayText !== "" ? Theme.textPrimary : Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled:      !root.disabled
                cursorShape:  Qt.PointingHandCursor
                onClicked:    _popup.opened ? _popup.close() : _popup.open()
            }
        }

        // Helper / error
        Text {
            visible:        root.errorText !== "" || root.helper !== ""
            text:           root.errorText !== "" ? root.errorText : root.helper
            color:          root.errorText !== "" ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    // ── Calendar popup ────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      _trigger
        y:           _trigger.height + Theme.sp1
        x:           0
        width:       280
        padding:     0
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside
        focus:       true

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast  } }

        background: Rectangle {
            color: Theme.surface; radius: Theme.radiusMd
            border.color: Theme.border; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            // ── Month navigator ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:   true
                Layout.leftMargin:  Theme.sp4
                Layout.rightMargin: Theme.sp4
                Layout.topMargin:   Theme.sp3
                Layout.bottomMargin:Theme.sp3

                // Prev month
                Rectangle {
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: _pmH.hovered ? Theme.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _pmH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root._viewMonth === 0) { root._viewMonth = 11; root._viewYear-- }
                            else root._viewMonth--
                        }
                    }
                    Icon { anchors.centerIn: parent; name: Icons.caretLeft; size: 14; color: Theme.textSecondary }
                }

                Text {
                    text:             root._monthName + " " + root._viewYear
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    font.weight:      Theme.weightSemibold
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Next month
                Rectangle {
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: _nmH.hovered ? Theme.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _nmH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root._viewMonth === 11) { root._viewMonth = 0; root._viewYear++ }
                            else root._viewMonth++
                        }
                    }
                    Icon { anchors.centerIn: parent; name: Icons.caretRight; size: 14; color: Theme.textSecondary }
                }
            }

            // ── Day-of-week header ────────────────────────────────────────────
            Grid {
                Layout.fillWidth:    true
                Layout.leftMargin:   Theme.sp3
                Layout.rightMargin:  Theme.sp3
                Layout.bottomMargin: Theme.sp1
                columns: 7

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    delegate: Item {
                        id: _rq1
                        required property var modelData
                        width:  (280 - Theme.sp3 * 2) / 7; height: 28
                        Text {
                            anchors.centerIn: parent
                            text: _rq1.modelData; color: Theme.textDisabled
                            font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                            font.weight: Theme.weightMedium
                        }
                    }
                }
            }

            // ── Day grid ──────────────────────────────────────────────────────
            Grid {
                id:                  _dayGrid
                Layout.fillWidth:    true
                Layout.leftMargin:   Theme.sp3
                Layout.rightMargin:  Theme.sp3
                Layout.bottomMargin: Theme.sp3
                columns:             7

                Repeater {
                    model: root._days

                    delegate: Item {
                        id: _dg
                        required property var modelData   // day number (0=empty)
                        required property int index

                        readonly property int  _day:      modelData
                        readonly property bool _empty:    _day === 0
                        readonly property bool _selected: root._isSelected(_day)
                        readonly property bool _today:    root._isToday(_day)
                        readonly property bool _disabled: root._isDisabled(_day)

                        width:  (280 - Theme.sp3 * 2) / 7
                        height: 32

                        Rectangle {
                            id:     _cell
                            width:  28; height: 28
                            radius: 14
                            anchors.centerIn: parent
                            color:  _dg._selected ? Theme.primary
                                  : _hov.hovered && !_dg._disabled && !_dg._empty ? Theme.hover
                                  : "transparent"
                            border.color: _dg._today && !_dg._selected ? Theme.primary : "transparent"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            HoverHandler { id: _hov; enabled: !_dg._disabled && !_dg._empty }

                            Text {
                                visible:          !_dg._empty
                                anchors.centerIn: parent
                                text:             _dg._day
                                color:            _dg._selected  ? Theme.textOnPrimary
                                                : _dg._disabled  ? Theme.textDisabled
                                                : _dg._today     ? Theme.primary
                                                : Theme.textPrimary
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.textXs
                                font.weight:      _dg._selected || _dg._today
                                                  ? Theme.weightSemibold : Theme.weightRegular
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled:      !_dg._empty && !_dg._disabled
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedDate = new Date(root._viewYear, root._viewMonth, _dg._day)
                                    root.dateSelected(root.selectedDate)
                                    _popup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
