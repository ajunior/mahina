pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property string pattern:    ""
    property string testString: ""
    property string flags:      "g"

    implicitWidth:  480
    implicitHeight: 320

    readonly property var _result: {
        if (root.pattern === "") return { matches: [], error: "", count: 0 }
        try {
            var re = new RegExp(root.pattern, root.flags.indexOf("g") >= 0 ? root.flags : root.flags + "g")
            var m
            var matches = []
            var str = root.testString
            re.lastIndex = 0
            var guard = 0
            while ((m = re.exec(str)) !== null && guard < 500) {
                guard++
                matches.push({ start: m.index, end: m.index + m[0].length, text: m[0] })
                if (m[0].length === 0) re.lastIndex++
            }
            return { matches: matches, error: "", count: matches.length }
        } catch(e) {
            return { matches: [], error: e.message, count: 0 }
        }
    }

    // Build highlighted segments from testString + matches
    function _segments() {
        var str  = root.testString
        var mats = root._result.matches
        if (mats.length === 0) return [{ text: str, match: false }]
        var out  = []
        var pos  = 0
        for (var i = 0; i < mats.length; i++) {
            var s = mats[i].start
            var e = mats[i].end
            if (pos < s) out.push({ text: str.slice(pos, s), match: false })
            out.push({ text: str.slice(s, e), match: true })
            pos = e
        }
        if (pos < str.length) out.push({ text: str.slice(pos), match: false })
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

            // Pattern row
            Rectangle {
                width: parent.width; height: 48
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; topMargin: 8; bottomMargin: 8 }
                    spacing: Theme.sp2

                    // Regex delimiters
                    Text { text: "/"; color: Theme.textDisabled; font { family: Theme.fontFamilyMono; pixelSize: Theme.textBase } anchors.verticalCenter: parent.verticalCenter }

                    Rectangle {
                        width:  parent.width - 48 - 20 - Theme.sp2 * 3; height: 32
                        radius: Theme.radiusSm; color: Theme.surface
                        border.color: {
                            if (root._result.error !== "") return Theme.error
                            return _patInput.activeFocus ? Theme.primary : Theme.border
                        }
                        border.width: _patInput.activeFocus ? 2 : 1
                        TextInput {
                            id:    _patInput
                            anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                            verticalAlignment: TextInput.AlignVCenter
                            text:  root.pattern
                            color: root._result.error !== "" ? Theme.error : Theme.textPrimary
                            font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                            selectByMouse: true
                            onTextChanged: root.pattern = text
                            Text {
                                visible: _patInput.text === ""
                                text:    "Enter pattern…"; color: Theme.textDisabled; font: _patInput.font
                            }
                        }
                    }

                    Text { text: "/"; color: Theme.textDisabled; font { family: Theme.fontFamilyMono; pixelSize: Theme.textBase } anchors.verticalCenter: parent.verticalCenter }

                    // Flags
                    Rectangle {
                        width: 48; height: 32; radius: Theme.radiusSm
                        color: Theme.surface; border.color: Theme.border; border.width: 1
                        TextInput {
                            anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                            verticalAlignment: TextInput.AlignVCenter
                            text:  root.flags
                            color: Theme.primary
                            font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                            selectByMouse: true
                            validator: RegularExpressionValidator { regularExpression: /^[gimsuy]*$/ }
                            onTextChanged: root.flags = text
                        }
                    }

                    // Match count badge
                    Rectangle {
                        visible: root._result.error === "" && root.pattern !== ""
                        width:  Math.max(28, _mcTxt.implicitWidth + 8); height: 28
                        radius: Theme.radiusFull; color: Theme.success; anchors.verticalCenter: parent.verticalCenter
                        Text { id: _mcTxt; anchors.centerIn: parent; text: root._result.count.toString(); color: "#ffffff"; font { family: Theme.fontFamily; pixelSize: 12; weight: Font.Bold } }
                    }
                    Rectangle {
                        visible: root._result.error !== ""
                        width:  28; height: 28; radius: Theme.radiusFull; color: Theme.error; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "!"; color: "#ffffff"; font { family: Theme.fontFamily; pixelSize: 13; weight: Font.Bold } }
                    }
                }
            }

            // Error display
            Rectangle {
                visible: root._result.error !== ""
                width: parent.width; height: 28
                color: Qt.rgba(Qt.color(Theme.error).r, Qt.color(Theme.error).g, Qt.color(Theme.error).b, 0.08)
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.error; opacity: 0.3 }
                Text {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    text:  root._result.error
                    color: Theme.error
                    font { family: Theme.fontFamilyMono; pixelSize: 11 }
                }
            }

            // Test string input
            Rectangle {
                width: parent.width; height: 28
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Text {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    text: "Test string"; color: Theme.textSecondary
                    font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                }
            }

            Flickable {
                width:  parent.width
                height: 80
                contentWidth:  width
                contentHeight: Math.max(80, _tsEdit.contentHeight + Theme.sp4)
                clip: true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                TextEdit {
                    id:    _tsEdit
                    width: parent.width
                    padding: Theme.sp3
                    text:  root.testString
                    color: Theme.textPrimary
                    font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    onTextChanged: root.testString = text
                    Text {
                        visible: _tsEdit.text === ""
                        text:  "Enter test string…"; color: Theme.textDisabled; font: _tsEdit.font
                        x: Theme.sp3; y: Theme.sp3
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Result display — highlighted matches
            Rectangle {
                width: parent.width; height: 28
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Text { text: "Matches"; color: Theme.textSecondary; font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                    Text {
                        visible: root._result.count > 0
                        text: root._result.count + " found"
                        color: Theme.success
                        font { family: Theme.fontFamily; pixelSize: 11 }
                    }
                    Text {
                        visible: root._result.count === 0 && root.pattern !== "" && root._result.error === ""
                        text: "no matches"
                        color: Theme.textDisabled
                        font { family: Theme.fontFamily; pixelSize: 11 }
                    }
                }
            }

            Flickable {
                width:  parent.width
                height: root.height - 48 - (root._result.error !== "" ? 28 : 0) - 80 - 1 - 28
                contentWidth:  width
                contentHeight: Math.max(height, _highlightFlow.implicitHeight + Theme.sp4)
                clip: true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                Flow {
                    id:      _highlightFlow
                    width:   parent.width - Theme.sp6
                    x:       Theme.sp3; y: Theme.sp3
                    spacing: 0

                    Repeater {
                        model: root._segments()
                        delegate: Rectangle {
                            id: _rq1
                            required property var modelData
                            width:  _segTxt.implicitWidth
                            height: _segTxt.implicitHeight
                            color:  modelData.match
                                    ? Qt.rgba(Qt.color(Theme.warning).r, Qt.color(Theme.warning).g, Qt.color(Theme.warning).b, 0.25)
                                    : "transparent"
                            radius: modelData.match ? 3 : 0
                            Text {
                                id:   _segTxt
                                text: _rq1.modelData.text
                                color: _rq1.modelData.match ? Theme.warning : Theme.textPrimary
                                font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm; weight: _rq1.modelData.match ? Font.Medium : Font.Normal }
                            }
                        }
                    }
                }
            }
        }
    }
}
