import QtQuick
import QtQuick.Layouts
import Mahina

// Star rating input with optional half-star precision.
//
// Usage:
//   Rating { value: 3 }
//   Rating { value: 4.5; allowHalf: true }
//   Rating { value: 2; readOnly: true; max: 10 }
//   Rating { value: 3; size: 28; onValueChanged: saveRating(value) }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property int  max:       5
    property real value:     0
    property bool allowHalf: false
    property bool readOnly:  false
    property real size:      20

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    // Hover preview value (0 = not hovering)
    property real _hoverVal: 0
    readonly property real _display: _hoverVal > 0 ? _hoverVal : root.value

    RowLayout {
        id:      _row
        spacing: Theme.sp1

        Repeater {
            model: root.max

            delegate: Item {
                id:             _star
                required property int index

                implicitWidth:  root.size
                implicitHeight: root.size

                // Determine fill state for display
                readonly property real _starIdx:  index + 1
                readonly property bool _full:     root._display >= _starIdx
                readonly property bool _half:     root.allowHalf
                                                  && !_full
                                                  && root._display >= _starIdx - 0.5

                Icon {
                    anchors.fill: parent
                    name:    Icons.starHalf
                    size:    root.size
                    weight:  Icon.Weight.Fill
                    color:   Theme.warning
                    visible: _star._half
                }

                Icon {
                    anchors.fill: parent
                    name:    Icons.star
                    size:    root.size
                    weight:  _star._full ? Icon.Weight.Fill : Icon.Weight.Regular
                    color:   _star._full ? Theme.warning : Theme.border
                    visible: !_star._half

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                // Hover + click
                MouseArea {
                    anchors.fill: parent
                    enabled:      !root.readOnly
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor

                    onPositionChanged: (mouse) => {
                        if (root.allowHalf)
                            root._hoverVal = mouse.x < width / 2 ? _star.index + 0.5 : _star.index + 1
                        else
                            root._hoverVal = _star.index + 1
                    }
                    onExited:   root._hoverVal = 0
                    onClicked:  (mouse) => {
                        if (root.allowHalf)
                            root.value = mouse.x < width / 2 ? _star.index + 0.5 : _star.index + 1
                        else
                            root.value = _star.index + 1
                        root._hoverVal = 0
                    }
                }
            }
        }
    }
}
