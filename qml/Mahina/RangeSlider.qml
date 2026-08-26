pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Two-handle slider for selecting a min/max range.
//
// Usage:
//   RangeSlider {
//       label: "Price range"; from: 0; to: 1000
//       first.value: 200; second.value: 800
//       showValues: true; decimals: 0
//   }
//
//   // React to changes:
//   RangeSlider {
//       from: 0; to: 100
//       first.onMoved:  low  = first.value
//       second.onMoved: high = second.value
//   }
Item {
    id: root

    // ── API — aliases into QQC.RangeSlider ────────────────────────────────────
    property alias first:    _rs.first
    property alias second:   _rs.second
    property alias from:     _rs.from
    property alias to:       _rs.to
    property alias stepSize: _rs.stepSize
    property alias live:     _rs.live

    property string label:      ""
    property bool   showValues: false
    property int    decimals:   0
    property string helper:     ""
    property string errorText:  ""
    property bool   disabled:   false

    readonly property bool hasError: errorText !== ""

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        // Header: label + range values
        RowLayout {
            visible:          root.label !== "" || root.showValues
            Layout.fillWidth: true

            Text {
                text:             root.label
                visible:          root.label !== ""
                color:            root.disabled ? Theme.textDisabled : Theme.textPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                font.weight:      Theme.weightMedium
                Layout.fillWidth: true
            }

            Text {
                visible:        root.showValues
                text:           _rs.first ? _rs.first.value.toFixed(root.decimals) + " – " + _rs.second.value.toFixed(root.decimals) : ""
                color:          root.disabled ? Theme.textDisabled : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightMedium
            }
        }

        // ── QQC RangeSlider ───────────────────────────────────────────────────
        QQC.RangeSlider {
            id:               _rs
            Layout.fillWidth: true
            from:             0
            to:               1
            enabled:          !root.disabled
            focusPolicy:      Qt.TabFocus

            background: Item {
                id:     _bg
                x:      _rs.leftPadding
                y:      _rs.topPadding + (_rs.availableHeight - height) / 2
                width:  _rs.availableWidth
                height: 4

                // Full track
                Rectangle {
                    anchors.fill: parent
                    radius:       2
                    color:        _rs.enabled ? Theme.border : Theme.panel
                }

                // Active range between handles — null-guarded
                Rectangle {
                    x:      _rs.first  ? _rs.first.visualPosition  * _bg.width : 0
                    width:  _rs.second && _rs.first
                            ? (_rs.second.visualPosition - _rs.first.visualPosition) * _bg.width : 0
                    height: _bg.height
                    radius: 2
                    color:  _rs.enabled
                            ? (root.hasError ? Theme.error : Theme.primary)
                            : Theme.borderStrong

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }
            }

            first.handle: Item {
                x: _rs.leftPadding + _rs.first.visualPosition * (_rs.availableWidth - width)
                y: _rs.topPadding  + (_rs.availableHeight - height) / 2
                implicitWidth:  18
                implicitHeight: 18

                Rectangle {
                    anchors.fill: parent
                    radius:       width / 2
                    color:        _rs.enabled ? Theme.surface : Theme.panel
                    border.color: root.hasError          ? Theme.error
                                : _rs.first.pressed      ? Theme.primaryActive
                                : _fHover.containsMouse  ? Theme.primaryHover
                                : Theme.primary
                    border.width: _rs.first.pressed ? 3 : 2

                    HoverHandler { id: _fHover }
                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                    Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }
                }

                Rectangle {
                    visible:         _rs.activeFocus
                    anchors.fill:    parent
                    anchors.margins: -3
                    radius:          width / 2
                    color:           "transparent"
                    border.color:    Theme.primary
                    border.width:    2
                    opacity:         0.5
                }
            }

            second.handle: Item {
                x: _rs.leftPadding + _rs.second.visualPosition * (_rs.availableWidth - width)
                y: _rs.topPadding  + (_rs.availableHeight - height) / 2
                implicitWidth:  18
                implicitHeight: 18

                Rectangle {
                    anchors.fill: parent
                    radius:       width / 2
                    color:        _rs.enabled ? Theme.surface : Theme.panel
                    border.color: root.hasError           ? Theme.error
                                : _rs.second.pressed      ? Theme.primaryActive
                                : _sHover.containsMouse   ? Theme.primaryHover
                                : Theme.primary
                    border.width: _rs.second.pressed ? 3 : 2

                    HoverHandler { id: _sHover }
                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                    Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }
                }

                Rectangle {
                    visible:         _rs.activeFocus
                    anchors.fill:    parent
                    anchors.margins: -3
                    radius:          width / 2
                    color:           "transparent"
                    border.color:    Theme.primary
                    border.width:    2
                    opacity:         0.5
                }
            }
        }

        // Helper / error
        Text {
            visible:        root.errorText !== "" || root.helper !== ""
            text:           root.errorText !== "" ? root.errorText : root.helper
            color:          root.errorText !== "" ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }
}
