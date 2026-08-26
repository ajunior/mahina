pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Key Performance Indicator card with value, label, trend, and sparkline.
//
// Usage:
//   KPICard {
//       label:       "Monthly Revenue"
//       value:       "$48,290"
//       trend:       "+12.4%"
//       trendUp:     true
//       sparkValues: [30, 45, 28, 60, 55, 72, 68, 80]
//   }
Item {
    id: root

    property string label:       ""
    property string value:       "—"
    property string trend:       ""
    property bool   trendUp:     true
    property var    sparkValues: []
    property string subtitle:    ""

    implicitWidth:  220
    implicitHeight: 120

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusLg
        color:         Theme.surface
        border.color:  Theme.border
        border.width:  1

        Column {
            anchors { fill: parent; margins: Theme.sp4 }
            spacing: Theme.sp2

            // Label row
            Row {
                width: parent.width
                spacing: Theme.sp2

                Text {
                    text:           root.label
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightMedium
                    elide:          Text.ElideRight
                    width:          parent.width - (root.trend !== "" ? _trendBadge.width + Theme.sp2 : 0)
                }

                Rectangle {
                    id:      _trendBadge
                    visible: root.trend !== ""
                    width:   _trendText.implicitWidth + Theme.sp2 * 2
                    height:  16
                    radius:  8
                    color:   root.trendUp ? Qt.rgba(0.15, 0.65, 0.27, 0.15) : Qt.rgba(0.97, 0.32, 0.29, 0.15)

                    Text {
                        id:             _trendText
                        anchors.centerIn: parent
                        text:           root.trend
                        color:          root.trendUp ? Theme.success : Theme.error
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightSemibold
                    }
                }
            }

            // Value
            Text {
                text:           root.value
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textXl
                font.weight:    Theme.weightBold
            }

            // Subtitle / sparkline row
            Row {
                width: parent.width
                spacing: Theme.sp3

                Text {
                    visible:        root.subtitle !== ""
                    text:           root.subtitle
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    anchors.verticalCenter: parent.verticalCenter
                }

                Sparkline {
                    visible:    root.sparkValues.length > 0
                    values:     root.sparkValues
                    width:      80; height: 24
                    color:      root.trendUp ? Theme.success : Theme.error
                    fillOpacity: 0.15
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
