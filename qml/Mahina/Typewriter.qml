pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Text that types itself out character by character.
//
// Usage:
//   Typewriter { text: "Hello, Mahina!" }
//   Typewriter {
//       text:   "Building beautiful UIs with Qt."
//       speed:  60
//       loop:   true
//       color:  Theme.primary
//       pixelSize: Theme.textLg
//   }
Item {
    id: root

    property string text:       ""
    property int    speed:      50        // ms per character
    property bool   loop:       false
    property int    pauseMs:    1200      // pause at end before looping
    property bool   showCursor: true
    property color  color:      Theme.textPrimary
    property real   pixelSize:  Theme.textBase
    property string fontFamily: Theme.fontFamily

    implicitWidth:  _disp.implicitWidth
    implicitHeight: _disp.implicitHeight

    property int  _pos:           0
    property bool _cursorVisible: true

    Text {
        id:             _disp
        text:           root.text.substring(0, root._pos) +
                        (root.showCursor && root._cursorVisible ? "│" : "")
        color:          root.color
        font.family:    root.fontFamily
        font.pixelSize: root.pixelSize
    }

    Timer {
        id:       _typeTimer
        interval: root.speed
        repeat:   true
        running:  root.text !== "" && root._pos < root.text.length

        onTriggered: {
            if (root._pos < root.text.length) {
                root._pos++
                if (root._pos === root.text.length && root.loop)
                    _pauseTimer.start()
            }
        }
    }

    Timer {
        id:       _pauseTimer
        interval: root.pauseMs
        onTriggered: { root._pos = 0 }
    }

    SequentialAnimation {
        running: root.showCursor
        loops:   Animation.Infinite
        PropertyAction  { target: root; property: "_cursorVisible"; value: true  }
        PauseAnimation  { duration: 530 }
        PropertyAction  { target: root; property: "_cursorVisible"; value: false }
        PauseAnimation  { duration: 530 }
    }

    onTextChanged: { _pos = 0; _typeTimer.restart() }
}
