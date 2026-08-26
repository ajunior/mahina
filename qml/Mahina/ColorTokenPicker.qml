pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Pick from a predefined palette of named design-token color swatches.
//
// Usage:
//   ColorTokenPicker {
//       tokens: [
//           { name: "Primary",  color: Theme.primary  },
//           { name: "Success",  color: Theme.success  },
//           { name: "Warning",  color: Theme.warning  },
//           { name: "Error",    color: Theme.error    },
//           { name: "Custom",   color: "#8b5cf6"      },
//       ]
//       selectedToken: "Primary"
//       onTokenSelected: (name, color) => applyColor(color)
//   }
Item {
    id: root

    property var    tokens:        []
    property string selectedToken: ""
    property int    swatchSize:    36
    property int    columns:       6

    signal tokenSelected(string name, color tokenColor)

    implicitWidth:  columns * (swatchSize + 8) - 8
    implicitHeight: Math.ceil(root.tokens.length / columns) * (swatchSize + 24) - 8

    Flow {
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: root.tokens
            delegate: Item {
                id: _rq1
                required property var  modelData
                required property int  index
                width:  root.swatchSize; height: root.swatchSize + 20

                readonly property bool isSelected: modelData.name === root.selectedToken

                // Swatch circle
                Rectangle {
                    width:  root.swatchSize; height: root.swatchSize; radius: root.swatchSize / 2
                    color:  _rq1.modelData.color || "transparent"
                    border.color: isSelected ? Theme.textPrimary : (_swH.hovered ? Theme.textSecondary : "transparent")
                    border.width: 2
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                    HoverHandler { id: _swH }

                    // Checkmark when selected
                    Text {
                        visible: isSelected
                        anchors.centerIn: parent
                        text: "✓"; color: "white"
                        font.pixelSize: root.swatchSize * 0.35
                        font.weight: Font.Bold

                        layer.enabled: true
                    }

                    // Scale on hover
                    scale: _swH.hovered ? 1.1 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedToken = _rq1.modelData.name
                            root.tokenSelected(_rq1.modelData.name, _rq1.modelData.color || "transparent")
                        }
                    }
                }

                Text {
                    anchors { top: parent.children[0].bottom; topMargin: 4; horizontalCenter: parent.horizontalCenter }
                    text:           _rq1.modelData.name || ""
                    color:          isSelected ? Theme.textPrimary : Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: 9
                    font.weight:    isSelected ? Font.Medium : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
