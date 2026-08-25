import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Virtual-scrolling log panel with level badges and text filter.
//
// Usage:
//   LogViewer {
//       log: [
//           { level: "info",  message: "Server started on :8080",  timestamp: "12:00:01" },
//           { level: "warn",  message: "Slow query detected: 1.2s", timestamp: "12:00:03" },
//           { level: "error", message: "Connection refused",        timestamp: "12:00:05", tag: "DB" },
//           { level: "debug", message: "Cache hit ratio: 0.87",     tag: "cache" },
//       ]
//       showFilter: true
//   }
//
// Each entry: { level: "debug"|"info"|"warn"|"error", message, timestamp?, tag? }
Item {
    id: root

    property var    log:        []
    property bool   showFilter: true
    property bool   autoScroll: true
    property bool   showTimestamps: true
    property bool   showTags:  true
    property bool   wrapLines: false
    property var    enabledLevels: ["debug", "info", "warn", "error"]

    implicitWidth:  500
    implicitHeight: 360

    // Filtered view
    readonly property var _filtered: {
        var f = root._filterText.toLowerCase()
        return root.log.filter(function(e) {
            if (root.enabledLevels.indexOf(e.level ?? "info") === -1) return false
            if (f === "") return true
            return (e.message ?? "").toLowerCase().indexOf(f) !== -1 ||
                   (e.tag ?? "").toLowerCase().indexOf(f) !== -1
        })
    }

    property string _filterText: ""

    function _levelColor(level) {
        switch (level) {
            case "debug": return "#6c7086"
            case "info":  return "#89b4fa"
            case "warn":  return "#f9e2af"
            case "error": return "#f38ba8"
            default:      return Theme.textSecondary
        }
    }
    function _levelBg(level) {
        switch (level) {
            case "debug": return "#1e1e2e"
            case "info":  return "#1e2030"
            case "warn":  return "#2a1f0a"
            case "error": return "#2a0a0a"
            default:      return "#1e1e2e"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing:      0

        // ── Toolbar ───────────────────────────────────────────────────────────
        Rectangle {
            visible:          root.showFilter
            Layout.fillWidth: true
            height:           40
            color:            Theme.panel
            border.color:     Theme.border
            border.width:     1
            radius:           Theme.radiusMd

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                spacing: Theme.sp2

                Icon { name: Icons.funnel; size: 13; color: Theme.textSecondary }

                TextInput {
                    id:             _filterInput
                    Layout.fillWidth: true
                    text:           root._filterText
                    onTextChanged:  root._filterText = text
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    clip:           true

                    Text {
                        visible:        _filterInput.text === ""
                        text:           "Filter logs…"
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Level toggles
                Repeater {
                    model: ["debug", "info", "warn", "error"]
                    delegate: Rectangle {
                        id: _rq2
                        required property string modelData
                        readonly property bool _on: root.enabledLevels.indexOf(modelData) !== -1
                        height: 22; width: _lt.implicitWidth + 10
                        radius: Theme.radiusFull
                        color:  _on ? Qt.rgba(Qt.color(root._levelColor(modelData)).r,
                                              Qt.color(root._levelColor(modelData)).g,
                                              Qt.color(root._levelColor(modelData)).b, 0.18)
                                    : Theme.surfaceVariant
                        border.color: _on ? root._levelColor(modelData) : Theme.border
                        border.width: 1
                        Text {
                            id:              _lt
                            anchors.centerIn: parent
                            text:            _rq2.modelData
                            color:           _on ? root._levelColor(_rq2.modelData) : Theme.textDisabled
                            font.family:     Theme.fontFamily
                            font.pixelSize:  Theme.textXs
                            font.weight:     Theme.weightMedium
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var lvls = root.enabledLevels.slice()
                                var idx  = lvls.indexOf(_rq2.modelData)
                                if (idx === -1) lvls.push(_rq2.modelData)
                                else            lvls.splice(idx, 1)
                                root.enabledLevels = lvls
                            }
                        }
                    }
                }

                // Clear
                Item {
                    width: 20; height: 20
                    Icon { anchors.centerIn: parent; name: Icons.x; size: 12; color: Theme.textSecondary }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root._filterText = ""
                    }
                    visible: root._filterText !== ""
                }
            }
        }

        // ── Log list ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            color:             "#1e1e2e"
            radius:            Theme.radiusMd
            clip:              true
            border.color:      Theme.border
            border.width:      1

            ListView {
                id:           _list
                anchors.fill: parent
                anchors.margins: 1
                model:        root._filtered
                spacing:      0
                clip:         true

                QQC.ScrollBar.vertical: QQC.ScrollBar {
                    contentItem: Rectangle { radius: 3; color: "#585b70" }
                    background:  Rectangle { color: "transparent" }
                }
                QQC.ScrollBar.horizontal: QQC.ScrollBar {
                    policy:      root.wrapLines ? QQC.ScrollBar.AlwaysOff : QQC.ScrollBar.AsNeeded
                    contentItem: Rectangle { radius: 3; color: "#585b70" }
                    background:  Rectangle { color: "transparent" }
                }

                onCountChanged: {
                    if (root.autoScroll) Qt.callLater(() => positionViewAtEnd())
                }

                delegate: Item {
                    id: _rq1
                    required property var modelData
                    required property int index

                    width:  root.wrapLines ? _list.width : Math.max(_list.width, _row.implicitWidth + Theme.sp4 * 2)
                    height: _row.implicitHeight + 6

                    Rectangle {
                        anchors.fill: parent
                        color:        _rq1.index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.02)
                    }

                    Row {
                        id:      _row
                        x:       Theme.sp3
                        y:       3
                        spacing: Theme.sp2

                        Text {
                            visible:        root.showTimestamps && (_rq1.modelData.timestamp ?? "") !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            text:           _rq1.modelData.timestamp ?? ""
                            color:          "#6c7086"
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textXs
                        }

                        Rectangle {
                            height: 18; width: _lvlTxt.implicitWidth + 10; radius: 3
                            color:  Qt.rgba(Qt.color(root._levelColor(_rq1.modelData.level ?? "info")).r,
                                           Qt.color(root._levelColor(_rq1.modelData.level ?? "info")).g,
                                           Qt.color(root._levelColor(_rq1.modelData.level ?? "info")).b, 0.2)
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                id:              _lvlTxt
                                anchors.centerIn: parent
                                text:            (_rq1.modelData.level ?? "info").toUpperCase()
                                color:           root._levelColor(_rq1.modelData.level ?? "info")
                                font.family:     Theme.fontFamilyMono
                                font.pixelSize:  9
                                font.weight:     Theme.weightBold
                            }
                        }

                        Rectangle {
                            visible:  root.showTags && (_rq1.modelData.tag ?? "") !== ""
                            height:   18; width: _tagTxt.implicitWidth + 10; radius: 3
                            color:    "#313244"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                id:              _tagTxt
                                anchors.centerIn: parent
                                text:            _rq1.modelData.tag ?? ""
                                color:           "#cdd6f4"
                                font.family:     Theme.fontFamilyMono
                                font.pixelSize:  Theme.textXs
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           _rq1.modelData.message ?? ""
                            color:          "#cdd6f4"
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textSm
                            wrapMode:       root.wrapLines ? Text.Wrap : Text.NoWrap
                            width:          root.wrapLines ? (_list.width - x - Theme.sp3 * 2) : implicitWidth
                        }
                    }
                }
            }
        }
    }
}
