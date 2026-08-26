pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Dynamic-island style pill that expands to reveal content on click/hover.
//
// Usage:
//   FloatingIsland {
//       islandIcon:     "🎵"
//       islandTitle:    "Now Playing"
//       islandSubtitle: "Bohemian Rhapsody - Queen"
//       accentColor:    Theme.primary
//   }
Item {
    id: root

    property string islandIcon:     ""
    property string islandTitle:    ""
    property string islandSubtitle: ""
    property color  accentColor:    Theme.primary
    property bool   islandExpanded: false

    signal islandClicked()

    implicitWidth:  islandExpanded ? 260 : 120
    implicitHeight: islandExpanded ? 60 : 32
    Behavior on implicitWidth  { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

    Rectangle {
        anchors.fill: parent
        radius:       height / 2
        color:        "#0d0d0d"

        // Glow ring → highlight ring when expanded
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            border.color: root.islandExpanded
                          ? Qt.rgba(Qt.color(root.accentColor).r,
                                    Qt.color(root.accentColor).g,
                                    Qt.color(root.accentColor).b, 0.4) : "transparent"
            border.width: 1.5; color: "transparent"
            Behavior on border.color { ColorAnimation { duration: 200 } }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            // Icon — always visible
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.islandIcon
                font.pixelSize: root.islandExpanded ? 20 : 14
                Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
            }

            // Expanded content
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                visible: root.islandExpanded
                opacity: root.islandExpanded ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Text {
                    text:           root.islandTitle
                    color:          "white"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Font.Medium
                }
                Text {
                    text:           root.islandSubtitle
                    color:          Qt.rgba(1, 1, 1, 0.6)
                    font.family:    Theme.fontFamily
                    font.pixelSize: 9
                    elide:          Text.ElideRight
                    width:          170
                }
            }

            // Collapsed label
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.islandExpanded && root.islandTitle !== ""
                opacity: root.islandExpanded ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 150 } }
                text:           root.islandTitle
                color:          "white"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                elide:          Text.ElideRight
                width:          70
            }
        }

        // Subtle accent dot
        Rectangle {
            visible: root.islandExpanded
            width:   6; height: 6; radius: 3
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
            color: root.accentColor
            SequentialAnimation on opacity {
                loops: Animation.Infinite; running: root.islandExpanded
                NumberAnimation { to: 0.3; duration: 700 }
                NumberAnimation { to: 1.0; duration: 700 }
            }
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.islandExpanded = !root.islandExpanded
                root.islandClicked()
            }
        }
    }
}
