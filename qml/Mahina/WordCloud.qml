pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Word cloud with font size proportional to word weight.
//
// Usage:
//   WordCloud {
//       words: [
//           { text: "design",    weight: 100 },
//           { text: "react",     weight: 75  },
//           { text: "typescript",weight: 60  },
//           { text: "animation", weight: 40  },
//       ]
//   }
Item {
    id: root

    property var  words:       []
    property real minFontSize: 10
    property real maxFontSize: 42
    property var  colorPalette: [Theme.primary, Theme.success, Theme.warning, Theme.error,
                             "#8b5cf6", "#0ea5e9", "#f97316", "#14b8a6"]

    signal wordClicked(string word)

    implicitWidth:  400
    implicitHeight: 260

    // Normalize weights and compute font sizes
    readonly property var _processed: {
        var ws = root.words
        if (!ws || ws.length === 0) return []
        var maxW = 0
        for (var i = 0; i < ws.length; i++) if ((ws[i].weight || 0) > maxW) maxW = ws[i].weight || 0
        if (maxW === 0) maxW = 1
        var res = []
        for (var j = 0; j < ws.length; j++) {
            var norm = (ws[j].weight || 0) / maxW
            var fs = root.minFontSize + norm * (root.maxFontSize - root.minFontSize)
            var col = root.colorPalette[j % root.colorPalette.length]
            res.push({ text: ws[j].text || "", fontSize: fs, norm: norm, color: col })
        }
        // Sort by fontSize descending so large words render first
        res.sort(function(a,b) { return b.fontSize - a.fontSize })
        return res
    }

    Flow {
        anchors { fill: parent; margins: 12 }
        spacing: 8

        Repeater {
            model: root._processed
            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                width:  _wordText.implicitWidth + 6
                height: _wordText.implicitHeight + 4

                Text {
                    id:             _wordText
                    anchors.centerIn: parent
                    text:           _rq1.modelData.text
                    font.pixelSize: _rq1.modelData.fontSize
                    font.family:    Theme.fontFamily
                    font.weight:    _rq1.modelData.fontSize > 22 ? Font.Bold : Font.Normal
                    color:          Qt.rgba(
                                        Qt.color(_rq1.modelData.color).r,
                                        Qt.color(_rq1.modelData.color).g,
                                        Qt.color(_rq1.modelData.color).b,
                                        0.6 + _rq1.modelData.norm * 0.4
                                    )
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Rectangle {
                    anchors.fill: parent; radius: 4
                    color:  _wh.hovered ? Qt.rgba(Qt.color(_rq1.modelData.color).r,
                                                   Qt.color(_rq1.modelData.color).g,
                                                   Qt.color(_rq1.modelData.color).b, 0.08)
                                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: _wh }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: root.wordClicked(_rq1.modelData.text)
                }
            }
        }
    }
}
