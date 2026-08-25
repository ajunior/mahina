import QtQuick
import Mahina

// Horizontally scrolling text ticker.
//
// Usage:
//   Marquee { text: "Breaking news: Mahina 1.0 ships!"; width: 300 }
//   Marquee { text: longText; speed: 80; color: Theme.primary; pixelSize: Theme.textBase }
Item {
    id: root

    property string text:      ""
    property real   speed:     60       // pixels per second
    property int    gap:       64       // gap between repetitions in px
    property color  color:     Theme.textPrimary
    property real   pixelSize: Theme.textSm
    property string fontFamily: Theme.fontFamily

    implicitHeight: _t1.implicitHeight
    clip:           true

    // Content width of a single copy (text + gap)
    readonly property real _cw: _t1.implicitWidth + root.gap
    readonly property int  _dur: _cw > 0 && root.speed > 0
                                 ? Math.round(_cw / root.speed * 1000) : 8000

    Text {
        id:             _t1
        text:           root.text
        color:          root.color
        font.family:    root.fontFamily
        font.pixelSize: root.pixelSize

        NumberAnimation on x {
            running:  root.text !== "" && root._cw > 0
            from:     0
            to:       -root._cw
            duration: root._dur
            loops:    Animation.Infinite
        }
    }

    // Second copy that follows seamlessly
    Text {
        x:              _t1.x + root._cw
        text:           root.text
        color:          root.color
        font.family:    root.fontFamily
        font.pixelSize: root.pixelSize
    }
}
