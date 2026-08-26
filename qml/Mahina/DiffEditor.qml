pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string leftText:    ""
    property string rightText:   ""
    property string leftLabel:   "Before"
    property string rightLabel:  "After"
    property bool   readOnly:    false
    property bool   syncScroll:  true

    signal leftEdited(string text)
    signal rightEdited(string text)

    implicitWidth:  680
    implicitHeight: 380

    property bool _syncingScroll: false

    function _diffLines(): var {
        var la = root.leftText.split("\n")
        var rb = root.rightText.split("\n")
        var maxLen = Math.max(la.length, rb.length)
        var out = []
        for (var i = 0; i < maxLen; i++) {
            var l = i < la.length ? la[i] : null
            var r = i < rb.length ? rb[i] : null
            var state = "same"
            if (l === null) state = "added"
            else if (r === null) state = "removed"
            else if (l !== r) state = "changed"
            out.push({ left: l, right: r, state: state })
        }
        return out
    }

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Headers
            Row {
                width: parent.width; height: 36
                Rectangle {
                    width: parent.width / 2; height: parent.height
                    color: Theme.panel
                    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                    Row {
                        anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2
                        Rectangle { width: 10; height: 10; radius: 5; color: Theme.error; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: root.leftLabel; color: Theme.textPrimary; font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: Font.Medium } }
                    }
                }
                Rectangle {
                    width: parent.width / 2; height: parent.height
                    color: Theme.panel
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                    Row {
                        anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2
                        Rectangle { width: 10; height: 10; radius: 5; color: Theme.success; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: root.rightLabel; color: Theme.textPrimary; font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: Font.Medium } }
                    }
                }
            }

            // Diff view
            Row {
                width:  parent.width
                height: root.height - 36

                // Left pane
                Flickable {
                    id:           _leftFlick
                    width:        parent.width / 2
                    height:       parent.height
                    contentWidth: Math.max(width, _leftEdit.contentWidth + Theme.sp3)
                    contentHeight: _leftEdit.contentHeight + Theme.sp6
                    clip: true
                    QQC.ScrollBar.vertical:   _leftVSB
                    QQC.ScrollBar.horizontal: QQC.ScrollBar {}

                    onContentYChanged: {
                        if (root.syncScroll && !root._syncingScroll) {
                            root._syncingScroll = true
                            _rightFlick.contentY = contentY
                            root._syncingScroll = false
                        }
                    }

                    TextEdit {
                        id:    _leftEdit
                        width: Math.max(_leftFlick.width, contentWidth + Theme.sp3)
                        padding: Theme.sp3
                        text:   root.leftText
                        color:  Theme.textPrimary
                        font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                        wrapMode:      TextEdit.NoWrap
                        readOnly:      root.readOnly
                        selectByMouse: true
                        onTextChanged: { root.leftText = text; root.leftEdited(text) }
                        Text {
                            visible: _leftEdit.text === ""
                            text:  "Left side…"; color: Theme.textDisabled; font: _leftEdit.font; x: Theme.sp3; y: Theme.sp3
                        }
                    }
                }

                Rectangle { width: 1; height: parent.height; color: Theme.border }

                // Right pane
                Flickable {
                    id:           _rightFlick
                    width:        parent.width / 2 - 1
                    height:       parent.height
                    contentWidth: Math.max(width, _rightEdit.contentWidth + Theme.sp3)
                    contentHeight: _rightEdit.contentHeight + Theme.sp6
                    clip: true
                    QQC.ScrollBar.vertical:   _rightVSB
                    QQC.ScrollBar.horizontal: QQC.ScrollBar {}

                    onContentYChanged: {
                        if (root.syncScroll && !root._syncingScroll) {
                            root._syncingScroll = true
                            _leftFlick.contentY = contentY
                            root._syncingScroll = false
                        }
                    }

                    TextEdit {
                        id:    _rightEdit
                        width: Math.max(_rightFlick.width, contentWidth + Theme.sp3)
                        padding: Theme.sp3
                        text:   root.rightText
                        color:  Theme.textPrimary
                        font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                        wrapMode:      TextEdit.NoWrap
                        readOnly:      root.readOnly
                        selectByMouse: true
                        onTextChanged: { root.rightText = text; root.rightEdited(text) }
                        Text {
                            visible: _rightEdit.text === ""
                            text:  "Right side…"; color: Theme.textDisabled; font: _rightEdit.font; x: Theme.sp3; y: Theme.sp3
                        }
                    }
                }
            }

            QQC.ScrollBar { id: _leftVSB }
            QQC.ScrollBar { id: _rightVSB }
        }
    }
}
