pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Select / dropdown component.
//
// Usage:
//   Dropdown {
//       label: "Country"
//       model: ["Australia", "Brazil", "Canada"]
//       onCurrentIndexChanged: console.log(currentValue)
//   }
//
//   // Object model with value + label:
//   Dropdown {
//       model: [
//           { value: "en", label: "English" },
//           { value: "pt", label: "Portuguese" },
//       ]
//       currentIndex: 0
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:        []
    property int    currentIndex: 0
    property string label:        ""
    property string placeholder:  "Select an option"
    property string helper:       ""
    property string errorText:    ""
    property bool   disabled:     false

    readonly property bool   hasError:    errorText !== ""
    readonly property string currentLabel: {
        if (currentIndex < 0 || currentIndex >= root.model.length) return ""
        var item = root.model[currentIndex]
        return (typeof item === "object" && item !== null) ? (item.label || "") : String(item)
    }
    readonly property var currentValue: {
        if (currentIndex < 0 || currentIndex >= root.model.length) return null
        var item = root.model[currentIndex]
        return (typeof item === "object" && item !== null) ? item.value : item
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  240
    implicitHeight: _col.implicitHeight

    // ── State ────────────────────────────────────────────────────────────────
    // The popup owns the open state: it is a QQC.Popup so it renders in the
    // window overlay, above whatever is stacked after the dropdown in a layout.
    // A plain child Rectangle drew *under* the content below it, no matter its z.
    readonly property bool _open: _popup.visible

    // Programmatic control, mirroring Menu's API.
    function open(): void  { if (!root.disabled) _popup.open() }
    function close(): void { _popup.close() }

    // ── Layout ────────────────────────────────────────────────────────────────
    Column {
        id:    _col
        width: parent.width
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

        // Trigger button
        Rectangle {
            id:     _trigger
            width:  parent.width
            height: Theme.textBase + Theme.sp2 * 2 + 2
            radius: Theme.radiusSm
            color:  root.disabled ? Theme.panel : Theme.surface

            border.width: root._open ? 2 : 1
            border.color: root.hasError   ? Theme.error
                        : root._open      ? Theme.primary
                        : _hover.hovered ? Theme.borderStrong
                        : Theme.border

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            HoverHandler { id: _hover; enabled: !root.disabled }

            RowLayout {
                anchors.fill:        parent
                anchors.leftMargin:  Theme.sp3
                anchors.rightMargin: Theme.sp3
                spacing:             Theme.sp2

                Text {
                    text:           root.currentLabel !== "" ? root.currentLabel : root.placeholder
                    color:          root.currentLabel !== "" ? (root.disabled ? Theme.textDisabled : Theme.textPrimary)
                                                            : Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    elide:          Text.ElideRight
                    Layout.fillWidth: true
                }

                // Chevron. Every other component in the library draws this with
                // the icon font; the literal ⌃/⌄ characters this used to carry
                // sit off-centre in opposite directions, so the arrow jumped
                // vertically each time the list opened.
                Icon {
                    name:  root._open ? Icons.caretUp : Icons.caretDown
                    size:  14
                    color: root._open ? Theme.primary : Theme.textSecondary

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled:      !root.disabled
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root._open ? _popup.close() : _popup.open()
            }
        }

        // Helper / error text
        Text {
            text:           root.hasError ? root.errorText : root.helper
            visible:        root.hasError || root.helper !== ""
            color:          root.hasError ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    // ── Dropdown popup ────────────────────────────────────────────────────────
    // A window-overlay popup, so the list is never covered by a sibling that
    // happens to be declared after the dropdown.
    QQC.Popup {
        id:          _popup
        parent:      _trigger
        padding:     Theme.sp1
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside
        focus:       true

        // Position just below the trigger
        x:      0
        y:      _trigger.height + Theme.sp1
        width:  _trigger.width
        height: Math.min(_list.contentHeight + Theme.sp1 * 2, 240)

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast }
        }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusSm
            border.color: Theme.border
            border.width: 1

            // Subtle drop shadow via layered rect
            Rectangle {
                anchors.fill:    parent
                anchors.margins: -1
                radius:          parent.radius + 1
                color:           "transparent"
                border.color:    Theme.shadowColor
                border.width:    1
                opacity:         Theme.shadowSmOpacity * 1.5
                z:               -1
            }
        }

        contentItem: ListView {
            id:      _list
            clip:    true
            model:   root.model
            spacing: 2

            delegate: Rectangle {
                id:     _opt
                required property var modelData
                required property int index

                width:  ListView.view.width
                height: 34
                radius: Theme.radiusSm

                readonly property bool selected: root.currentIndex === _opt.index
                readonly property string optLabel: {
                    var item = _opt.modelData
                    return (typeof item === "object" && item !== null) ? (item.label || "") : String(item)
                }

                color: _opt.selected           ? Theme.primarySubtle
                     : _optMouse.containsMouse ? Theme.panel
                     : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                RowLayout {
                    anchors.fill:       parent
                    anchors.leftMargin: Theme.sp3
                    anchors.rightMargin: Theme.sp3
                    spacing: Theme.sp2

                    Text {
                        text:           _opt.optLabel
                        color:          _opt.selected ? Theme.primary : Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    _opt.selected ? Theme.weightSemibold : Theme.weightRegular
                        elide:          Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Checkmark for selected item
                    Text {
                        visible:        _opt.selected
                        text:           "✓"
                        color:          Theme.primary
                        font.pixelSize: Theme.textSm
                        font.weight:    Theme.weightSemibold
                    }
                }

                MouseArea {
                    id:           _optMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = _opt.index
                        _popup.close()
                    }
                }
            }
        }
    }
}
