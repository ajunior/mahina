pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // tracks: [{label, color, keyframes: [{time: real, value: real}]}]
    property var  tracks:      []
    property real duration:    10.0   // seconds
    property real currentTime: 0.0
    property real zoom:        1.0    // pixels per second

    signal timeChanged(real t)
    signal keyframeMoved(int trackIndex, int keyframeIndex, real newTime)

    implicitWidth:  600
    implicitHeight: 240

    readonly property int _labelW:   100
    readonly property int _rulerH:   24
    readonly property int _trackH:   36
    readonly property real _pxPerSec: root.zoom * 50

    function _timeToPx(t) { return t * root._pxPerSec }
    function _pxToTime(px) { return px / root._pxPerSec }

    Rectangle {
        anchors.fill: parent
        color:  Theme.dark ? "#0d1117" : "#f6f8fa"
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Ruler + time controls
            Rectangle {
                width: parent.width; height: root._rulerH + 1
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                Row {
                    anchors.fill: parent

                    // Label area
                    Rectangle {
                        width: root._labelW; height: parent.height
                        color: Theme.panel
                        Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }
                        Row {
                            anchors.centerIn: parent; spacing: 4
                            // Play/stop
                            Rectangle {
                                width: 20; height: 20; radius: 4
                                color: _playH.hovered ? Theme.primary : "transparent"
                                HoverHandler { id: _playH }
                                Text { anchors.centerIn: parent; text: "▶"; color: _playH.hovered ? "#fff" : Theme.textSecondary; font.pixelSize: 9 }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.currentTime = 0; root.timeChanged(0) } }
                            }
                            Text {
                                text:  root.currentTime.toFixed(2) + "s"
                                color: Theme.primary; font { family: Theme.fontFamilyMono; pixelSize: 11 }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Ruler canvas
                    Rectangle {
                        width:  parent.width - root._labelW
                        height: parent.height
                        color:  "transparent"
                        clip:   true

                        Canvas {
                            id:     _ruler
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var step = root._pxPerSec >= 50 ? 1 : root._pxPerSec >= 20 ? 2 : 5
                                var off  = _timelineFlick.contentX
                                for (var t = 0; t <= root.duration; t += step) {
                                    var px = root._timeToPx(t) - off
                                    if (px < -10 || px > width + 10) continue
                                    ctx.fillStyle = Theme.textSecondary.toString()
                                    ctx.fillRect(px, height * 0.6, 1, height * 0.4)
                                    if (t % (step * 5) === 0 || step === 1) {
                                        ctx.font = "10px '" + Theme.fontFamilyMono + "'"
                                        ctx.fillText(t + "s", px + 2, 14)
                                    }
                                }
                                // Playhead tick
                                var phx = root._timeToPx(root.currentTime) - off
                                ctx.fillStyle = Theme.primary.toString()
                                ctx.fillRect(phx - 1, 0, 2, height)
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.IBeamCursor
                                onClicked: (m) => {
                                    var t = root._pxToTime(m.x + _timelineFlick.contentX)
                                    root.currentTime = Math.max(0, Math.min(root.duration, t))
                                    root.timeChanged(root.currentTime)
                                    _ruler.requestPaint()
                                }
                            }
                        }

                        Connections {
                            target: _timelineFlick
                            function onContentXChanged() { _ruler.requestPaint() }
                        }
                    }
                }
            }

            // Tracks
            Row {
                width:  parent.width
                height: root.height - root._rulerH - 1

                // Track labels
                Rectangle {
                    width:  root._labelW
                    height: parent.height
                    color:  Theme.panel
                    border.color: Theme.border; border.width: 0
                    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }
                    clip: true

                    Column {
                        y: -_timelineFlick.contentY
                        width: parent.width

                        Repeater {
                            model: root.tracks
                            delegate: Rectangle {
                                id: _rq2
                                required property var  modelData
                                required property int  index
                                width:  root._labelW; height: root._trackH
                                color:  "transparent"
                                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border; opacity: 0.5 }
                                Row {
                                    anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                                    spacing: Theme.sp2
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: _rq2.modelData.color || Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text:  _rq2.modelData.label || "Track"
                                        color: Theme.textPrimary
                                        font { family: Theme.fontFamily; pixelSize: 12 }
                                        elide: Text.ElideRight
                                        width: root._labelW - 20 - Theme.sp2 * 2
                                    }
                                }
                            }
                        }
                    }
                }

                // Timeline (horizontal scroll)
                Flickable {
                    id:    _timelineFlick
                    width: parent.width - root._labelW
                    height: parent.height
                    contentWidth: root._timeToPx(root.duration) + 40
                    contentHeight: root.tracks.length * root._trackH
                    clip: true
                    QQC.ScrollBar.horizontal: QQC.ScrollBar {}
                    QQC.ScrollBar.vertical:   QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }
                    onContentXChanged: _ruler.requestPaint()

                    // Background grid
                    Canvas {
                        id:     _grid
                        width:  parent.contentWidth
                        height: parent.contentHeight
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            // Alternating track rows
                            for (var t = 0; t < root.tracks.length; t++) {
                                ctx.fillStyle = (t % 2 === 0 ? "transparent"
                                    : Qt.rgba(0,0,0, Theme.dark ? 0.1 : 0.03)).toString()
                                ctx.fillRect(0, t * root._trackH, width, root._trackH)
                            }
                            // Second markers
                            ctx.fillStyle = Theme.border.toString()
                            for (var s = 0; s <= root.duration; s++) {
                                ctx.fillRect(root._timeToPx(s), 0, 1, height)
                            }
                        }
                    }

                    // Playhead line
                    Rectangle {
                        x:      root._timeToPx(root.currentTime)
                        y:      0
                        width:  2
                        height: parent.contentHeight
                        color:  Theme.primary
                        opacity: 0.7
                    }

                    // Keyframes per track
                    Repeater {
                        model: root.tracks
                        delegate: Item {
                            id: _rq3
                            required property var  modelData
                            required property int  index
                            y:      index * root._trackH
                            width:  _timelineFlick.contentWidth
                            height: root._trackH

                            Repeater {
                                model: _rq3.modelData.keyframes || []
                                delegate: Rectangle {
                                    id: _rq1
                                    required property var  modelData
                                    required property int  index
                                    property int trackIdx: parent.index

                                    x:      root._timeToPx(modelData.time) - 6
                                    y:      (root._trackH - 12) / 2
                                    width:  12; height: 12
                                    radius: 2
                                    rotation: 45
                                    color:  _kfH.hovered ? "#ffffff"
                                            : (parent.modelData.color || Theme.primary)
                                    border.color: parent.modelData.color || Theme.primary
                                    border.width: 2
                                    HoverHandler { id: _kfH }

                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.SizeHorCursor
                                        drag.target: parent
                                        drag.axis:   Drag.XAxis
                                        drag.minimumX: -6
                                        drag.maximumX: root._timeToPx(root.duration) - 6
                                        onReleased: {
                                            var newT = root._pxToTime(parent.x + 6)
                                            newT = Math.max(0, Math.min(root.duration, newT))
                                            root.keyframeMoved(trackIdx, _rq1.index, newT)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onCurrentTimeChanged: _ruler.requestPaint()
    onZoomChanged:        { _ruler.requestPaint(); _grid.requestPaint() }
    onTracksChanged:      _grid.requestPaint()
}
