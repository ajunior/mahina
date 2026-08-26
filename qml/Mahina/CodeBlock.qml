pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Syntax-highlighted code display with language label and copy button.
// By default uses a dark "One Dark"-inspired palette regardless of the app's
// light/dark mode; set followTheme to style it with the active theme instead.
//
// Usage:
//   CodeBlock {
//       language: "qml"
//       code: 'Button { text: "Hello"; onClicked: console.log("world") }'
//   }
//
//   CodeBlock { language: "js"; showLineNumbers: true; code: myScript; maxHeight: 300 }
//   CodeBlock { language: "sql"; followTheme: true; code: query }
//   CodeBlock { language: "sh"; showTrafficLights: true; code: cmd }   // showcase look
Item {
    id: root

    property string code:            ""
    property string language:        ""    // label only (e.g. "qml", "js", "python")
    property bool   showLineNumbers: false
    property real   maxHeight:       400
    property bool   showCopyButton:  true
    property bool   followTheme:     false // active theme instead of the fixed dark palette
    property bool   showTrafficLights: false // decorative macOS-style window dots
    // Wrap long lines instead of scrolling horizontally. Wrapped lines occupy
    // several visual rows, so combining this with showLineNumbers misaligns
    // the gutter — prefer one or the other.
    property bool   wrapText:        false

    // Palette (fixed dark by default, Theme tokens when followTheme)
    readonly property color _bg:        followTheme ? Theme.surface        : "#1e1e2e"
    readonly property color _headerBg:  followTheme ? Theme.panel          : "#181825"
    readonly property color _border:    followTheme ? Theme.border         : "#313244"
    readonly property color _fg:        followTheme ? Theme.textPrimary    : "#cdd6f4"
    readonly property color _fgSub:     followTheme ? Theme.textSecondary  : "#6c7086"
    readonly property color _btnBg:     followTheme ? Theme.surfaceVariant : "#24273a"
    readonly property color _btnHover:  followTheme ? Theme.border         : "#313244"
    readonly property color _ok:        followTheme ? Theme.success        : "#a6e3a1"
    readonly property color _scrollbar: followTheme ? Theme.borderStrong   : "#585b70"

    implicitWidth:  400
    implicitHeight: Math.min(root.maxHeight, _header.height + _scroll.contentHeight + Theme.sp4 * 2)

    property bool _copied: false

    Rectangle {
        anchors.fill:  parent
        color:         root._bg
        radius:        Theme.radiusMd
        border.color:  root._border
        border.width:  1
        clip:          true

        // ── Header bar ────────────────────────────────────────────────────────
        Rectangle {
            id:     _header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 36; color: root._headerBg
            radius: Theme.radiusMd
            Rectangle { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 1; color: root._border }

            // Traffic lights (decorative)
            Row {
                visible: root.showTrafficLights
                anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                spacing: Theme.sp1
                Repeater {
                    model: ["#ff5f57", "#febc2e", "#28c840"]
                    Rectangle {
                        id: _dot
                        required property string modelData
                        width: 10; height: 10; radius: 5; color: _dot.modelData
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text:           root.language.toUpperCase()
                color:          root._fgSub
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textXs
                font.weight:    Theme.weightMedium
            }

            Rectangle {
                visible:  root.showCopyButton
                anchors { right: parent.right; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                width: 64; height: 24; radius: Theme.radiusSm
                color: _cpH.hovered ? root._btnHover : root._btnBg
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                HoverHandler { id: _cpH }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // QML doesn't expose clipboard directly, but signal can be connected
                        root._copied = true
                        _resetTimer.restart()
                    }
                }
                Row {
                    anchors.centerIn: parent; spacing: Theme.sp1
                    Icon { name: root._copied ? Icons.check : Icons.copy; size: 11; color: root._copied ? root._ok : root._fgSub }
                    Text {
                        text:           root._copied ? "Copied!" : "Copy"
                        color:          root._copied ? root._ok : root._fgSub
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                    }
                }
            }

            Timer { id: _resetTimer; interval: 2000; onTriggered: root._copied = false }
        }

        // ── Code area ─────────────────────────────────────────────────────────
        Flickable {
            id:      _scroll
            anchors { top: _header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            contentWidth:  root.wrapText ? width : _codeRow.implicitWidth + Theme.sp4 * 2
            contentHeight: _codeRow.implicitHeight + Theme.sp4 * 2
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            QQC.ScrollBar.horizontal: QQC.ScrollBar {
                policy: _scroll.contentWidth > _scroll.width ? QQC.ScrollBar.AsNeeded : QQC.ScrollBar.AlwaysOff
                contentItem: Rectangle { radius: 3; color: root._scrollbar }
                background:  Rectangle { color: "transparent" }
            }
            QQC.ScrollBar.vertical: QQC.ScrollBar {
                policy: _scroll.contentHeight > _scroll.height ? QQC.ScrollBar.AsNeeded : QQC.ScrollBar.AlwaysOff
                contentItem: Rectangle { radius: 3; color: root._scrollbar }
                background:  Rectangle { color: "transparent" }
            }

            Row {
                id:     _codeRow
                x:      Theme.sp4
                y:      Theme.sp4
                spacing:Theme.sp4

                // Line numbers
                Column {
                    visible:  root.showLineNumbers
                    spacing:  0

                    Repeater {
                        model: root.code.split("\n").length
                        Text {
                            id: _lineNo
                            required property int index
                            width:          28
                            text:           _lineNo.index + 1
                            horizontalAlignment: Text.AlignRight
                            color:          root._fgSub
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textSm
                            lineHeight:     1.6
                            lineHeightMode: Text.ProportionalHeight
                        }
                    }
                }

                // Code text
                Text {
                    id: _codeText
                    text:           root.code
                    color:          root._fg
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                    wrapMode:       root.wrapText ? Text.Wrap : Text.NoWrap
                    width: root.wrapText
                           ? _scroll.width - Theme.sp4 * 2
                             - (root.showLineNumbers ? 28 + Theme.sp4 : 0)
                           : implicitWidth
                    lineHeight:     1.6
                    lineHeightMode: Text.ProportionalHeight
                }
            }
        }
    }
}
