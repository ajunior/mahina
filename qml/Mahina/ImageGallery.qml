import QtQuick
import QtQuick.Controls
import QtQuick.Controls as QQC
import Mahina

// Grid gallery with lightbox overlay on tap.
//
// Usage:
//   ImageGallery {
//       images: [
//           { src: "qrc:/img/photo1.jpg", caption: "Sunset" },
//           { src: "qrc:/img/photo2.jpg" },
//       ]
//       columns: 3
//   }
Item {
    id: root

    property var    images:    []
    property int    columns:   3
    property real   thumbSize: 120
    property real   gap:       Theme.sp2
    property int    _lightbox: -1

    implicitWidth:  columns * (thumbSize + gap) - gap
    implicitHeight: Math.ceil(images.length / columns) * (thumbSize + gap) - gap

    // Thumbnail grid
    Repeater {
        model: root.images
        delegate: Item {
            id: _rq1
            required property var  modelData
            required property int  index

            width:  root.thumbSize; height: root.thumbSize
            x: (index % root.columns) * (root.thumbSize + root.gap)
            y: Math.floor(index / root.columns) * (root.thumbSize + root.gap)

            Rectangle {
                anchors.fill: parent
                radius:       Theme.radiusMd
                color:        Theme.panel
                clip:         true

                Image {
                    anchors.fill: parent
                    source:       _rq1.modelData.src ?? ""
                    fillMode:     Image.PreserveAspectCrop
                    smooth:       true
                }

                // Hover overlay
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, _thumbHover.containsMouse ? 0.25 : 0)
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                HoverHandler { id: _thumbHover }

                MouseArea {
                    anchors.fill:  parent
                    cursorShape:   Qt.PointingHandCursor
                    onClicked:     root._lightbox = _rq1.index
                }
            }
        }
    }

    // Lightbox overlay
    QQC.Popup {
        id:     _lb
        anchors.centerIn: Overlay.overlay
        visible:     root._lightbox >= 0
        modal:       true
        padding:     0
        width:       Math.min(Overlay.overlay ? Overlay.overlay.width * 0.9 : 600, 800)
        height:      Math.min(Overlay.overlay ? Overlay.overlay.height * 0.9 : 500, 600)
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        onClosed: root._lightbox = -1

        background: Rectangle {
            color:        Theme.background
            radius:       Theme.radiusLg
            border.color: Theme.border
            border.width: 1
        }

        // Image
        Image {
            anchors { fill: parent; margins: Theme.sp4; bottomMargin: Theme.sp4 + (root._lightbox >= 0 && (root.images[root._lightbox].caption ?? "") !== "" ? 28 : Theme.sp4) }
            source:   root._lightbox >= 0 ? (root.images[root._lightbox].src ?? "") : ""
            fillMode: Image.PreserveAspectFit
            smooth:   true
        }

        // Caption
        Text {
            visible:     root._lightbox >= 0 && (root.images[root._lightbox].caption ?? "") !== ""
            anchors { bottom: parent.bottom; bottomMargin: Theme.sp3; horizontalCenter: parent.horizontalCenter }
            text:        root._lightbox >= 0 ? (root.images[root._lightbox].caption ?? "") : ""
            color:       Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.textSm
        }

        // Prev / Next buttons
        Rectangle {
            anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
            visible: root._lightbox > 0
            width: 36; height: 36; radius: 18
            color: Theme.surface; opacity: 0.9
            Text { anchors.centerIn: parent; text: "‹"; color: Theme.textPrimary; font.pixelSize: 20 }
            MouseArea { anchors.fill: parent; onClicked: root._lightbox = Math.max(0, root._lightbox - 1) }
        }
        Rectangle {
            anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
            visible: root._lightbox >= 0 && root._lightbox < root.images.length - 1
            width: 36; height: 36; radius: 18
            color: Theme.surface; opacity: 0.9
            Text { anchors.centerIn: parent; text: "›"; color: Theme.textPrimary; font.pixelSize: 20 }
            MouseArea { anchors.fill: parent; onClicked: root._lightbox = Math.min(root.images.length - 1, root._lightbox + 1) }
        }
    }
}
