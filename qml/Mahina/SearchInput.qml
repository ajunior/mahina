import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Mahina

// Search field with leading magnifying-glass icon and an inline clear button.
//
// Usage:
//   SearchInput { placeholder: "Search people…"; onTextChanged: filter(text) }
//   SearchInput { text: q; onCleared: q = "" }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property alias text:        _field.text
    property alias placeholder: _field.placeholderText
    property string helper:     ""
    property string errorText:  ""
    property bool   disabled:   false
    property bool   clearable:  true

    readonly property bool hasError: errorText !== ""

    signal cleared()

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  240
    implicitHeight: _col.implicitHeight

    readonly property real _fieldH: Theme.textBase + Theme.sp2 * 2 + 2

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        // ── Field box ─────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:      root._fieldH
            color:       Theme.surface
            radius:      Theme.radiusSm
            border.width: _field.activeFocus ? 2 : 1
            border.color: root.hasError        ? Theme.error
                        : _field.activeFocus   ? Theme.primary
                        : _boxHover.containsMouse ? Theme.borderStrong
                        : Theme.border

            HoverHandler { id: _boxHover }
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
            Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }

            // Leading search icon
            Icon {
                id: _searchIcon
                name:  Icons.magnifyingGlass
                size:  16
                color: root.hasError      ? Theme.error
                     : _field.activeFocus ? Theme.primary
                     : Theme.textSecondary
                anchors.left:           parent.left
                anchors.leftMargin:     Theme.sp3
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            // Text field
            TextField {
                id:              _field
                anchors {
                    left:            parent.left
                    leftMargin:      Theme.sp3 + 16 + Theme.sp2
                    right:           parent.right
                    rightMargin:     root.clearable && text !== "" ? Theme.sp3 + 20 + Theme.sp2
                                                                   : Theme.sp3
                    verticalCenter:  parent.verticalCenter
                }
                placeholderText:      "Search…"
                color:                Theme.textPrimary
                placeholderTextColor: Theme.textDisabled
                selectionColor:       Theme.primarySubtle
                selectedTextColor:    Theme.primary
                enabled:              !root.disabled
                font.family:          Theme.fontFamily
                font.pixelSize:       Theme.textBase
                verticalAlignment:    Text.AlignVCenter
                background:           null
                padding:              0

                Keys.onEscapePressed: {
                    if (text !== "") { text = ""; root.cleared() }
                    else focus = false
                }
            }

            // Clear button
            Item {
                id:      _clearBtn
                visible: root.clearable && _field.text !== ""
                width:   20
                height:  20
                anchors.right:          parent.right
                anchors.rightMargin:    Theme.sp2 + 1
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius:       width / 2
                    color:        _cHover.containsMouse ? Theme.border : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                Icon {
                    anchors.centerIn: parent
                    name:  Icons.x
                    size:  11
                    color: Theme.textSecondary
                }

                HoverHandler { id: _cHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        _field.text = ""
                        root.cleared()
                        _field.forceActiveFocus()
                    }
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
