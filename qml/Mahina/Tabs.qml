pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Tabbed content panels. The tab header is linked to a StackLayout of content pages.
//
// Usage:
//   Tabs {
//       model: ["Overview", "Activity", "Settings"]
//       Rectangle { color: "red"   }   // page 0
//       Rectangle { color: "green" }   // page 1
//       Rectangle { color: "blue"  }   // page 2
//   }
//
//   // With icons:
//   Tabs {
//       model: [{ label: "Docs", icon: Icons.book }, { label: "API", icon: Icons.codeBlock }]
//       // children as above
//   }
//
//   // Pill variant:
//   Tabs { variant: "pill"; model: ["Day", "Week", "Month"] }
//
// Children are placed in a StackLayout; index follows currentIndex.
Item {
    id: root

    default property alias content: _stack.children
    property var    model:        []
    property int    currentIndex: 0
    property string variant:      "underline"  // "underline" | "pill" | "card"
    property bool   fullWidth:    false         // stretch tabs to fill header

    signal tabChanged(int index)

    implicitWidth:  400
    implicitHeight: _header.height + _stack.implicitHeight

    onCurrentIndexChanged: root.tabChanged(currentIndex)

    // ── Tab header ────────────────────────────────────────────────────────────
    Item {
        id:     _header
        width:  parent.width
        height: root.variant === "pill" ? 44 : 40

        // "underline" bottom border
        Rectangle {
            visible: root.variant === "underline"
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: Theme.border
        }

        // "pill" / "card" background
        Rectangle {
            visible:  root.variant === "pill" || root.variant === "card"
            anchors.fill: parent
            color:    Theme.panel
            radius:   root.variant === "pill" ? Theme.radiusMd : 0
            border.color: root.variant === "card" ? Theme.border : "transparent"
            border.width: 1
        }

        Row {
            id:     _tabRow
            height: parent.height
            x:      root.variant === "pill" ? Theme.sp1 : 0

            Repeater {
                model: root.model
                delegate: Item {
                    id: _rq1
                    required property var modelData
                    required property int index

                    readonly property string _label: typeof modelData === "string" ? modelData : (modelData.label ?? "")
                    readonly property string _icon:  typeof modelData === "string" ? "" : (modelData.icon ?? "")
                    readonly property bool   _sel:   index === root.currentIndex

                    height: _tabRow.height
                    width:  root.fullWidth
                            ? root.width / root.model.length
                            : Math.max(80, _tabInner.implicitWidth + Theme.sp4 * 2)

                    // Sliding pill indicator (pill variant)
                    Rectangle {
                        visible:  root.variant === "pill" && _sel
                        anchors { fill: parent; margins: Theme.sp1 }
                        radius:   Theme.radiusSm
                        color:    Theme.surface
                        border.color: Theme.border; border.width: 1
                    }

                    // Underline indicator (underline variant)
                    Rectangle {
                        visible: root.variant === "underline" && _sel
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        height: 2; color: Theme.primary
                        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
                    }

                    // Card tab style
                    Rectangle {
                        visible: root.variant === "card" && _sel
                        anchors { fill: parent }
                        color:   Theme.surface
                        border.color: Theme.border; border.width: 1
                        Rectangle { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 1; color: Theme.surface }
                    }

                    Row {
                        id:               _tabInner
                        anchors.centerIn: parent
                        spacing:          Theme.sp2

                        Icon {
                            visible: _icon !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            name:  _icon; size: 14
                            color: _sel ? Theme.primary : Theme.textSecondary
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           _label
                            color:          _sel ? (root.variant === "underline" ? Theme.primary : Theme.textPrimary) : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _sel ? Theme.weightSemibold : Theme.weightRegular
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentIndex = _rq1.index
                    }
                }
            }
        }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    StackLayout {
        id:           _stack
        anchors {
            top:    _header.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        currentIndex: root.currentIndex
    }
}
