import QtQuick
import Mahina

// Animates smoothly from one numeric value to another.
//
// Usage:
//   AnimatedCounter { value: totalUsers; prefix: ""; suffix: " users"; decimals: 0 }
//   AnimatedCounter { value: percentage; suffix: "%"; decimals: 1; font.pixelSize: 36 }
Item {
    id: root

    property real   value:    0
    property int    duration: 700
    property string prefix:   ""
    property string suffix:   ""
    property int    decimals: 0
    property int    pixelSize: Theme.textXl
    property color  color:     Theme.textPrimary
    property int    fontWeight: Theme.weightBold

    implicitWidth:  _label.implicitWidth
    implicitHeight: _label.implicitHeight

    property real displayedVal: 0

    onValueChanged: {
        _anim.from = root.displayedVal
        _anim.to   = root.value
        _anim.restart()
    }

    NumberAnimation {
        id:           _anim
        target:       root
        property:     "displayedVal"
        from:         root.displayedVal
        to:           root.value
        duration:     root.duration
        easing.type:  Easing.OutExpo
    }

    Text {
        id:             _label
        text:           root.prefix + root.displayedVal.toFixed(root.decimals) + root.suffix
        color:          root.color
        font.family:    Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.weight:    root.fontWeight
    }
}
