pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Service status dashboard card — shows per-service status with a computed overall status.
//
// Usage:
//   SystemStatus {
//       services: [
//           { name: "API",     status: "operational" },
//           { name: "Database",status: "degraded"    },
//           { name: "CDN",     status: "operational" },
//           { name: "Auth",    status: "outage"      },
//       ]
//   }
Rectangle {
    id: root

    property var services: []

    implicitWidth:  360
    implicitHeight: _col.implicitHeight + Theme.sp4 * 2

    radius: Theme.radiusMd
    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    function _statusColor(s: var): var {
        switch (s) {
            case "operational":  return Theme.success
            case "degraded":     return Theme.warning
            case "outage":       return Theme.error
            case "maintenance":  return Theme.primary
            default:             return Theme.textDisabled
        }
    }

    function _statusLabel(s: var): var {
        switch (s) {
            case "operational":  return "Operational"
            case "degraded":     return "Degraded"
            case "outage":       return "Outage"
            case "maintenance":  return "Maintenance"
            default:             return "Unknown"
        }
    }

    readonly property string overallStatus: {
        var svcs = root.services
        var hasOutage = false, hasDegraded = false, hasMaint = false
        for (var i = 0; i < svcs.length; i++) {
            if (svcs[i].status === "outage")      hasOutage    = true
            if (svcs[i].status === "degraded")    hasDegraded  = true
            if (svcs[i].status === "maintenance") hasMaint     = true
        }
        if (hasOutage)   return "outage"
        if (hasDegraded) return "degraded"
        if (hasMaint)    return "maintenance"
        return "operational"
    }

    Column {
        id:    _col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp4 }
        spacing: Theme.sp3

        // Overall status header
        Row {
            spacing: Theme.sp3
            width: parent.width

            Rectangle {
                width:  10; height: 10; radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color:  root._statusColor(root.overallStatus)

                // Pulse when outage
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.overallStatus === "outage"
                    NumberAnimation { to: 0.3; duration: 600 }
                    NumberAnimation { to: 1.0; duration: 600 }
                }
            }

            Column {
                spacing: 1
                Text {
                    text:           "System Status"
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    font.weight:    Font.DemiBold
                }
                Text {
                    text:           root._statusLabel(root.overallStatus)
                    color:          root._statusColor(root.overallStatus)
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        // Service rows
        Repeater {
            model: root.services
            delegate: Row {
                id: _rq1
                required property var modelData
                width: parent.width
                height: 32

                Rectangle {
                    width:  8; height: 8; radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: root._statusColor(_rq1.modelData.status || "")
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           _rq1.modelData.name || ""
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    leftPadding:    10
                    width:          parent.width * 0.55
                }

                Item { width: 1; height: 1 }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           root._statusLabel(_rq1.modelData.status || "")
                    color:          root._statusColor(_rq1.modelData.status || "")
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Font.Medium
                }
            }
        }
    }
}
