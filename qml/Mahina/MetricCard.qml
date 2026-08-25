import QtQuick
import Mahina

// Stat tile with trend arrow, comparison delta, and embedded mini sparkline.
//
// Usage:
//   MetricCard {
//       cardLabel:   "Monthly Revenue"
//       metricValue: "$84.2k"
//       delta:       12.4     // positive = up, negative = down
//       deltaLabel:  "vs last month"
//       sparkData:   [42, 55, 48, 72, 65, 84]
//       accentColor: Theme.success
//   }
Rectangle {
    id: root

    property string cardLabel:   ""
    property string metricValue: "—"
    property real   delta:       0
    property string deltaLabel:  ""
    property var    sparkData:   []
    property color  accentColor: Theme.primary

    implicitWidth:  220
    implicitHeight: 130

    radius: Theme.radiusMd
    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    // Top accent bar
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 3; radius: root.radius
        color:  root.accentColor
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: parent.radius; color: parent.color
        }
    }

    Column {
        anchors { fill: parent; margins: Theme.sp4; topMargin: Theme.sp4 + 3 }
        spacing: Theme.sp2

        Text {
            text:           root.cardLabel
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Font.Medium
            elide:          Text.ElideRight
            width:          parent.width
        }

        Text {
            text:           root.metricValue
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.text2xl
            font.weight:    Font.Bold
        }

        Row {
            spacing: 6
            visible: root.delta !== 0 || root.deltaLabel !== ""

            // Arrow + delta %
            Rectangle {
                width:  _deltaRow.implicitWidth + 8; height: 18; radius: 9
                color: root.delta >= 0
                       ? Qt.rgba(Qt.color(Theme.success).r, Qt.color(Theme.success).g, Qt.color(Theme.success).b, 0.12)
                       : Qt.rgba(Qt.color(Theme.error).r,   Qt.color(Theme.error).g,   Qt.color(Theme.error).b,   0.12)

                Row {
                    id:      _deltaRow
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        text:           root.delta >= 0 ? "↑" : "↓"
                        color:          root.delta >= 0 ? Theme.success : Theme.error
                        font.pixelSize: 10; font.weight: Font.Bold
                    }
                    Text {
                        text:           Math.abs(root.delta).toFixed(1) + "%"
                        color:          root.delta >= 0 ? Theme.success : Theme.error
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Font.Medium
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.deltaLabel
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }

    // Sparkline (bottom right)
    Canvas {
        id:     _spark
        width:  80; height: 32
        anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }

        Connections {
            target: root
            function onSparkDataChanged() { _spark.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var pts = root.sparkData
            if (pts.length < 2) return
            var mn = pts[0], mx = pts[0]
            for (var i = 1; i < pts.length; i++) { if (pts[i] < mn) mn = pts[i]; if (pts[i] > mx) mx = pts[i] }
            if (mx === mn) mx = mn + 1
            var pw = width / (pts.length - 1)
            var sc = Qt.color(root.accentColor)
            ctx.strokeStyle = sc.toString(); ctx.lineWidth = 1.5; ctx.lineJoin = "round"
            ctx.beginPath()
            for (var j = 0; j < pts.length; j++) {
                var sx = j * pw, sy = height - (pts[j] - mn) / (mx - mn) * height * 0.9 - 2
                if (j === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy)
            }
            ctx.stroke()
        }
    }
}
