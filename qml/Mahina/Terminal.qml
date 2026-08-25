import QtQuick
import Mahina

// Command-line-style terminal with scrollback output and command history.
//
// Usage:
//   Terminal {
//       id: term
//       prompt: "glow $ "
//       onCommandEntered: (cmd) => {
//           term.appendLine("Running: " + cmd)
//           term.appendLine("Done.")
//       }
//   }
Item {
    id: root

    property string prompt:      "$ "
    property color  bgColor:     "#0f172a"
    property color  textColor:   "#e2e8f0"
    property color  promptColor: "#22c55e"
    property color  errorColor:  "#f87171"
    property int    historyLimit: 100

    signal commandEntered(string command)

    property var outputLines:    []
    property var cmdHistory:     []
    property int historyIdx:     -1

    function appendLine(text) {
        var lines = root.outputLines.slice()
        lines.push({ text: text, error: false })
        if (lines.length > 500) lines = lines.slice(lines.length - 500)
        root.outputLines = lines
        Qt.callLater(function() { _scroll.positionViewAtEnd() })
    }

    function appendError(text) {
        var lines = root.outputLines.slice()
        lines.push({ text: text, error: true })
        root.outputLines = lines
        Qt.callLater(function() { _scroll.positionViewAtEnd() })
    }

    function clear() {
        root.outputLines = []
    }

    implicitWidth:  480
    implicitHeight: 280

    Rectangle {
        anchors.fill: parent
        color:  root.bgColor
        radius: Theme.radiusMd
        border.color: Theme.border; border.width: 1

        Column {
            anchors.fill: parent

            // Title bar
            Rectangle {
                width:  parent.width
                height: 28
                color:  Qt.rgba(0,0,0,0.3)
                radius: Theme.radiusMd

                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: 6
                    Repeater {
                        model: ["#ff5f57","#febc2e","#28c840"]
                        delegate: Rectangle { required property string modelData; width: 12; height: 12; radius: 6; color: modelData }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Terminal"
                    color: Qt.rgba(1,1,1,0.5)
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                }
            }

            // Output area
            ListView {
                id:    _scroll
                width: parent.width
                height: parent.parent.height - 28 - 36
                clip:   true
                model:  root.outputLines
                spacing: 0

                delegate: Text {
                    required property var modelData
                    required property int index
                    text:           modelData.text
                    color:          modelData.error ? root.errorColor : root.textColor
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                    wrapMode:       Text.WrapAnywhere
                    width:          _scroll.width
                    leftPadding:    Theme.sp3
                    rightPadding:   Theme.sp3
                    topPadding:     index === 0 ? Theme.sp2 : 0
                }
            }

            // Input row
            Rectangle {
                width:  parent.width
                height: 36
                color:  Qt.rgba(0,0,0,0.2)

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                    spacing: Theme.sp2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  root.prompt
                        color: root.promptColor
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textSm
                    }

                    TextInput {
                        id:    _cmdInput
                        width: parent.width - root.prompt.length * 8 - Theme.sp2
                        anchors.verticalCenter: parent.verticalCenter
                        color:          root.textColor
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textSm
                        selectionColor: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.4)

                        Keys.onReturnPressed: {
                            var cmd = text.trim()
                            if (cmd === "") return
                            root.appendLine(root.prompt + cmd)
                            if (cmd === "clear") {
                                root.clear()
                            } else {
                                root.commandEntered(cmd)
                            }
                            root.cmdHistory.unshift(cmd)
                            if (root.cmdHistory.length > root.historyLimit) root.cmdHistory.pop()
                            root.historyIdx = -1
                            text = ""
                        }

                        Keys.onUpPressed: {
                            if (root.cmdHistory.length === 0) return
                            root.historyIdx = Math.min(root.historyIdx + 1, root.cmdHistory.length - 1)
                            text = root.cmdHistory[root.historyIdx]
                            cursorPosition = text.length
                        }

                        Keys.onDownPressed: {
                            if (root.historyIdx <= 0) { root.historyIdx = -1; text = ""; return }
                            root.historyIdx--
                            text = root.cmdHistory[root.historyIdx]
                            cursorPosition = text.length
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:    _cmdInput.forceActiveFocus()
                }
            }
        }
    }

    // Only claim keyboard focus while actually on screen. Taking it
    // unconditionally at construction lets a Terminal sitting on a hidden
    // page of a StackLayout swallow every keystroke in the application.
    onVisibleChanged: if (visible) _cmdInput.forceActiveFocus()

    Component.onCompleted: {
        appendLine("Mahina Terminal  —  type a command and press Enter")
        appendLine('Type "clear" to clear the log.')
        if (visible) _cmdInput.forceActiveFocus()
    }
}
