pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Mahina

// Multiline text input with label, helper, error, char count, and auto-grow.
//
// Usage:
//   Textarea {
//       label:           "Description"
//       placeholderText: "Write something…"
//       rows:            4
//   }
//   Textarea {
//       label:     "Bio"
//       showCount: true
//       maxLength: 280
//   }
//   Textarea {
//       autoGrow: true    // height expands with content instead of scrolling
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property alias text:            _area.text
    property alias placeholderText: _area.placeholderText
    property alias readOnly:        _area.readOnly
    property alias selectByMouse:   _area.selectByMouse

    property string label:     ""
    property string helper:    ""
    property string errorText: ""
    property bool   showCount: false
    property int    maxLength: 0       // 0 = no limit
    property int    rows:      4       // visible rows when autoGrow is false
    property bool   autoGrow:  false   // grow height with content instead of scrolling

    readonly property bool hasError:  errorText !== ""
    readonly property bool overLimit: maxLength > 0 && _area.text.length > maxLength

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  240
    implicitHeight: _col.implicitHeight

    readonly property real _rowH: Theme.textBase * 1.6
    readonly property real _pad:  Theme.sp3

    // ── Layout ────────────────────────────────────────────────────────────────
    Column {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        // Label
        Text {
            text:           root.label
            visible:        root.label !== ""
            color:          root.hasError ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Field box ─────────────────────────────────────────────────────────
        Rectangle {
            id:     _field
            width:  parent.width

            // autoGrow: expand to fit text; fixed: clamp to rows
            height: root.autoGrow
                    ? _area.implicitHeight + root._pad * 2
                    : root.rows * root._rowH + root._pad * 2

            Behavior on height { NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic } }

            radius: Theme.radiusSm
            color:  root.enabled ? Theme.surface : Theme.panel
            clip:   true

            border.width: _area.activeFocus ? 2 : 1
            border.color: root.hasError        ? Theme.error
                        : _area.activeFocus    ? Theme.primary
                        : _hover.hovered ? Theme.borderStrong
                        : Theme.border

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            HoverHandler { id: _hover; enabled: root.enabled }

            // ScrollBar sits on the right edge inside the border
            ScrollBar {
                id:      _vbar
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: 2 }
                policy:  ScrollBar.AsNeeded
                visible: !root.autoGrow && _flick.contentHeight > _flick.height
            }

            Flickable {
                id: _flick
                anchors {
                    fill:        parent
                    margins:     root._pad
                    rightMargin: _vbar.visible ? _vbar.width + root._pad : root._pad
                }

                // In autoGrow mode the Flickable matches content — no scrolling
                contentWidth:       width
                contentHeight:      _area.implicitHeight
                clip:               false
                boundsMovement:     Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                interactive:        !root.autoGrow

                // Wires TextArea cursor/selection scrolling to this Flickable
                TextArea.flickable: _area

                TextArea {
                    id:     _area
                    width:  _flick.width

                    wrapMode:             Text.Wrap
                    color:                root.enabled ? Theme.textPrimary : Theme.textDisabled
                    placeholderTextColor: Theme.textDisabled
                    selectionColor:       Theme.primary
                    selectedTextColor:    Theme.textOnPrimary
                    font.family:          Theme.fontFamily
                    font.pixelSize:       Theme.textBase
                    enabled:              root.enabled

                    // Strip all default padding — field box provides it
                    padding:       0
                    topPadding:    0
                    bottomPadding: 0
                    leftPadding:   0
                    rightPadding:  0

                    selectByMouse: true
                    background:    null

                    // Tab moves focus, doesn't insert a literal tab
                    Keys.onTabPressed: (e) => {
                        nextItemInFocusChain().forceActiveFocus()
                        e.accepted = true
                    }
                }
            }
        }

        // ── Footer: helper / error  +  char count ─────────────────────────────
        RowLayout {
            width:   parent.width
            visible: root.hasError || root.helper !== "" || root.showCount

            Text {
                text:             root.hasError ? root.errorText : root.helper
                visible:          root.hasError || root.helper !== ""
                color:            root.hasError ? Theme.error : Theme.textSecondary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textXs
                Layout.fillWidth: true
            }

            Text {
                visible:             root.showCount
                text:                root.maxLength > 0
                                     ? _area.text.length + " / " + root.maxLength
                                     : _area.text.length.toString()
                color:               root.overLimit ? Theme.error : Theme.textDisabled
                font.family:         Theme.fontFamily
                font.pixelSize:      Theme.textXs
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
