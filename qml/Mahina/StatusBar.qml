pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Thin status bar for the bottom of a window.
// Each section takes an array of {icon?, text, color?} items.
//
// Usage:
//   StatusBar {
//       anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
//       leftItems:   [{ icon: Icons.checkCircle, text: "Ready",    color: Theme.success },
//                     { icon: Icons.wifiHigh,    text: "Connected" }]
//       centerItems: [{ text: "Line 42, Col 8" }]
//       rightItems:  [{ icon: Icons.gitBranch, text: "main" },
//                     { text: "UTF-8" }]
//   }
Item {
    id: root

    property var leftItems:   []
    property var centerItems: []
    property var rightItems:  []
    property color backgroundColor: Theme.panel

    signal itemClicked(string section, int index)

    implicitWidth:  400
    implicitHeight: 28

    Rectangle {
        anchors.fill:  parent
        color:         root.backgroundColor

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: Theme.border
        }

        RowLayout {
            anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
            spacing: 0

            // Left
            Row {
                spacing:          0
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: root.leftItems
                    delegate: Rectangle {
                        id: _rq1
                        required property var modelData
                        required property int index
                        height: root.implicitHeight
                        width:  _lir.implicitWidth + Theme.sp3 * 2
                        color:  _lbh.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _lbh }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.itemClicked("left", _rq1.index) }
                        Row {
                            id: _lir; anchors.centerIn: parent; spacing: Theme.sp1
                            Icon { visible: (_rq1.modelData.icon ?? "") !== ""; anchors.verticalCenter: parent.verticalCenter; name: _rq1.modelData.icon ?? ""; size: 11; color: _rq1.modelData.color ?? Theme.textSecondary }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: _rq1.modelData.text ?? ""; color: _rq1.modelData.color ?? Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Center
            Row {
                spacing:          0
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                Repeater {
                    model: root.centerItems
                    delegate: Rectangle {
                        id: _rq2
                        required property var modelData
                        required property int index
                        height: root.implicitHeight
                        width:  _cir.implicitWidth + Theme.sp3 * 2
                        color:  _cbh.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _cbh }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.itemClicked("center", _rq2.index) }
                        Row {
                            id: _cir; anchors.centerIn: parent; spacing: Theme.sp1
                            Icon { visible: (_rq2.modelData.icon ?? "") !== ""; anchors.verticalCenter: parent.verticalCenter; name: _rq2.modelData.icon ?? ""; size: 11; color: _rq2.modelData.color ?? Theme.textSecondary }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: _rq2.modelData.text ?? ""; color: _rq2.modelData.color ?? Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Right
            Row {
                spacing:          0
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: root.rightItems
                    delegate: Rectangle {
                        id: _rq3
                        required property var modelData
                        required property int index
                        height: root.implicitHeight
                        width:  _rir.implicitWidth + Theme.sp3 * 2
                        color:  _rbh.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _rbh }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.itemClicked("right", _rq3.index) }
                        Row {
                            id: _rir; anchors.centerIn: parent; spacing: Theme.sp1
                            Icon { visible: (_rq3.modelData.icon ?? "") !== ""; anchors.verticalCenter: parent.verticalCenter; name: _rq3.modelData.icon ?? ""; size: 11; color: _rq3.modelData.color ?? Theme.textSecondary }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: _rq3.modelData.text ?? ""; color: _rq3.modelData.color ?? Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                        }
                    }
                }
            }
        }
    }
}
