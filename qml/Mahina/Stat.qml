import QtQuick
import QtQuick.Layouts
import Mahina

// Metric card — big number, label, and optional trend indicator.
//
// Usage:
//   Stat { label: "Total revenue"; value: "$48,295"; trend: 12.5 }
//   Stat { label: "Active users"; value: "3,241"; trend: -4.2; trendLabel: "vs last week" }
//   Stat { label: "Uptime"; value: "99.9 %"; icon: Icons.chartLine }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string label:      ""
    property string value:      "—"
    property real   trend:      0        // % change; positive=up, negative=down, 0=none
    property string trendLabel: ""       // e.g. "vs last month"
    property string icon:       ""       // optional leading icon
    property int    iconSize:   20

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  180
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        // Icon + label row
        RowLayout {
            spacing: Theme.sp2

            Icon {
                visible: root.icon !== ""
                name:    root.icon
                size:    root.iconSize
                color:   Theme.textSecondary
            }

            Text {
                text:           root.label
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightMedium
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Big value
        Text {
            text:           root.value
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.text3xl
            font.weight:    Theme.weightSemibold
            Layout.fillWidth: true
        }

        // Trend badge
        RowLayout {
            visible:  root.trend !== 0
            spacing:  Theme.sp1

            Rectangle {
                implicitWidth:  _trendRow.implicitWidth + Theme.sp2 * 2
                implicitHeight: _trendRow.implicitHeight + Theme.sp1
                radius:         Theme.radiusSm
                color:          root.trend > 0 ? Theme.successSubtle : Theme.errorSubtle

                RowLayout {
                    id:             _trendRow
                    anchors.centerIn: parent
                    spacing:        2

                    Icon {
                        name:  root.trend > 0 ? Icons.arrowUp : Icons.arrowDown
                        size:  12
                        color: root.trend > 0 ? Theme.success : Theme.error
                    }

                    Text {
                        text:           Math.abs(root.trend).toFixed(1) + "%"
                        color:          root.trend > 0 ? Theme.success : Theme.error
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightSemibold
                    }
                }
            }

            Text {
                visible:        root.trendLabel !== ""
                text:           root.trendLabel
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }
}
