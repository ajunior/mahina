pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Click-to-edit text field — shows as plain text, activates on click.
//
// Usage:
//   InlineEdit {
//       editValue:   "Untitled document"
//       fontSize:    Theme.textXl
//       onCommitted: (t) => saveName(t)
//   }
Item {
    id: root

    property string editValue:   ""
    property string placeholder: "Click to edit"
    property real   fontSize:    Theme.textBase
    property bool   editing:     false

    signal committed(string text)

    implicitWidth:  Math.max(_display.implicitWidth + 16, 120)
    implicitHeight: Math.max(_display.implicitHeight + 8, 32)

    function _commit(): void {
        root.editing   = false
        root.editValue = _input.text
        root.committed(root.editValue)
    }

    // Display mode
    Rectangle {
        anchors.fill: parent
        visible: !root.editing
        color:   _dH.hovered ? Theme.hover : "transparent"
        radius:  Theme.radiusSm
        border.color: _dH.hovered ? Theme.border : "transparent"
        border.width: 1
        Behavior on color        { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
        HoverHandler { id: _dH }

        Text {
            id:             _display
            anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
            text:           root.editValue !== "" ? root.editValue : root.placeholder
            color:          root.editValue !== "" ? Theme.textPrimary : Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: root.fontSize
            elide:          Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Pencil hint
        Text {
            visible:        _dH.hovered
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 6 }
            text:           "✎"
            color:          Theme.textDisabled
            font.pixelSize: root.fontSize * 0.75
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.IBeamCursor
            onClicked: {
                root.editing = true
                _input.text  = root.editValue
                _input.selectAll()
                _input.forceActiveFocus()
            }
        }
    }

    // Edit mode
    Rectangle {
        anchors.fill: parent
        visible: root.editing
        color:   Theme.surface
        radius:  Theme.radiusSm
        border.color: Theme.primary; border.width: 2

        TextInput {
            id:             _input
            anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
            text:           root.editValue
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: root.fontSize
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse:  true
            selectedTextColor:    Theme.textOnPrimary
            selectionColor:       Qt.rgba(Qt.color(Theme.primary).r,
                                          Qt.color(Theme.primary).g,
                                          Qt.color(Theme.primary).b, 0.35)

            Keys.onReturnPressed:  root._commit()
            Keys.onEscapePressed:  { root.editing = false }

            onActiveFocusChanged: { if (!activeFocus && root.editing) root._commit() }
        }
    }
}
