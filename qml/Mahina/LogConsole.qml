pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Scrolling log output with level badges and search filter.
//
// Usage:
//   LogConsole {
//       id: _log
//       // call _log.append("info", "Server started on :8080")
//       // call _log.append("error", "Connection refused")
//   }
Item {
    id: root

    property var    logEntries:  []    // [{level, message, timestamp}]
    property string filterLevel: "all" // "all"|"info"|"warn"|"error"|"debug"
    property string searchText:  ""
    property int    maxEntries:  500
    property bool   autoScroll:  true

    signal entryClicked(var entry)

    function append(level, message) {
        var ts   = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
        var copy = root.logEntries.slice()
        copy.push({ level: level, message: message, timestamp: ts })
        if (copy.length > root.maxEntries) copy.shift()
        root.logEntries = copy
        if (root.autoScroll) _lcView.positionViewAtEnd()
    }

    function clear() { root.logEntries = [] }

    function _levelColor(l) {
        switch (l) {
            case "error": return Theme.error
            case "warn":  return Theme.warning
            case "info":  return Theme.info
            case "debug": return Theme.textDisabled
            default:      return Theme.textSecondary
        }
    }

    function _matches(e) {
        if (root.filterLevel !== "all" && e.level !== root.filterLevel) return false
        if (root.searchText !== "" && e.message.toLowerCase().indexOf(root.searchText.toLowerCase()) < 0) return false
        return true
    }

    readonly property var filteredEntries: {
        var out = []
        for (var i = 0; i < root.logEntries.length; i++)
            if (root._matches(root.logEntries[i])) out.push(root.logEntries[i])
        return out
    }

    implicitWidth:  500
    implicitHeight: 300

    Rectangle {
        anchors.fill: parent
        color:  "#0d1117"
        radius: Theme.radiusMd
        border.color: Theme.border; border.width: 1
        clip: true

        // Toolbar
        Rectangle {
            id:    _lcBar
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 36
            color:  "#161b22"

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1; color: Theme.border
            }

            Row {
                anchors { left: parent.left; right: parent.right
                          leftMargin: Theme.sp3; rightMargin: Theme.sp3
                          verticalCenter: parent.verticalCenter }
                spacing: Theme.sp2

                // Level filter buttons
                Repeater {
                    model: ["all", "debug", "info", "warn", "error"]
                    delegate: Rectangle {
                        id: _rq1
                        required property string modelData
                        required property int    index
                        height: 22; width: _lvTxt.implicitWidth + 12; radius: Theme.radiusSm
                        color: root.filterLevel === modelData
                               ? Qt.rgba(Qt.color(root._levelColor(modelData)).r,
                                         Qt.color(root._levelColor(modelData)).g,
                                         Qt.color(root._levelColor(modelData)).b, 0.25)
                               : (_lvH.hovered ? "#21262d" : "transparent")
                        HoverHandler { id: _lvH }
                        Text {
                            id:    _lvTxt
                            anchors.centerIn: parent
                            text:           _rq1.modelData.toUpperCase()
                            color:          root._levelColor(_rq1.modelData)
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            font.weight:    Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.filterLevel = _rq1.modelData
                        }
                    }
                }

                // Search box
                Item {
                    width: 140; height: 22

                    Text {
                        visible: _srchInput.text === ""
                        anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                        text: "Filter…"; color: "#484f58"
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                    }

                    TextInput {
                        id:    _srchInput
                        anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                        color:          "#c9d1d9"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        onTextChanged:  root.searchText = text
                    }

                    Rectangle {
                        anchors.fill: parent; radius: Theme.radiusSm
                        color: "transparent"; border.color: "#30363d"; border.width: 1
                    }
                }

                Item { width: 1; height: 1 }   // spacer

                // Clear button
                Rectangle {
                    height: 22; width: _clrLbl.implicitWidth + 12; radius: Theme.radiusSm
                    color: _clcH.hovered ? "#21262d" : "transparent"
                    HoverHandler { id: _clcH }
                    Text {
                        id:    _clrLbl
                        anchors.centerIn: parent
                        text:  "Clear"; color: "#8b949e"
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.clear() }
                }
            }
        }

        // Log list
        ListView {
            id:    _lcView
            anchors { left: parent.left; right: parent.right; top: _lcBar.bottom; bottom: parent.bottom }
            model: root.filteredEntries
            clip:  true

            delegate: Item {
                id: _rq2
                required property var  modelData
                required property int  index
                width:  _lcView.width; height: 24

                Rectangle {
                    anchors.fill: parent
                    color: _logH.hovered ? "#161b22" : "transparent"
                    HoverHandler { id: _logH }
                }

                Row {
                    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                    spacing: 6

                    Text {
                        text:           _rq2.modelData.timestamp
                        color:          "#484f58"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: _lvBadge.implicitWidth + 8; height: 14; radius: 3
                        color: Qt.rgba(Qt.color(root._levelColor(_rq2.modelData.level)).r,
                                       Qt.color(root._levelColor(_rq2.modelData.level)).g,
                                       Qt.color(root._levelColor(_rq2.modelData.level)).b, 0.2)
                        Text {
                            id:    _lvBadge
                            anchors.centerIn: parent
                            text:           _rq2.modelData.level.toUpperCase()
                            color:          root._levelColor(_rq2.modelData.level)
                            font.family:    Theme.fontFamily
                            font.pixelSize: 8
                            font.weight:    Font.Bold
                        }
                    }

                    Text {
                        text:           _rq2.modelData.message
                        color:          "#c9d1d9"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.entryClicked(_rq2.modelData)
                }
            }
        }
    }
}
