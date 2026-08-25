import QtQuick
import Mahina

// Horizontal scrollable event timeline with zoom.
//
// Usage:
//   DataTimeline {
//       timelineEvents: [
//           { label: "Launch",   date: "2024-01-15", color: Theme.primary,     description: "v1.0 released" },
//           { label: "Bug fix",  date: "2024-02-03", color: Theme.warning,     description: "Critical patch" },
//           { label: "v2.0",     date: "2024-04-20", color: Theme.success,     description: "Major update" },
//       ]
//       onEventClicked: (e) => showDetail(e)
//   }
Item {
    id: root

    property var  timelineEvents: []
    property real zoomLevel:      1.0   // 0.5..4.0
    property bool showDates:      true

    signal eventClicked(var evt)

    implicitWidth:  480
    implicitHeight: 120

    readonly property real trackY:     50
    readonly property real eventSpacing: 120 * root.zoomLevel

    Flickable {
        id:           _flick
        anchors.fill: parent
        contentWidth: Math.max(root.width,
                               root.timelineEvents.length > 0
                               ? root.eventSpacing * (root.timelineEvents.length + 0.5)
                               : root.width)
        contentHeight: root.height
        clip: true
        boundsMovement: Flickable.StopAtBounds

        // Track line
        Rectangle {
            x:      root.eventSpacing * 0.5
            y:      root.trackY
            width:  _flick.contentWidth - root.eventSpacing
            height: 2
            color:  Theme.border
        }

        // Events
        Repeater {
            model: root.timelineEvents
            delegate: Item {
                id: _rq1
                required property var  modelData
                required property int  index

                x: root.eventSpacing * 0.5 + index * root.eventSpacing
                y: 0
                width:  root.eventSpacing; height: root.height

                // Dot
                Rectangle {
                    width:  12; height: 12; radius: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    y:      root.trackY - 5
                    color:  _rq1.modelData.color || Theme.primary
                    border.color: Theme.surface; border.width: 2

                    SequentialAnimation on scale {
                        running: true; loops: 1
                        NumberAnimation { to: 1.4; duration: 150 }
                        NumberAnimation { to: 1.0; duration: 150 }
                    }
                }

                // Label card above
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y:      0
                    width:  _evLabel.implicitWidth + 12; height: _evLabel.implicitHeight + 8
                    radius: Theme.radiusSm
                    color:  _rq1.modelData.color
                             ? Qt.rgba(Qt.color(_rq1.modelData.color).r, Qt.color(_rq1.modelData.color).g,
                                       Qt.color(_rq1.modelData.color).b, 0.12)
                             : Theme.surfaceVariant
                    border.color: _rq1.modelData.color || Theme.border; border.width: 1

                    Text {
                        id:             _evLabel
                        anchors.centerIn: parent
                        text:           _rq1.modelData.label || ""
                        color:          _rq1.modelData.color || Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Font.Medium
                        elide:          Text.ElideRight
                        width:          Math.min(implicitWidth, root.eventSpacing - 8)
                    }
                }

                // Connector line card → dot
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y:      20; height: root.trackY - 20 - 4
                    width:  1; color: _rq1.modelData.color || Theme.border; opacity: 0.5
                }

                // Date below track
                Text {
                    visible:        root.showDates && (_rq1.modelData.date || "") !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    y:      root.trackY + 14
                    text:   _rq1.modelData.date || ""
                    color:  Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }

                // Description below date
                Text {
                    visible:        (_rq1.modelData.description || "") !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    y:      root.trackY + 30
                    text:   _rq1.modelData.description || ""
                    color:  Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    elide:  Text.ElideRight
                    width:  root.eventSpacing - 8
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.eventClicked(_rq1.modelData)
                }
            }
        }
    }

    // Zoom controls
    Row {
        anchors { right: parent.right; top: parent.top; margins: 4 }
        spacing: 4

        Repeater {
            model: [{ label: "−", delta: -0.25 }, { label: "+", delta: 0.25 }]
            delegate: Rectangle {
                id: _rq2
                required property var modelData
                width: 22; height: 22; radius: 4
                color: _zh.hovered ? Theme.panel : Theme.surfaceVariant
                border.color: Theme.border; border.width: 1
                HoverHandler { id: _zh }
                Text { anchors.centerIn: parent; text: _rq2.modelData.label; color: Theme.textSecondary; font.pixelSize: 13 }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomLevel = Math.max(0.5, Math.min(4.0, root.zoomLevel + _rq2.modelData.delta))
                }
            }
        }
    }
}
