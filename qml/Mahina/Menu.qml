import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Contextual action list attached to an anchor item.
//
// Usage:
//   Button { id: moreBtn; text: "•••"; onClicked: _menu.open() }
//
//   Menu {
//       id:     _menu
//       anchor: moreBtn
//       model: [
//           { label: "Edit",      icon: Icons.pencil                  },
//           { label: "Duplicate", icon: Icons.copy,   shortcut: "⌘D"  },
//           null,                                                        // divider
//           { label: "Delete",    icon: Icons.trash,  danger: true    },
//       ]
//       onTriggered: (index, item) => console.log(item.label)
//   }
//
//   // String shorthand (no icons):
//   Menu { anchor: btn; model: ["Cut", "Copy", "Paste"] }
//
//   // Context-menu trigger:
//   TapHandler { acceptedButtons: Qt.RightButton; onTapped: _ctx.open() }
//   Menu { id: _ctx; anchor: someItem; model: [...] }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Position { Bottom, Top, Left, Right, BottomRight, TopRight }

    property Item   anchor:   parent
    property var    model:    []
    property int    position: Menu.Position.Bottom

    // Real index of triggered item (skips dividers)
    signal triggered(int index, var item)

    function open()  { _popup.open()  }
    function close() { _popup.close() }

    width: 0; height: 0

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      root.anchor !== null ? root.anchor : root
        padding:     0
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        width: 220

        x: {
            switch (root.position) {
                case Menu.Position.Left:        return -width - Theme.sp1
                case Menu.Position.Right:       return (parent ? parent.width : 0) + Theme.sp1
                case Menu.Position.BottomRight:
                case Menu.Position.TopRight:    return parent ? parent.width - width : 0
                default:                        return 0
            }
        }
        y: {
            switch (root.position) {
                case Menu.Position.Top:
                case Menu.Position.TopRight:   return -height - Theme.sp1
                case Menu.Position.Left:
                case Menu.Position.Right:      return parent ? Math.round((parent.height - height) / 2) : 0
                default:                       return parent ? parent.height + Theme.sp1 : 0
            }
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0;    to: 1.0;  duration: Theme.durationNormal; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale";   from: 0.96; to: 1.0;  duration: Theme.durationNormal; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Column {
            id:      _list
            width:   _popup.width
            padding: Theme.sp1

            Repeater {
                model: root.model

                delegate: Loader {
                    id:   _ldr
                    required property var modelData
                    required property int index

                    width: _list.width - _list.padding * 2

                    // null or { divider: true } → separator line
                    readonly property bool isDivider: modelData === null
                                                   || (typeof modelData === "object"
                                                       && modelData !== null
                                                       && modelData.divider === true)

                    sourceComponent: isDivider ? _divComp : _itemComp

                    // Keep item data in sync reactively so checked/disabled update live
                    Binding { target: _ldr.item; property: "menuIndex"; value: _ldr.index;     when: !_ldr.isDivider && _ldr.status === Loader.Ready }
                    Binding { target: _ldr.item; property: "itemData";  value: _ldr.modelData; when: !_ldr.isDivider && _ldr.status === Loader.Ready }
                }
            }
        }
    }

    // ── Divider component ─────────────────────────────────────────────────────
    Component {
        id: _divComp
        Item {
            height: Theme.sp1 * 2 + 1
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y:     Theme.sp1
                width: parent.width
                height: 1
                color: Theme.border
            }
        }
    }

    // ── Action item component ─────────────────────────────────────────────────
    Component {
        id: _itemComp

        Rectangle {
            id: _itemRoot

            // Set by the Loader
            property int menuIndex: 0
            property var itemData:  null

            readonly property string  _label:    itemData === null ? ""
                                               : typeof itemData === "string" ? itemData
                                               : (itemData.label ?? "")
            readonly property string  _icon:     typeof itemData === "object" && itemData !== null
                                               ? (itemData.icon     ?? "") : ""
            readonly property string  _shortcut: typeof itemData === "object" && itemData !== null
                                               ? (itemData.shortcut ?? "") : ""
            readonly property bool    _danger:   typeof itemData === "object" && itemData !== null
                                               && itemData.danger   === true
            readonly property bool    _disabled: typeof itemData === "object" && itemData !== null
                                               && itemData.disabled === true
            readonly property bool    _checked:  typeof itemData === "object" && itemData !== null
                                               && itemData.checked  === true

            height: 36
            radius: Theme.radiusSm
            color:  "transparent"

            Rectangle {
                anchors.fill: parent
                radius:       Theme.radiusSm
                color:        _itemRoot._danger ? Theme.errorSubtle : Theme.surfaceVariant
                opacity:      !_itemRoot._disabled && _ma.containsMouse ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
            }

            MouseArea {
                id:           _ma
                anchors.fill: parent
                hoverEnabled: true
                enabled:      !_itemRoot._disabled
                cursorShape:  _itemRoot._disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    _popup.close()
                    root.triggered(_itemRoot.menuIndex, _itemRoot.itemData)
                }
            }

            RowLayout {
                anchors {
                    fill:        parent
                    leftMargin:  Theme.sp3
                    rightMargin: Theme.sp3
                }
                spacing: Theme.sp2

                // Leading icon
                Icon {
                    visible: _itemRoot._icon !== ""
                    name:    _itemRoot._icon
                    size:    16
                    color:   _itemRoot._disabled ? Theme.textDisabled
                           : _itemRoot._danger   ? Theme.error
                           : Theme.textSecondary
                }

                // Label
                Text {
                    text:             _itemRoot._label
                    color:            _itemRoot._disabled ? Theme.textDisabled
                                    : _itemRoot._danger   ? Theme.error
                                    : Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                }

                // Shortcut hint
                Text {
                    visible:        _itemRoot._shortcut !== ""
                    text:           _itemRoot._shortcut
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                }

                // Checked indicator
                Icon {
                    visible: _itemRoot._checked
                    name:    Icons.check
                    size:    14
                    color:   Theme.primary
                }
            }
        }
    }
}
