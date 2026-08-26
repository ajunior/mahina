pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// App launch screen with logo, progress bar, and fade-out. Covers its parent.
//
// Usage:
//   SplashScreen {
//       anchors.fill: parent
//       title:    "MyApp"
//       version:  "2.1.0"
//       progress: _loader.progress      // 0..1; auto-hides at 1.0
//       onDismissed: splashLoader.active = false
//   }
Item {
    id: root

    property string title:       "Mahina"
    property string subtitle:    "UI Component Library"
    property string version:     "1.0.0"
    property string logo:        ""     // Icon glyph, optional
    property real   progress:    0      // 0..1
    property int    fadeDuration: 400

    signal dismissed()

    z:       1000
    visible: opacity > 0.005

    Behavior on opacity { NumberAnimation { id: _fadeAnim; duration: root.fadeDuration; easing.type: Easing.InQuad } }

    onOpacityChanged: { if (opacity <= 0.005) root.dismissed() }

    onProgressChanged: {
        if (root.progress >= 1.0) {
            root.opacity = 0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        Column {
            anchors.centerIn: parent
            spacing: Theme.sp5

            // Logo circle
            Rectangle {
                width:  64; height: 64; radius: Theme.radiusXl
                color:  Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text:  root.logo !== "" ? root.logo
                         : root.title.length > 0 ? root.title.charAt(0).toUpperCase() : "G"
                    color: Theme.textOnPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: root.logo !== "" ? 32 : 28
                    font.weight:    Theme.weightBold
                }
            }

            // Title
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.title
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.text2xl
                font.weight:    Theme.weightBold
            }

            // Subtitle
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible:        root.subtitle !== ""
                text:           root.subtitle
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textBase
            }

            // Progress bar
            Item {
                width:  240; height: 4
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    anchors.fill: parent; radius: 2; color: Theme.panel
                }
                Rectangle {
                    width:  parent.width * root.progress; height: parent.height
                    radius: 2; color: Theme.primary
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }

            // Version
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible:        root.version !== ""
                text:           "v" + root.version
                color:          Theme.textDisabled
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textXs
            }
        }
    }
}
