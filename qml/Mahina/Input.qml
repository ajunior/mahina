pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import Mahina

TextField {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string label:       ""
    property string helper:      ""
    property string errorText:   ""
    property string leadingIcon: ""
    property string trailingIcon:""
    property bool   hasError:    errorText !== ""

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  240
    implicitHeight: _column.implicitHeight

    // Expose inner field height for alignment
    readonly property real fieldHeight: Theme.textBase + Theme.sp2 * 2 + 2

    leftPadding:   leadingIcon  !== "" ? Theme.sp4 + 20 + Theme.sp2 : Theme.sp3
    rightPadding:  trailingIcon !== "" ? Theme.sp4 + 20 + Theme.sp2 : Theme.sp3
    topPadding:    _lbl.visible ? _lbl.implicitHeight + Theme.sp1 : 0
    bottomPadding: _hlp.visible ? Theme.sp1 + _hlp.implicitHeight : 0

    // ── Colors ────────────────────────────────────────────────────────────────
    color:            Theme.textPrimary
    placeholderTextColor: Theme.textDisabled
    selectionColor:   Theme.primarySubtle
    selectedTextColor: Theme.primary

    font.family:    Theme.fontFamily
    font.pixelSize: Theme.textBase
    verticalAlignment: Text.AlignVCenter

    // ── Background ────────────────────────────────────────────────────────────
    background: Column {
        id: _column
        spacing: Theme.sp1
        width: root.width

        // Label
        Text {
            id:              _lbl
            text:            root.label
            visible:         root.label !== ""
            color:           root.hasError ? Theme.error : Theme.textSecondary
            font.family:     Theme.fontFamily
            font.pixelSize:  Theme.textSm
            font.weight:     Theme.weightMedium
        }

        // Field box
        Item {
            width:          parent.width
            height:         root.fieldHeight
            implicitHeight: root.fieldHeight

            // Leading icon
            Icon {
                name:    root.leadingIcon
                size:    16
                color:   root.hasError ? Theme.error
                        : root.activeFocus ? Theme.primary
                        : Theme.textSecondary
                visible: root.leadingIcon !== ""
                anchors.left:           parent.left
                anchors.leftMargin:     Theme.sp3
                anchors.verticalCenter: parent.verticalCenter
            }

            // Trailing icon
            Icon {
                name:    root.trailingIcon
                size:    16
                color:   root.hasError ? Theme.error : Theme.textSecondary
                visible: root.trailingIcon !== ""
                anchors.right:          parent.right
                anchors.rightMargin:    Theme.sp3
                anchors.verticalCenter: parent.verticalCenter
            }

            // Border rect
            Rectangle {
                anchors.fill: parent
                color:        Theme.surface
                radius:       Theme.radiusSm
                border.width: root.activeFocus ? 2 : 1
                border.color: root.hasError    ? Theme.error
                            : root.activeFocus ? Theme.primary
                            : root.hovered     ? Theme.borderStrong
                            : Theme.border

                Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }
            }
        }

        // Helper / error text
        Text {
            id:             _hlp
            text:           root.hasError ? root.errorText : root.helper
            visible:        root.hasError || root.helper !== ""
            color:          root.hasError ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }
}
