pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Loading placeholder with a sweeping shimmer animation.
//
// Usage:
//   // Single rectangle (e.g. image placeholder)
//   Skeleton { width: 200; height: 120 }
//
//   // Circle (avatar placeholder)
//   Skeleton { shape: Skeleton.Shape.Circle; width: 40 }
//
//   // Text block
//   Skeleton { shape: Skeleton.Shape.Text; lines: 3; width: 240 }
//
//   // Static (no animation):
//   Skeleton { width: 80; height: 12; animate: false }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Shape { Rect, Circle, Text }

    property int  shape:   Skeleton.Shape.Rect
    property int  lines:   3      // only for Text shape
    property bool animate: true

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  120
    implicitHeight: {
        switch (root.shape) {
            case Skeleton.Shape.Circle: return root.width
            case Skeleton.Shape.Text:   return root.lines * 14 + Math.max(0, root.lines - 1) * 8
            default:                    return 16
        }
    }

    // ── Shared shimmer phase ──────────────────────────────────────────────────
    // All items in this component share the same phase so they sweep in sync.
    property real _phase: -0.6

    SequentialAnimation on _phase {
        loops:   Animation.Infinite
        running: root.animate && root.visible
        NumberAnimation { from: -0.6; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
        PauseAnimation  { duration: 600 }
    }

    // ── Rect / Circle ─────────────────────────────────────────────────────────
    Rectangle {
        id:      _block
        visible: root.shape !== Skeleton.Shape.Text
        width:   root.width
        height:  root.shape === Skeleton.Shape.Circle ? root.width : root.height
        radius:  root.shape === Skeleton.Shape.Circle ? width / 2 : Theme.radiusSm
        color:   Theme.panel
        clip:    true

        Rectangle {
            x:      _block.width * root._phase
            y:      0
            width:  _block.width * 0.55
            height: _block.height
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── Text lines ────────────────────────────────────────────────────────────
    Column {
        visible: root.shape === Skeleton.Shape.Text
        width:   root.width
        spacing: 8

        Repeater {
            model: root.lines

            delegate: Rectangle {
                required property int index

                // Last line is shorter to simulate natural paragraph end
                width:  index === root.lines - 1 && root.lines > 1
                        ? parent.width * 0.65 : parent.width
                height: 14
                radius: Theme.radiusSm
                color:  Theme.panel
                clip:   true

                Rectangle {
                    x:      parent.width * root._phase
                    y:      0
                    width:  parent.width * 0.55
                    height: parent.height
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop {
                            position: 0.5
                            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                        }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }
        }
    }
}
