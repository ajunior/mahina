pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Three-column icon + title + description feature showcase.
//
// Usage:
//   FeatureGrid {
//       columns: 3
//       features: [
//           { icon: Icons.lightning, title: "Fast",     desc: "AOT-compiled QML runs at native speed."      },
//           { icon: Icons.palette,   title: "Themeable", desc: "Dark mode with one property toggle."        },
//           { icon: Icons.sparkle,   title: "100+ Components", desc: "Everything you need, out of the box." },
//       ]
//   }
Item {
    id: root

    property var  features: []
    property int  columns:  3
    property real gap:      Theme.sp4

    implicitWidth:  500
    implicitHeight: Math.ceil(features.length / columns) * (_cellH + gap) - gap

    readonly property real _cellW: (width + gap) / columns - gap
    readonly property real _cellH: 120

    Repeater {
        model: root.features
        delegate: Rectangle {
            id: _rq1
            required property var  modelData
            required property int  index

            x: (index % root.columns) * (root._cellW + root.gap)
            y: Math.floor(index / root.columns) * (root._cellH + root.gap)
            width:  root._cellW
            height: root._cellH
            radius: Theme.radiusLg
            color:  Theme.surface
            border.color: Theme.border; border.width: 1

            Column {
                anchors { fill: parent; margins: Theme.sp4 }
                spacing: Theme.sp2

                Rectangle {
                    width: 36; height: 36; radius: Theme.radiusMd
                    color: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.12)

                    Text {
                        anchors.centerIn: parent
                        text:  _rq1.modelData.icon ?? "●"
                        color: Theme.primary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textLg
                    }
                }

                Text {
                    text:           _rq1.modelData.title ?? ""
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightSemibold
                }

                Text {
                    text:           _rq1.modelData.desc ?? ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    wrapMode:       Text.Wrap
                    width:          parent.width
                    lineHeight:     Theme.lineHeightNormal
                    lineHeightMode: Text.ProportionalHeight
                }
            }
        }
    }
}
