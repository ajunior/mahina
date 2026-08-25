import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property int  pageCount:   1
    property int  currentPage: 1
    property real pageWidthMm:  210   // A4 width mm
    property real pageHeightMm: 297   // A4 height mm
    property real previewScale: 0.8   // 0.1 – 2.0
    property string paperColor: "#ffffff"

    default property alias pageContent: _pageContent.data

    signal pageChanged(int page)

    implicitWidth:  540
    implicitHeight: 480

    // Pixel dimensions of page at current scale
    readonly property real _pw: pageWidthMm  * (96 / 25.4) * previewScale
    readonly property real _ph: pageHeightMm * (96 / 25.4) * previewScale

    Rectangle {
        anchors.fill: parent
        color:  Theme.dark ? "#282828" : "#555555"
        border.color: Theme.border; border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Toolbar
            Rectangle {
                width: parent.width; height: 40
                color: Theme.dark ? "#1e1e1e" : "#3c3c3c"
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: "#222" }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.sp3

                    // Prev page
                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color: _ppH.hovered && root.currentPage > 1 ? "#ffffff22" : "transparent"
                        HoverHandler { id: _ppH }
                        Text { anchors.centerIn: parent; text: "◀"; color: root.currentPage > 1 ? "#ffffff" : "#666"; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.currentPage > 1) { root.currentPage--; root.pageChanged(root.currentPage) } } }
                    }

                    Text {
                        text:  "Page " + root.currentPage + " of " + root.pageCount
                        color: "#cccccc"
                        font { family: Theme.fontFamily; pixelSize: Theme.textSm }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Next page
                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color: _npH.hovered && root.currentPage < root.pageCount ? "#ffffff22" : "transparent"
                        HoverHandler { id: _npH }
                        Text { anchors.centerIn: parent; text: "▶"; color: root.currentPage < root.pageCount ? "#ffffff" : "#666"; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.currentPage < root.pageCount) { root.currentPage++; root.pageChanged(root.currentPage) } } }
                    }

                    Rectangle { width: 1; height: 20; color: "#444" }

                    // Zoom out
                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color: _zoH.hovered ? "#ffffff22" : "transparent"
                        HoverHandler { id: _zoH }
                        Text { anchors.centerIn: parent; text: "−"; color: "#cccccc"; font.pixelSize: 14 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.previewScale = Math.max(0.2, root.previewScale - 0.1) }
                    }

                    Text {
                        text:  Math.round(root.previewScale * 100) + "%"
                        color: "#cccccc"
                        font { family: Theme.fontFamily; pixelSize: 12 }
                        anchors.verticalCenter: parent.verticalCenter
                        width: 42; horizontalAlignment: Text.AlignHCenter
                    }

                    // Zoom in
                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color: _ziH.hovered ? "#ffffff22" : "transparent"
                        HoverHandler { id: _ziH }
                        Text { anchors.centerIn: parent; text: "+"; color: "#cccccc"; font.pixelSize: 14 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.previewScale = Math.min(3.0, root.previewScale + 0.1) }
                    }

                    Rectangle { width: 1; height: 20; color: "#444" }

                    Text {
                        text:  root.pageWidthMm + "×" + root.pageHeightMm + "mm"
                        color: "#888888"
                        font { family: Theme.fontFamily; pixelSize: 11 }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Page canvas area
            Flickable {
                width:  parent.width
                height: root.height - 40
                contentWidth:  Math.max(parent.width, root._pw + 40)
                contentHeight: Math.max(parent.height - 40, root._ph + 40)
                clip: true
                QQC.ScrollBar.horizontal: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }
                QQC.ScrollBar.vertical:   QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

                // Page shadow
                Rectangle {
                    x:      (parent.width  - root._pw) / 2 + 4
                    y:      (parent.height - root._ph) / 2 + 4
                    width:  root._pw; height: root._ph
                    color:  "#00000060"
                    radius: 2
                }

                // Page paper
                Rectangle {
                    x:      (parent.width  - root._pw) / 2
                    y:      (parent.height - root._ph) / 2
                    width:  root._pw; height: root._ph
                    color:  root.paperColor
                    radius: 2
                    clip:   true

                    // Content area (scaled)
                    Item {
                        id:     _pageContent
                        x:      0; y: 0
                        width:  root._pw; height: root._ph
                        scale:  root.previewScale
                        transformOrigin: Item.TopLeft
                    }

                    // Page border
                    Rectangle {
                        anchors.fill: parent; radius: 2
                        color: "transparent"
                        border.color: "#cccccc"; border.width: 1
                    }
                }
            }
        }
    }
}
