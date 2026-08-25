import QtQuick
import Mahina

// Collapsible developer overlay. Shows runtime info and a scrollable log.
//
// Usage:
//   DebugPanel {
//       anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }
//       open: true
//   }
//   // Push log entries at runtime:
//   DebugPanel { id: dbg }
//   dbg.log("Loaded 42 items")
//   dbg.log("ERR: connection refused")
Item {
    id: root

    property bool   open:        false
    property int    maxLogLines: 80
    property string appVersion:  "—"

    property var logLines: []

    function log(msg) {
        var ts    = new Date().toTimeString().slice(0, 8)
        var lines = root.logLines.slice()
        lines.push(ts + "  " + msg)
        if (lines.length > root.maxLogLines) lines = lines.slice(lines.length - root.maxLogLines)
        root.logLines = lines
        Qt.callLater(function() { _logView.positionViewAtEnd() })
    }

    implicitWidth:  root.open ? 320 : 36
    implicitHeight: root.open ? 300 : 36

    Behavior on implicitWidth  { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
    Behavior on implicitHeight { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

    clip: true

    Rectangle {
        anchors.fill: parent
        radius:  Theme.radiusMd
        color:   Qt.rgba(Qt.color(Theme.background).r, Qt.color(Theme.background).g, Qt.color(Theme.background).b, 0.95)
        border.color: Theme.primary
        border.width: 1

        // Collapse / expand button (always visible)
        Rectangle {
            id:     _btn
            width:  36; height: 36; radius: Theme.radiusSm
            color:  _bH.containsMouse ? Theme.panel : "transparent"
            HoverHandler { id: _bH }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.open = !root.open }
            Text { anchors.centerIn: parent; text: "🐛"; font.pixelSize: 16 }
        }

        // Body — visible only when open
        Item {
            visible:  root.open
            anchors { left: parent.left; right: parent.right; top: _btn.bottom; bottom: parent.bottom }

            Column {
                anchors { fill: parent; margins: Theme.sp3 }
                spacing: Theme.sp2

                Rectangle { width: parent.width; height: 1; color: Theme.border }

                // Runtime info grid
                Grid {
                    columns: 2
                    width:   parent.width
                    columnSpacing: Theme.sp2
                    rowSpacing:    3

                    Repeater {
                        model: [
                            { k: "Qt",      v: Qt.version },
                            { k: "Arch",    v: Qt.platform.os },
                            { k: "Screen",  v: Screen.width + "×" + Screen.height },
                            { k: "DPR",     v: Screen.devicePixelRatio.toFixed(1) },
                            { k: "LogLines",v: root.logLines.length.toString() },
                            { k: "Version", v: root.appVersion },
                        ]
                        delegate: Text {
                            required property var modelData
                            text:           modelData.k + ": " + modelData.v
                            color:          Theme.textSecondary
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textXs
                            width:          parent.width / 2
                            elide:          Text.ElideRight
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Theme.border }

                // Log list
                ListView {
                    id:     _logView
                    width:  parent.width
                    height: parent.parent.height - 80
                    clip:   true
                    model:  root.logLines
                    delegate: Text {
                        required property string modelData
                        text:           modelData
                        color:          modelData.indexOf("ERR") >= 0  ? Theme.error
                                      : modelData.indexOf("WARN") >= 0 ? Theme.warning
                                      : Theme.textDisabled
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textXs
                        width:          _logView.width
                        elide:          Text.ElideRight
                    }
                }
            }
        }
    }
}
