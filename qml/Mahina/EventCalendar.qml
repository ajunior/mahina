pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Full month calendar grid with event dots.
//
// Usage:
//   EventCalendar {
//       year:  2026; month: 5   // 0-based: 5 = June
//       events: [
//           { date: "2026-06-03", title: "Sprint review",   color: Theme.primary },
//           { date: "2026-06-15", title: "Team off-site",   color: Theme.success },
//           { date: "2026-06-28", title: "Product launch",  color: Theme.warning },
//       ]
//       onDayClicked: (date, evs) => showEvents(evs)
//   }
Item {
    id: root

    property int year:  new Date().getFullYear()
    property int month: new Date().getMonth()
    property var events: []

    signal dayClicked(var date, var events)

    implicitWidth:  420
    implicitHeight: 340

    readonly property var monthNames: ["January","February","March","April","May","June",
                                       "July","August","September","October","November","December"]

    function _eventsOn(y, m, d) {
        var key = y + "-" + String(m+1).padStart(2,"0") + "-" + String(d).padStart(2,"0")
        var evs = []
        for (var i = 0; i < root.events.length; i++) {
            if (root.events[i].date === key) evs.push(root.events[i])
        }
        return evs
    }

    Column {
        anchors.fill: parent
        spacing: Theme.sp2

        // Month navigation header
        Rectangle {
            width:  parent.width
            height: 44
            color:  Theme.panel
            radius: Theme.radiusMd

            Row {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                spacing: 0

                Rectangle {
                    width: 32; height: 32; radius: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: _prevH.containsMouse ? Theme.surfaceVariant : "transparent"
                    HoverHandler { id: _prevH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.month--
                            if (root.month < 0) { root.month = 11; root.year-- }
                        }
                    }
                    Text { anchors.centerIn: parent; text: "‹"; color: Theme.textSecondary; font.pixelSize: Theme.textLg }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  root.monthNames[root.month] + " " + root.year
                    color: Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    font.weight:    Theme.weightSemibold
                    width: parent.width - 64
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 32; height: 32; radius: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: _nextH.containsMouse ? Theme.surfaceVariant : "transparent"
                    HoverHandler { id: _nextH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.month++
                            if (root.month > 11) { root.month = 0; root.year++ }
                        }
                    }
                    Text { anchors.centerIn: parent; text: "›"; color: Theme.textSecondary; font.pixelSize: Theme.textLg }
                }
            }
        }

        // Day-of-week headers
        Row {
            width: parent.width
            Repeater {
                model: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                delegate: Text {
                    required property string modelData
                    width: root.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text:  modelData
                    color: Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightSemibold
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
                    var firstDay     = new Date(root.year, root.month, 1).getDay()
                    var daysInMonth  = new Date(root.year, root.month+1, 0).getDate()
                    var cells = []
                    for (var i = 0; i < firstDay; i++) cells.push(-1)
                    for (var d = 1; d <= daysInMonth; d++) cells.push(d)
                    while (cells.length % 7 !== 0) cells.push(-1)
                    return cells
                }

                delegate: Item {
                    required property int modelData
                    property int  dayNum:  modelData
                    property bool valid:   dayNum > 0
                    property var  dayEvts: valid ? root._eventsOn(root.year, root.month, dayNum) : []
                    property bool isToday: {
                        var t = new Date()
                        return valid && t.getFullYear() === root.year && t.getMonth() === root.month && t.getDate() === dayNum
                    }

                    width:  root.width / 7
                    height: Math.max(36, (root.height - 44 - 24 - Theme.sp2 * 2) / 6)

                    Rectangle {
                        anchors { fill: parent; margins: 1 }
                        radius:  Theme.radiusSm
                        color:   isToday ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.1)
                                         : _cellH.containsMouse && valid ? Theme.panel : "transparent"
                        border.color: isToday ? Theme.primary : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }

                        HoverHandler { id: _cellH }

                        Column {
                            anchors { fill: parent; margins: 4 }
                            spacing: 2

                            Text {
                                visible: valid
                                text:    dayNum > 0 ? dayNum : ""
                                color:   isToday ? Theme.primary : Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight:    isToday ? Theme.weightBold : Theme.weightRegular
                            }

                            // Event dots (up to 3)
                            Column {
                                spacing: 2
                                visible: dayEvts.length > 0
                                Repeater {
                                    model: Math.min(dayEvts.length, 3)
                                    delegate: Rectangle {
                                        required property int index
                                        width:  parent.width; height: 4; radius: 2
                                        color:  index < dayEvts.length ? (dayEvts[index].color || Theme.primary) : Theme.primary
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            visible:      valid
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.dayClicked(new Date(root.year, root.month, dayNum), dayEvts)
                        }
                    }
                }
            }
        }
    }
}
