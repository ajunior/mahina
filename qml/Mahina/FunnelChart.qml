import QtQuick
import Mahina

// Conversion funnel visualization with labeled stages.
//
// Usage:
//   FunnelChart {
//       stages: [
//           { label: "Visitors",   value: 10000 },
//           { label: "Sign-ups",   value: 4200  },
//           { label: "Activated",  value: 2100  },
//           { label: "Paying",     value:  840  },
//           { label: "Retained",   value:  310  },
//       ]
//   }
Item {
    id: root

    property var   stages:     []
    property color baseColor:  Theme.primary
    property real  barHeight:  40
    property real  barGap:     6
    property bool  showValues: true
    property bool  showPct:    true

    readonly property real _maxVal: {
        var m = 1
        for (var i = 0; i < stages.length; i++) if ((stages[i].value ?? 0) > m) m = stages[i].value
        return m
    }

    implicitWidth:  400
    implicitHeight: stages.length * (barHeight + barGap) - barGap

    Repeater {
        model: root.stages
        delegate: Item {
            id: _rq1
            required property var  modelData
            required property int  index

            readonly property real _frac:   (modelData.value ?? 0) / root._maxVal
            readonly property real _pct:    index === 0 ? 100 :
                                            Math.round((modelData.value ?? 0) / (root.stages[0].value ?? 1) * 100)
            readonly property color _col: Qt.rgba(
                Qt.color(root.baseColor).r * (0.6 + _frac * 0.4),
                Qt.color(root.baseColor).g * (0.6 + _frac * 0.4),
                Qt.color(root.baseColor).b * (0.6 + _frac * 0.4),
                1)

            y:      index * (root.barHeight + root.barGap)
            width:  parent.width
            height: root.barHeight

            // Bar
            Rectangle {
                width:  parent.width * _frac
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.radiusSm
                color:  _col

                Behavior on width { NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic } }
            }

            // Labels
            Row {
                anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                spacing: Theme.sp2

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           _rq1.modelData.label ?? ""
                    color:          "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightMedium
                }

                Text {
                    visible:        root.showValues
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "(" + (_rq1.modelData.value ?? 0).toLocaleString() + ")"
                    color:          Qt.rgba(1, 1, 1, 0.75)
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
            }

            Text {
                visible:        root.showPct
                anchors { right: parent.right; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                text:           _pct + "%"
                color:          "#ffffff"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                font.weight:    Theme.weightSemibold
            }
        }
    }
}
