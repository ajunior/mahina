import QtQuick
import Mahina

// Range slider with multiple thumbs for selecting N values along a range.
//
// Usage:
//   MultiRangeSlider { values: [20, 50, 80]; min: 0; max: 100 }
//   MultiRangeSlider { values: [0.25, 0.75]; min: 0; max: 1; decimals: 2 }
Item {
    id: root

    property var  values:   [0, 100]
    property real min:      0
    property real max:      100
    property real step:     1
    property int  decimals: 0

    signal valuesEdited(var vals)

    implicitWidth:  280
    implicitHeight: 40

    readonly property real _range: max - min || 1

    function _snap(v) {
        var snapped = step > 0 ? Math.round(v / step) * step : v
        return Math.max(min, Math.min(max, snapped))
    }

    function _xToVal(px) {
        return min + (px / (_track.width - 18)) * _range
    }

    Rectangle {
        id:     _track
        anchors.verticalCenter: parent.verticalCenter
        width:  parent.width; height: 4; radius: 2
        color:  Theme.border

        // Colored fill between first and last thumb
        Rectangle {
            x:     ((root.values[0] ?? 0) - root.min) / root._range * (_track.width - 18) + 9
            width: ((root.values[root.values.length - 1] ?? 0) - (root.values[0] ?? 0)) / root._range * (_track.width - 18)
            height: parent.height; radius: 2
            color:  Theme.primary
        }
    }

    Repeater {
        model: root.values
        delegate: Item {
            id: _rq1
            required property real modelData
            required property int  index

            property real _val: modelData

            width:  18; height: 18
            x: (_val - root.min) / root._range * (_track.width - 18)
            y: (root.height - 18) / 2

            Rectangle {
                anchors.fill: parent
                radius: 9
                color:  Theme.surface
                border.color: Theme.primary; border.width: 2

                Rectangle {
                    anchors.centerIn: parent
                    width: 6; height: 6; radius: 3
                    color: Theme.primary
                }
            }

            // Value label on hover
            Text {
                id:     _lbl
                anchors { bottom: parent.top; bottomMargin: 4; horizontalCenter: parent.horizontalCenter }
                visible: _thumbMA.containsMouse || _thumbMA.drag.active
                text:   _val.toFixed(root.decimals)
                color:  Theme.textPrimary
                font.family: Theme.fontFamilyMono
                font.pixelSize: Theme.textXs
                font.weight: Theme.weightSemibold
            }

            MouseArea {
                id:          _thumbMA
                anchors.fill: parent
                drag.target: parent
                drag.axis:   Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: _track.width - 18
                hoverEnabled: true

                onPositionChanged: {
                    if (drag.active) {
                        var newVal = root._snap(root._xToVal(parent.x))
                        var newVals = root.values.slice()
                        newVals[_rq1.index] = newVal
                        // Sort to keep thumbs ordered
                        newVals.sort(function(a, b) { return a - b })
                        root.values = newVals
                        root.valuesEdited(root.values)
                    }
                }
            }
        }
    }
}
