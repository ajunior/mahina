pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string selectedZone: "UTC"
    property string searchText:   ""

    signal zoneSelected(string timezone)

    implicitWidth:  280
    implicitHeight: 40

    readonly property var _zones: [
        "UTC",
        "America/New_York",   "America/Chicago",    "America/Denver",
        "America/Los_Angeles","America/Anchorage",   "America/Honolulu",
        "America/Sao_Paulo",  "America/Argentina/Buenos_Aires",
        "Europe/London",      "Europe/Paris",        "Europe/Berlin",
        "Europe/Moscow",      "Europe/Istanbul",
        "Africa/Cairo",       "Africa/Johannesburg",
        "Asia/Dubai",         "Asia/Kolkata",        "Asia/Dhaka",
        "Asia/Bangkok",       "Asia/Singapore",      "Asia/Tokyo",
        "Asia/Seoul",         "Asia/Shanghai",
        "Australia/Sydney",   "Pacific/Auckland",
    ]

    readonly property var _offsets: ({
        "UTC": "±0",
        "America/New_York":    "−5/−4", "America/Chicago":   "−6/−5",
        "America/Denver":      "−7/−6", "America/Los_Angeles":"−8/−7",
        "America/Anchorage":   "−9/−8", "America/Honolulu":  "−10",
        "America/Sao_Paulo":   "−3",    "America/Argentina/Buenos_Aires": "−3",
        "Europe/London":       "+0/+1", "Europe/Paris":       "+1/+2",
        "Europe/Berlin":       "+1/+2", "Europe/Moscow":      "+3",
        "Europe/Istanbul":     "+3",    "Africa/Cairo":       "+2",
        "Africa/Johannesburg": "+2",    "Asia/Dubai":         "+4",
        "Asia/Kolkata":        "+5:30", "Asia/Dhaka":         "+6",
        "Asia/Bangkok":        "+7",    "Asia/Singapore":     "+8",
        "Asia/Tokyo":          "+9",    "Asia/Seoul":         "+9",
        "Asia/Shanghai":       "+8",    "Australia/Sydney":   "+10/+11",
        "Pacific/Auckland":    "+12/+13"
    })

    function _label(z: var): var {
        var parts = z.split("/")
        return parts[parts.length - 1].replace(/_/g, " ")
    }

    function _filtered(): var {
        if (root.searchText === "") return root._zones
        var q = root.searchText.toLowerCase()
        return root._zones.filter(function(z) {
            return z.toLowerCase().indexOf(q) >= 0
        })
    }

    Rectangle {
        id:    _trigger
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: _popup.visible ? Theme.primary : Theme.border
        border.width: _popup.visible ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 100 } }

        Row {
            anchors { left: parent.left; right: _arr.left; leftMargin: Theme.sp3
                      verticalCenter: parent.verticalCenter }
            spacing: Theme.sp2
            Text {
                text:  "🌐"
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                Text {
                    text:  root._label(root.selectedZone)
                    color: Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }
                Text {
                    text:  "UTC " + (root._offsets[root.selectedZone] || "")
                    color: Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: 10
                }
            }
        }

        Text {
            id:    _arr
            anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
            text:  _popup.visible ? "▴" : "▾"
            color: Theme.textSecondary
            font.pixelSize: 10
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.searchText = ""
                _searchInput.text = ""
                _popup.visible = !_popup.visible
            }
        }
    }

    // Popup
    Rectangle {
        id:      _popup
        visible: false
        parent:  root
        x:       0
        y:       44
        width:   root.width
        height:  260
        z:       100
        radius:  Theme.radiusSm
        color:   Theme.surface
        border.color: Theme.border
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent

            // Search
            Rectangle {
                width:  parent.width
                height: 36
                color:  "transparent"
                border.color: Theme.border
                border.width: 0
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1; color: Theme.border
                }
                Row {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                               leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                    spacing: Theme.sp2
                    Text { text: "🔍"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    TextInput {
                        id:    _searchInput
                        width: parent.width - 20 - Theme.sp2
                        anchors.verticalCenter: parent.verticalCenter
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        onTextChanged:  root.searchText = text
                        Text {
                            visible: _searchInput.text === ""
                            text:  "Search timezone…"
                            color: Theme.textDisabled
                            font:  _searchInput.font
                        }
                    }
                }
            }

            ListView {
                width:  parent.width
                height: 224
                model:  root._filtered()
                clip:   true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}
                delegate: Rectangle {
                    id: _rq1
                    required property string modelData
                    width:  parent ? parent.width : 0
                    height: 36
                    color:  _tzH.hovered
                            ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.08)
                            : (modelData === root.selectedZone ? Theme.panel : "transparent")
                    HoverHandler { id: _tzH }
                    Row {
                        anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3
                                  verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2
                        Text {
                            text:  root._label(_rq1.modelData)
                            color: _rq1.modelData === root.selectedZone ? Theme.primary : Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _rq1.modelData === root.selectedZone ? Font.Medium : Font.Normal
                        }
                        Text {
                            text:  "UTC " + (root._offsets[_rq1.modelData] || "")
                            color: Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedZone = _rq1.modelData
                            root.zoneSelected(_rq1.modelData)
                            _popup.visible = false
                        }
                    }
                }
            }
        }
    }
}
