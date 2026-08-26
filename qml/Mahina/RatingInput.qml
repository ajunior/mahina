pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Interactive star rating input.
//
// Usage:
//   RatingInput {
//       value:    3
//       maxStars: 5
//       onRatingSelected: (r) => console.log("Rated:", r)
//   }
Item {
    id: root

    property int  value:    0
    property int  maxStars: 5
    property bool readOnly: false
    property real starSize: 28
    property color filledColor: Theme.warning
    property color emptyColor:  Theme.textDisabled
    property real  spacing:     4
    property string label:      ""

    signal ratingSelected(int rating)

    implicitWidth:  root.maxStars * (root.starSize + root.spacing) - root.spacing +
                    (root.label !== "" ? _ratingLabel.implicitWidth + 8 : 0)
    implicitHeight: root.starSize

    property int hoverRating: 0

    Row {
        spacing: root.spacing
        height:  parent.height

        Repeater {
            model: root.maxStars
            delegate: Item {
                id: _rq1
                required property int index
                width:  root.starSize
                height: root.starSize

                readonly property bool isLit: (root.readOnly ? root.value : (root.hoverRating > 0 ? root.hoverRating : root.value)) > index

                Text {
                    anchors.centerIn: parent
                    text:           isLit ? "★" : "☆"
                    font.pixelSize: root.starSize * 0.85
                    color: {
                        if (isLit) {
                            if (!root.readOnly && root.hoverRating > 0)
                                return Qt.rgba(Qt.color(root.filledColor).r, Qt.color(root.filledColor).g,
                                               Qt.color(root.filledColor).b, 0.75)
                            return root.filledColor
                        }
                        return root.emptyColor
                    }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                HoverHandler {
                    enabled: !root.readOnly
                    onHoveredChanged: root.hoverRating = hovered ? (_rq1.index + 1) : 0
                }
                MouseArea {
                    enabled: !root.readOnly
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        root.value = _rq1.index + 1
                        root.ratingSelected(root.value)
                    }
                }
            }
        }

        Text {
            id:      _ratingLabel
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
        }
    }
}
