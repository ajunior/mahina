pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Pure UI media player controls — no actual playback. Wire signals to your backend.
//
// Usage:
//   MediaPlayer {
//       title:    "Blue Ridge Mountains"
//       artist:   "Fleet Foxes"
//       position: audioEngine.position   // 0.0 – 1.0
//       duration: audioEngine.duration   // total seconds
//       playing:  audioEngine.playing
//       volume:   audioEngine.volume     // 0.0 – 1.0
//       onPlayPauseClicked: audioEngine.togglePlay()
//       onSeeked:  (pos) => audioEngine.seek(pos)
//       onVolumeChanged: (v) => audioEngine.setVolume(v)
//   }
Item {
    id: root

    property string title:    ""
    property string artist:   ""
    property string coverUrl: ""    // image URL; if empty, shows icon placeholder
    property bool   playing:  false
    property real   position: 0.0   // 0 – 1
    property real   duration: 0     // total seconds
    property real   volume:   1.0   // 0 – 1
    property bool   shuffle:  false
    property bool   loop:     false

    signal playPauseClicked()
    signal skipBackClicked()
    signal skipForwardClicked()
    signal seeked(real position)
    signal volumeRequested(real volume)
    signal shuffleToggled(bool on)
    signal loopToggled(bool on)

    readonly property string _timeStr: {
        function _fmt(s) {
            var m = Math.floor(s / 60), sec = Math.floor(s % 60)
            return m + ":" + (sec < 10 ? "0" : "") + sec
        }
        return _fmt(root.position * root.duration) + " / " + _fmt(root.duration)
    }

    property bool _seeking:  false
    property real _seekPrev: 0

    implicitWidth:  400
    implicitHeight: 88

    Rectangle {
        anchors.fill:  parent
        color:         Theme.surface
        radius:        Theme.radiusLg
        border.color:  Theme.border
        border.width:  1

        ColumnLayout {
            anchors { fill: parent; margins: Theme.sp3 }
            spacing: Theme.sp2

            // ── Track info + volume ────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.sp3

                // Cover or placeholder
                Rectangle {
                    width: 40; height: 40; radius: Theme.radiusSm
                    color: Theme.surfaceVariant
                    border.color: Theme.border; border.width: 1

                    Image {
                        anchors.fill: parent
                        source:       root.coverUrl; fillMode: Image.PreserveAspectCrop
                        visible:      root.coverUrl !== "" && status === Image.Ready
                    }
                    Icon {
                        anchors.centerIn: parent
                        name:  Icons.playlist; size: 18; color: Theme.textDisabled
                        visible: root.coverUrl === ""
                    }
                }

                // Title + artist
                Column {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        width:          parent.width
                        text:           root.title !== "" ? root.title : "No track"
                        color:          root.title !== "" ? Theme.textPrimary : Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Theme.weightSemibold
                        elide:          Text.ElideRight
                    }
                    Text {
                        width:          parent.width
                        text:           root.artist
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        elide:          Text.ElideRight
                        visible:        root.artist !== ""
                    }
                }

                // Volume
                Row {
                    spacing: Theme.sp1
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: root.volume === 0 ? Icons.speakerX :
                              root.volume < 0.4 ? Icons.speakerNone :
                              root.volume < 0.7 ? Icons.speakerLow : Icons.speakerHigh
                        size: 14; color: Theme.textSecondary
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.volumeRequested(root.volume > 0 ? 0 : 1)
                        }
                    }
                    Rectangle {
                        width: 64; height: 4; radius: 2
                        color: Theme.surfaceVariant
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width:  parent.width * root.volume
                            height: parent.height
                            radius: parent.radius
                            color:  Theme.primary
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => root.volumeRequested(mouse.x / width)
                        }
                    }
                }
            }

            // ── Seek bar ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.sp2

                Text {
                    text:           root._timeStr.split(" / ")[0]
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                }

                Rectangle {
                    id:             _seekBar
                    Layout.fillWidth: true
                    height:         4; radius: 2
                    color:          Theme.surfaceVariant

                    Rectangle {
                        width:  _seekBar.width * root.position
                        height: parent.height; radius: parent.radius
                        color:  Theme.primary
                    }

                    // Thumb
                    Rectangle {
                        x:       _seekBar.width * root.position - 6
                        y:       -4
                        width:   12; height: 12; radius: 6
                        color:   Theme.primary
                        visible: _seekMA.containsMouse || _seekMA.pressed
                    }

                    HoverHandler {}
                    MouseArea {
                        id:           _seekMA
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: (mouse) => root.seeked(mouse.x / _seekBar.width)
                        onPositionChanged: (mouse) => {
                            if (pressed) root.seeked(Math.max(0, Math.min(1, mouse.x / _seekBar.width)))
                        }
                    }
                }

                Text {
                    text:           root._timeStr.split(" / ")[1]
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                }
            }

            // ── Playback controls ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing:          0

                // Shuffle
                Item {
                    width: 32; height: 28
                    Icon {
                        anchors.centerIn: parent
                        name:  Icons.shuffle; size: 16
                        color: root.shuffle ? Theme.primary : Theme.textSecondary
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.shuffleToggled(!root.shuffle)
                    }
                }

                Item { Layout.fillWidth: true }

                // Skip back
                Item {
                    width: 36; height: 28
                    Icon { anchors.centerIn: parent; name: Icons.skipBack; size: 20; color: Theme.textPrimary }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.skipBackClicked()
                    }
                }

                // Play / Pause
                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: _ppH.containsMouse ? Theme.primaryHover : Theme.primary
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _ppH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.playPauseClicked()
                    }
                    Icon {
                        anchors.centerIn: parent
                        name:  root.playing ? Icons.pause : Icons.play
                        size:  18; color: "#ffffff"
                    }
                }

                // Skip forward
                Item {
                    width: 36; height: 28
                    Icon { anchors.centerIn: parent; name: Icons.skipForward; size: 20; color: Theme.textPrimary }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.skipForwardClicked()
                    }
                }

                Item { Layout.fillWidth: true }

                // Loop
                Item {
                    width: 32; height: 28
                    Icon {
                        anchors.centerIn: parent
                        name:  Icons.arrowClockwise; size: 16
                        color: root.loop ? Theme.primary : Theme.textSecondary
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.loopToggled(!root.loop)
                    }
                }
            }
        }
    }
}
