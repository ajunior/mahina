pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Video player UI shell (controls + progress bar).
// Wraps actual playback in a slot; works with any Video/MediaPlayer.
//
// Usage:
//   VideoPlayer {
//       source:   "qrc:/videos/demo.mp4"
//       duration: 240
//       position: 60
//       playing:  true
//       onPlayPauseClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
//       onSeekRequested: (pos) => player.position = pos
//   }
Item {
    id: root

    property string source:   ""
    property real   position: 0        // seconds
    property real   duration: 1        // seconds
    property bool   playing:  false
    property real   volume:   1.0
    property bool   muted:    false
    property bool   showControls: true

    signal playPauseClicked()
    signal seekRequested(real seconds)
    signal volumeAdjusted(real vol)
    signal muteToggled()
    signal fullscreenClicked()

    implicitWidth:  640
    implicitHeight: 360

    Rectangle {
        anchors.fill: parent
        color:        "#000000"
        radius:       Theme.radiusMd
        clip:         true

        // Placeholder when no source
        Text {
            visible:        root.source === ""
            anchors.centerIn: parent
            text:           "▶"
            color:          Theme.textDisabled
            font.pixelSize: 48
        }

        // Controls overlay (shown always; can be hidden via showControls)
        Rectangle {
            visible: root.showControls
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height:  72
            color:   Qt.rgba(0, 0, 0, 0.65)
            radius:  Theme.radiusMd

            Column {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; bottomMargin: Theme.sp2; topMargin: Theme.sp2 }
                spacing: Theme.sp1

                // Progress bar
                Item {
                    width:  parent.width; height: 16

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width:  parent.width; height: 4; radius: 2
                        color:  Qt.rgba(1, 1, 1, 0.25)

                        Rectangle {
                            width:  parent.width * Math.min(1, root.duration > 0 ? root.position / root.duration : 0)
                            height: parent.height; radius: 2
                            color:  Theme.primary
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    (m) => root.seekRequested((m.x / parent.width) * root.duration)
                        cursorShape:  Qt.PointingHandCursor
                    }
                }

                // Controls row
                Row {
                    width: parent.width
                    spacing: Theme.sp2

                    // Play/Pause
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: _ppHover.hovered ? Qt.rgba(1,1,1,0.15) : "transparent"
                        HoverHandler { id: _ppHover }
                        Text {
                            anchors.centerIn: parent
                            text:           root.playing ? "⏸" : "▶"
                            color:          "#ffffff"
                            font.pixelSize: 14
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.playPauseClicked() }
                    }

                    // Time
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            function fmt(s: var): var {
                                var m = Math.floor(s / 60), sec = Math.floor(s % 60)
                                return m + ":" + (sec < 10 ? "0" : "") + sec
                            }
                            return fmt(root.position) + " / " + fmt(root.duration)
                        }
                        color:          "#ffffff"
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textXs
                    }

                    // Volume slider
                    Row {
                        spacing: Theme.sp1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: root.muted || root.volume === 0 ? "🔇" : root.volume < 0.5 ? "🔉" : "🔊"
                            color: "#ffffff"; font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; onClicked: root.muteToggled() }
                        }

                        Rectangle {
                            width: 60; height: 4; radius: 2
                            color: Qt.rgba(1, 1, 1, 0.25)
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                width:  parent.width * root.volume
                                height: parent.height; radius: 2; color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: (m) => root.volumeAdjusted(m.x / parent.width)
                            }
                        }
                    }

                    // Fullscreen
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: _fsHover.hovered ? Qt.rgba(1,1,1,0.15) : "transparent"
                        HoverHandler { id: _fsHover }
                        Text {
                            anchors.centerIn: parent
                            text: "⛶"; color: "#ffffff"; font.pixelSize: 14
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.fullscreenClicked() }
                    }
                }
            }
        }
    }
}
