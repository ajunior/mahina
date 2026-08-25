import QtQuick
import Mahina

// Two-month calendar for selecting a start and end date range.
//
// Usage:
//   DateRangePicker {
//       onRangeSelected: (start, end) => filter.setRange(start, end)
//   }
Item {
    id: root

    property var startDate: null  // JS Date or null
    property var endDate:   null  // JS Date or null
    property var hoveredDate: null

    signal rangeSelected(var startDate, var endDate)

    implicitWidth:  560
    implicitHeight: 300

    // Display months: left = current month, right = next month
    property int leftYear:  { var d = new Date(); return d.getFullYear() }
    property int leftMonth: { var d = new Date(); return d.getMonth() }

    property int rightYear:  leftMonth === 11 ? leftYear + 1 : leftYear
    property int rightMonth: (leftMonth + 1) % 12

    function _isoDate(d) {
        if (!d) return ""
        return d.getFullYear() + "-"
            + String(d.getMonth()+1).padStart(2,"0") + "-"
            + String(d.getDate()).padStart(2,"0")
    }

    function _sameDay(a, b) {
        if (!a || !b) return false
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
    }

    function _inRange(d) {
        if (!root.startDate || !d) return false
        var end = root.endDate || root.hoveredDate
        if (!end) return false
        var lo = root.startDate <= end ? root.startDate : end
        var hi = root.startDate <= end ? end : root.startDate
        return d >= lo && d <= hi
    }

    function _handleClick(d) {
        if (!root.startDate || (root.startDate && root.endDate)) {
            root.startDate = d; root.endDate = null
        } else if (d < root.startDate) {
            root.endDate = root.startDate; root.startDate = d
        } else {
            root.endDate = d
            root.rangeSelected(root.startDate, root.endDate)
        }
    }

    Row {
        anchors.fill: parent
        spacing: Theme.sp4

        Repeater {
            model: 2
            delegate: MonthGrid {
                required property int index
                year:  index === 0 ? root.leftYear  : root.rightYear
                month: index === 0 ? root.leftMonth : root.rightMonth
                startDate:   root.startDate
                endDate:     root.endDate
                hoveredDate: root.hoveredDate
                width: (parent.width - Theme.sp4) / 2
                height: parent.height

                onDayClicked:   (d) => root._handleClick(d)
                onDayHovered:   (d) => root.hoveredDate = d
                onDayUnhovered: root.hoveredDate = null
                onPrevClicked: {
                    if (index === 0) {
                        root.leftMonth--
                        if (root.leftMonth < 0) { root.leftMonth = 11; root.leftYear-- }
                    }
                }
                onNextClicked: {
                    if (index === 0) {
                        root.leftMonth++
                        if (root.leftMonth > 11) { root.leftMonth = 0; root.leftYear++ }
                    }
                }
                showPrev: index === 0
                showNext: index === 1
            }
        }
    }

    component MonthGrid: Item {
        id: _mg

        property int  year:  2026
        property int  month: 0
        property var  startDate:   null
        property var  endDate:     null
        property var  hoveredDate: null
        property bool showPrev:    true
        property bool showNext:    true

        signal dayClicked(var date)
        signal dayHovered(var date)
        signal dayUnhovered()
        signal prevClicked()
        signal nextClicked()

        readonly property var monthNames: ["January","February","March","April","May","June","July","August","September","October","November","December"]

        Column {
            anchors.fill: parent
            spacing: Theme.sp2

            // Header
            Row {
                width: parent.width
                spacing: 0

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: prevA.containsMouse ? Theme.panel : "transparent"
                    visible: _mg.showPrev
                    HoverHandler { id: prevA }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _mg.prevClicked() }
                    Text { anchors.centerIn: parent; text: "‹"; color: Theme.textSecondary; font.pixelSize: Theme.textLg }
                }
                Item { width: 1; height: 1 }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  _mg.monthNames[_mg.month] + " " + _mg.year
                    color: Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightSemibold
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width - 56
                }
                Item { width: 1; height: 1 }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: nextA.containsMouse ? Theme.panel : "transparent"
                    visible: _mg.showNext
                    HoverHandler { id: nextA }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _mg.nextClicked() }
                    Text { anchors.centerIn: parent; text: "›"; color: Theme.textSecondary; font.pixelSize: Theme.textLg }
                }
            }

            // Day-of-week headers
            Row {
                width: parent.width
                Repeater {
                    model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                    delegate: Text {
                        required property string modelData
                        width: (_mg.width) / 7
                        horizontalAlignment: Text.AlignHCenter
                        text:  modelData
                        color: Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }
            }

            // Date grid
            Grid {
                id:      _grid
                width:   parent.width
                columns: 7
                spacing: 2

                Repeater {
                    model: {
                        // Build 6-week grid
                        var firstDay = new Date(_mg.year, _mg.month, 1).getDay()
                        var daysInMonth = new Date(_mg.year, _mg.month+1, 0).getDate()
                        var cells = []
                        for (var i = 0; i < firstDay; i++) cells.push(null)
                        for (var d = 1; d <= daysInMonth; d++) cells.push(new Date(_mg.year, _mg.month, d))
                        while (cells.length % 7 !== 0) cells.push(null)
                        return cells
                    }

                    delegate: Item {
                        required property var modelData
                        property var cellDate: modelData
                        width:  _mg.width / 7
                        height: 30

                        readonly property bool isStart:   cellDate && root._sameDay(cellDate, root.startDate)
                        readonly property bool isEnd:     cellDate && root._sameDay(cellDate, root.endDate)
                        readonly property bool inRange:   cellDate && root._inRange(cellDate)
                        readonly property bool isToday:   cellDate && root._sameDay(cellDate, new Date())
                        readonly property bool isHovered: cellDate && root._sameDay(cellDate, root.hoveredDate)

                        Rectangle {
                            anchors.fill: parent
                            color: {
                                if (isStart || isEnd) return Theme.primary
                                if (inRange) return Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)
                                if (isHovered && cellDate) return Theme.panel
                                return "transparent"
                            }
                            radius: (isStart || isEnd) ? 15 : 4
                            Behavior on color { ColorAnimation { duration: 80 } }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: cellDate !== null
                            text:    cellDate ? cellDate.getDate() : ""
                            color: {
                                if (isStart || isEnd) return Theme.textOnPrimary
                                if (isToday) return Theme.primary
                                return Theme.textPrimary
                            }
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            font.weight:    isToday ? Theme.weightSemibold : Theme.weightRegular
                        }

                        HoverHandler { onHoveredChanged: hovered ? _mg.dayHovered(cellDate) : _mg.dayUnhovered() }
                        MouseArea {
                            anchors.fill: parent
                            visible:      cellDate !== null
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    if (cellDate) _mg.dayClicked(cellDate)
                        }
                    }
                }
            }
        }
    }
}
