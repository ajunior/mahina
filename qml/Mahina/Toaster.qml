pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Auto-dismissing toast notification stack.
//
// Place once as a child of your root Window (or full-screen Item), then call
// show() from anywhere in the UI.
//
// Usage:
//   // In Window root:
//   Toaster { id: toaster; anchors.fill: parent }
//
//   // Anywhere:
//   toaster.show("File saved!")
//   toaster.show("Upload failed", Toaster.Type.Error)
//   toaster.show("Warning: low disk space", Toaster.Type.Warning, 6000)
//   toaster.show("SELECT * FROM users", Toaster.Type.Info, 5000, true)
//   //                                                            ^^^^ shows copy button
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Type { Info, Success, Warning, Error }

    property int maxVisible: 5

    function show(message: var, type: var, duration: var, copyable: var): void {
        if (_model.count >= root.maxVisible) _model.remove(0)
        _model.append({
            toastId:   ++_nextId,
            message:   message   ?? "",
            toastType: type      ?? Toaster.Type.Info,
            duration:  duration  ?? 3500,
            copyable:  copyable  ?? false
        })
    }

    function copyToClipboard(text: var): void {
        _clipHelper.text = text
        _clipHelper.selectAll()
        _clipHelper.copy()
    }

    function _remove(id: var): var {
        for (var i = 0; i < _model.count; i++) {
            if (_model.get(i).toastId === id) { _model.remove(i); return }
        }
    }

    // ── Internal ─────────────────────────────────────────────────────────────
    property int _nextId: 0
    anchors.fill: parent
    z:            9000

    // Hidden TextEdit used as clipboard helper
    TextEdit { id: _clipHelper; visible: false; text: "" }

    ListModel { id: _model }

    // ── Toast stack ───────────────────────────────────────────────────────────
    Column {
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin:     Theme.sp6
        spacing:                  Theme.sp2
        width:                    Math.min(420, root.width - Theme.sp8 * 2)

        Repeater {
            model: _model

            delegate: Rectangle {
                id:      _toast

                // ComponentBehavior: Bound — roles arrive as required properties.
                required property int    toastId
                required property string message
                required property int    toastType
                required property int    duration
                required property bool   copyable

                width:   parent.width
                height:  _tRow.implicitHeight + Theme.sp3 * 2
                radius:  0
                color:   Theme.surface
                border.color: Theme.border
                border.width: 1
                opacity: 0

                property bool _copied: false

                // ── Palette ───────────────────────────────────────────────────
                readonly property color _accent: {
                    switch (_toast.toastType) {
                        case Toaster.Type.Success: return Theme.success
                        case Toaster.Type.Warning: return Theme.warning
                        case Toaster.Type.Error:   return Theme.error
                        default:                   return Theme.info
                    }
                }
                readonly property color _subtle: {
                    switch (_toast.toastType) {
                        case Toaster.Type.Success: return Theme.successSubtle
                        case Toaster.Type.Warning: return Theme.warningSubtle
                        case Toaster.Type.Error:   return Theme.errorSubtle
                        default:                   return Theme.infoSubtle
                    }
                }
                readonly property string _icon: {
                    switch (_toast.toastType) {
                        case Toaster.Type.Success: return Icons.checkCircle
                        case Toaster.Type.Warning: return Icons.warningCircle
                        case Toaster.Type.Error:   return Icons.xCircle
                        default:                   return Icons.info
                    }
                }

                // Left accent stripe
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: 3
                    color: _toast._accent
                }

                RowLayout {
                    id:      _tRow
                    anchors {
                        left:           parent.left
                        right:          parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin:     Theme.sp3 + 3   // +3 for accent stripe
                        rightMargin:    Theme.sp3
                    }
                    spacing: Theme.sp3

                    // Icon bubble
                    Rectangle {
                        width:  32; height: 32; radius: 16
                        color:  _toast._subtle

                        Icon {
                            anchors.centerIn: parent
                            name:  _toast._icon
                            size:  16
                            color: _toast._accent
                        }
                    }

                    Text {
                        text:             _toast.message
                        color:            Theme.textPrimary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textSm
                        wrapMode:         Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Copy button
                    Rectangle {
                        visible: _toast.copyable
                        width:  24; height: 24; radius: Theme.radiusSm
                        color:  _copyHov.containsMouse ? Theme.border : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                        Icon {
                            anchors.centerIn: parent
                            name:  _toast._copied ? Icons.check : Icons.copy
                            size:  14
                            color: _toast._copied ? Theme.success : Theme.textSecondary

                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        HoverHandler { id: _copyHov }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                _clipHelper.text = _toast.message
                                _clipHelper.selectAll()
                                _clipHelper.copy()
                                _toast._copied = true
                                _resetTimer.restart()
                            }
                        }

                        Timer {
                            id:       _resetTimer
                            interval: 1500
                            onTriggered: _toast._copied = false
                        }
                    }

                    // Dismiss button
                    Rectangle {
                        width:  24; height: 24; radius: Theme.radiusSm
                        color:  _xHov.containsMouse ? Theme.border : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                        Text { anchors.centerIn: parent; text: "×"; color: Theme.textSecondary; font.pixelSize: 16 }
                        HoverHandler { id: _xHov }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: _exitAnim.start()
                        }
                    }
                }

                // ── Auto-dismiss timer (inside delegate — uses duration role) ──
                Timer {
                    interval: _toast.duration
                    running:  true
                    onTriggered: _exitAnim.start()
                }

                // ── Animations ────────────────────────────────────────────────
                Component.onCompleted: _enterAnim.start()

                NumberAnimation {
                    id: _enterAnim; target: _toast; property: "opacity"
                    from: 0; to: 1; duration: Theme.durationNormal; easing.type: Easing.OutCubic
                }

                SequentialAnimation {
                    id: _exitAnim
                    NumberAnimation { target: _toast; property: "opacity"; to: 0; duration: Theme.durationNormal; easing.type: Easing.InCubic }
                    onFinished: root._remove(_toast.toastId)
                }
            }
        }
    }
}
