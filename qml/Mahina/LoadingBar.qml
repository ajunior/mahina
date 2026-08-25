import QtQuick
import Mahina

// Thin progress bar, typically anchored to the top of a container.
// Use progress=-1 for indeterminate (animated sweep).
//
// Usage:
//   LoadingBar {
//       anchors { top: parent.top; left: parent.left; right: parent.right }
//       running: isLoading
//       progress: loadProgress   // 0..1  or  -1 for indeterminate
//   }
Rectangle {
    id: root

    property real   progress:  -1   // -1 = indeterminate
    property bool   running:   false
    property color  barColor:  Theme.primary
    property int    barHeight: 3

    height:  running ? barHeight : 0
    Behavior on height { NumberAnimation { duration: Theme.durationFast } }

    color:     Qt.rgba(Qt.color(root.barColor).r,
                       Qt.color(root.barColor).g,
                       Qt.color(root.barColor).b, 0.15)
    visible:   running
    clip: true

    // Determinate fill
    Rectangle {
        id:       _fill
        visible:  root.progress >= 0
        height:   parent.height
        width:    root.progress >= 0 ? root.width * Math.max(0, Math.min(1, root.progress)) : 0
        color:    root.barColor
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    // Indeterminate sweep — a shorter bar that slides back and forth
    Rectangle {
        id:      _sweep
        visible: root.progress < 0 && root.running
        height:  parent.height
        width:   root.width * 0.4
        color:   root.barColor
        x:       _sweepAnim.running ? _sweepAnim.to : -width

        NumberAnimation {
            id:         _sweepAnim
            target:     _sweep
            property:   "x"
            from:       -_sweep.width
            to:         root.width
            duration:   1200
            loops:      Animation.Infinite
            easing.type: Easing.InOutSine
            running:    root.progress < 0 && root.running
        }
    }
}
