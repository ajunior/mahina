pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Stacked dismissable alerts with type-based styling.
//
// Usage:
//   AlertStack {
//       stackAlerts: [
//           { type: "error",   title: "Upload failed", message: "File too large.", dismissible: true  },
//           { type: "warning", title: "Almost full",   message: "90% storage used.", dismissible: true },
//           { type: "success", title: "Saved",         message: "Changes applied.",  dismissible: true },
//           { type: "info",    title: "Update ready",  message: "Restart to apply.", dismissible: false},
//       ]
//       onDismissed: (i) => alerts.splice(i, 1)
//   }
Item {
    id: root

    property var  stackAlerts: []
    property int  maxVisible:  5

    signal dismissed(int idx)

    implicitWidth:  420
    implicitHeight: _col.implicitHeight

    function _typeColor(t: var): var {
        switch (t) {
            case "error":   return Theme.error
            case "warning": return Theme.warning
            case "success": return Theme.success
            case "info":    return Theme.primary
            default:        return Theme.textSecondary
        }
    }
    function _typeIcon(t: var): var {
        switch (t) {
            case "error":   return "✕"
            case "warning": return "⚠"
            case "success": return "✓"
            case "info":    return "ℹ"
            default:        return "•"
        }
    }

    Column {
        id:     _col
        width:  parent.width
        spacing: 8

        Repeater {
            model: root.stackAlerts.length > root.maxVisible
                   ? root.stackAlerts.slice(0, root.maxVisible)
                   : root.stackAlerts

            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index

                width:  root.width
                height: _alertRow.implicitHeight + Theme.sp3 * 2
                radius: 0

                readonly property color alertColor: Qt.color(root._typeColor(modelData.type || "info"))
                color:   Qt.rgba(alertColor.r, alertColor.g, alertColor.b, 0.08)
                border.color: Qt.rgba(alertColor.r, alertColor.g, alertColor.b, 0.35)
                border.width: 1

                // Left accent stripe
                Rectangle {
                    width:  3; height: parent.height - 2; radius: 0
                    anchors { left: parent.left; leftMargin: 1; verticalCenter: parent.verticalCenter }
                    color: root._typeColor(_rq1.modelData.type || "info")
                }

                Row {
                    id:    _alertRow
                    anchors {
                        left: parent.left; right: parent.right
                        top:  parent.top; margins: Theme.sp3
                        leftMargin: Theme.sp3 + 8
                    }
                    spacing: Theme.sp2

                    // Type icon
                    Rectangle {
                        width: 20; height: 20; radius: 10
                        color: Qt.rgba(Qt.color(root._typeColor(_rq1.modelData.type || "info")).r,
                                       Qt.color(root._typeColor(_rq1.modelData.type || "info")).g,
                                       Qt.color(root._typeColor(_rq1.modelData.type || "info")).b, 0.2)
                        Text {
                            anchors.centerIn: parent
                            text:           root._typeIcon(_rq1.modelData.type || "info")
                            color:          root._typeColor(_rq1.modelData.type || "info")
                            font.pixelSize: 10
                            font.weight:    Font.Bold
                        }
                    }

                    // Text content
                    Column {
                        width: parent.width - 20 - Theme.sp2 - (_rq1.modelData.dismissible ? 24 : 0) - Theme.sp2
                        spacing: 2

                        Text {
                            text:           _rq1.modelData.title || ""
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Font.Medium
                            visible:        text !== ""
                        }
                        Text {
                            text:           _rq1.modelData.message || ""
                            color:          Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            wrapMode:       Text.Wrap
                            width:          parent.width
                            visible:        text !== ""
                        }
                    }

                    // Dismiss button
                    Rectangle {
                        visible: _rq1.modelData.dismissible || false
                        width:   20; height: 20; radius: 4
                        color:   _dH.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _dH }
                        Text {
                            anchors.centerIn: parent
                            text:   "✕"; color: Theme.textSecondary; font.pixelSize: 10
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.dismissed(_rq1.index)
                        }
                    }
                }
            }
        }

        // "N more" pill if truncated
        Rectangle {
            visible: root.stackAlerts.length > root.maxVisible
            width:   root.width; height: 28; radius: Theme.radiusMd
            color:   Theme.surfaceVariant
            border.color: Theme.border; border.width: 1

            Text {
                anchors.centerIn: parent
                text:           "+" + (root.stackAlerts.length - root.maxVisible) + " more alerts"
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }
}
