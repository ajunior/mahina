pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Horizontal row of filter chips. Clicking a chip toggles its active state.
//
// Usage:
//   FilterBar {
//       filters: [
//           { key: "all",    label: "All",    active: true  },
//           { key: "open",   label: "Open",   active: false },
//           { key: "closed", label: "Closed", active: false },
//       ]
//       onFilterToggled: (f, active) => applyFilter(f.key, active)
//   }
Item {
    id: root

    property var  filterItems:    []
    property bool showClearAll:   true
    property bool multiSelect:    true

    signal filterToggled(var filterItem, bool active)
    signal cleared()

    implicitHeight: 36
    implicitWidth:  _row.implicitWidth

    readonly property bool hasActive: {
        for (var i = 0; i < root.filterItems.length; i++)
            if (root.filterItems[i].active) return true
        return false
    }

    Row {
        id:      _row
        height:  parent.height
        spacing: Theme.sp2

        Repeater {
            id:    _chips
            model: root.filterItems

            // Bridge the parent component ref into the delegate scope so that
            // required-property delegates (which have their own scope boundary)
            // can reach it without relying on the 'root' id which may conflict
            // with an outer component's id: root.
            property Item fb: root

            // Required-property delegates do not inject `index`/`modelData`
            // into nested scopes — reference them through the delegate id.
            delegate: Item {
                id: _chip
                required property var  modelData
                required property int  index
                height: parent.height
                width:  _chipBg.width

                readonly property bool chipActive: modelData.active || false

                Rectangle {
                    id:     _chipBg
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    width:  _chipLabel.implicitWidth + 20
                    radius: Theme.radiusFull

                    color: _chip.chipActive ? Theme.primary : (_ch.hovered ? Theme.panel : Theme.surfaceVariant)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    border.color: _chip.chipActive ? Theme.primary : Theme.border
                    border.width: 1

                    HoverHandler { id: _ch }

                    Text {
                        id:             _chipLabel
                        anchors.centerIn: parent
                        text:           _chip.modelData.label || ""
                        color:          _chip.chipActive ? Theme.textOnPrimary : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            var fb   = _chips.fb
                            var i    = _chip.index
                            var copy = fb.filterItems.slice()
                            if (!fb.multiSelect) {
                                for (var j = 0; j < copy.length; j++)
                                    copy[j] = Object.assign({}, copy[j], { active: false })
                            }
                            var newActive = !copy[i].active
                            copy[i] = Object.assign({}, copy[i], { active: newActive })
                            fb.filterItems = copy
                            fb.filterToggled(copy[i], newActive)
                        }
                    }
                }
            }
        }

        // Clear all button
        Rectangle {
            visible: root.showClearAll && root.hasActive
            height:  28
            width:   _clearLabel.implicitWidth + 20
            radius:  Theme.radiusFull
            color:   _clearH.hovered ? Theme.error : "transparent"
            border.color: Theme.border; border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }

            HoverHandler { id: _clearH }

            Text {
                id:             _clearLabel
                anchors.centerIn: parent
                text:           "Clear all"
                color:          _clearH.hovered ? Theme.textOnPrimary : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    var copy = root.filterItems.slice()
                    for (var j = 0; j < copy.length; j++)
                        copy[j] = Object.assign({}, copy[j], { active: false })
                    root.filterItems = copy
                    root.cleared()
                }
            }
        }
    }
}
