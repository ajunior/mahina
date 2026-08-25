import QtQuick
import QtQuick.Layouts
import Mahina

// Exclusive radio button group driven by a model array.
//
// Usage:
//   RadioGroup {
//       label: "Subscription"
//       model: ["Monthly", "Annual", "Lifetime"]
//       currentIndex: 1
//       onSelectionChanged: (i) => console.log(model[i])
//   }
//
//   // Object model with labels and values:
//   RadioGroup {
//       model: [{ label: "Small", value: "sm" }, { label: "Large", value: "lg" }]
//       onSelectionChanged: (i) => doSomething(model[i].value)
//   }
//
//   // Horizontal layout:
//   RadioGroup { model: ["Left", "Center", "Right"]; horizontal: true }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:        []
    property int    currentIndex: 0
    property string label:        ""
    property string helper:       ""
    property string errorText:    ""
    property bool   disabled:     false
    property bool   horizontal:   false

    signal selectionChanged(int index)

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        // Group label
        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          root.disabled ? Theme.textDisabled : Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Radio items ───────────────────────────────────────────────────────
        // GridLayout: columns=1 → vertical stack; columns=count → single row
        GridLayout {
            id:               _grid
            Layout.fillWidth: true
            columns:          root.horizontal ? Math.max(1, root.model.length) : 1
            columnSpacing:    Theme.sp4
            rowSpacing:       Theme.sp2

            Repeater {
                id:    _rep
                model: root.model

                delegate: Radio {
                    id: _item
                    required property var modelData
                    required property int index

                    // Disable QQC's internal toggle so the binding below sticks
                    checkable: false
                    checked:   _item.index === root.currentIndex
                    enabled:   !root.disabled
                    text:      typeof modelData === "string"
                               ? modelData
                               : (modelData.label ?? String(modelData))

                    // Restore click behavior via MouseArea since checkable:false disables it
                    MouseArea {
                        anchors.fill: parent
                        enabled:      !root.disabled
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = _item.index
                            root.selectionChanged(_item.index)
                        }
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
