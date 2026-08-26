pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// JSON editor with live syntax validation and error display.
//
// Usage:
//   JsonEditor {
//       jsonText: '{"name":"Alice","age":30}'
//       onJsonEdited: (text, isValid) => { if (isValid) applyConfig(text) }
//   }
Item {
    id: root

    property string jsonText:    "{}"
    property bool   valid:       true
    property string parseError:  ""
    property bool   readonly:    false

    signal jsonEdited(string text, bool isValid)

    implicitWidth:  380
    implicitHeight: 260

    function _validate(str) {
        try {
            JSON.parse(str)
            root.valid      = true
            root.parseError = ""
        } catch(e) {
            root.valid      = false
            root.parseError = e.toString().replace("SyntaxError: ", "")
        }
    }

    function _formatJson(str) {
        try {
            return JSON.stringify(JSON.parse(str), null, 2)
        } catch(e) {
            return str
        }
    }

    Component.onCompleted: _validate(root.jsonText)

    Column {
        anchors.fill: parent
        spacing: 0

        // Toolbar
        Rectangle {
            width:  parent.width
            height: 32
            color:  Theme.surfaceVariant
            radius: Theme.radiusMd
            // only round top corners by using an inner rect for bottom
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: parent.radius; color: parent.color
            }
            border.color: root.valid ? Theme.border : Theme.error
            border.width: 1

            Row {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 10 }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "JSON"
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textXs
                    font.weight:    Font.Bold
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: _validBadge.implicitWidth + 12; height: 18; radius: 9
                    color: root.valid ? Qt.rgba(Qt.color(Theme.success).r, Qt.color(Theme.success).g, Qt.color(Theme.success).b, 0.15)
                                      : Qt.rgba(Qt.color(Theme.error).r,   Qt.color(Theme.error).g,   Qt.color(Theme.error).b,   0.15)
                    Text {
                        id:             _validBadge
                        anchors.centerIn: parent
                        text:           root.valid ? "Valid" : "Invalid"
                        color:          root.valid ? Theme.success : Theme.error
                        font.pixelSize: Theme.textXs
                        font.family:    Theme.fontFamily
                        font.weight:    Font.Medium
                    }
                }

                Item { width: 1; height: 1 } // spacer

                // Format button
                Rectangle {
                    visible: !root.readonly
                    anchors.verticalCenter: parent.verticalCenter
                    width: _fmtTxt.implicitWidth + 10; height: 20; radius: 4
                    color: _fmtH.hovered ? Theme.primary : "transparent"
                    border.color: Theme.border; border.width: 1
                    HoverHandler { id: _fmtH }
                    Text {
                        id:             _fmtTxt
                        anchors.centerIn: parent
                        text:           "Format"
                        color:          _fmtH.hovered ? Theme.textOnPrimary : Theme.textSecondary
                        font.pixelSize: Theme.textXs
                        font.family:    Theme.fontFamily
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { _edit.text = root._formatJson(_edit.text) }
                    }
                }
            }
        }

        // Editor area
        Rectangle {
            width:  parent.width
            height: parent.height - 32 - (root.valid ? 0 : 24)
            color:  Theme.surface
            border.color: root.valid ? Theme.border : Theme.error
            border.width: 1
            clip: true

            Flickable {
                anchors.fill:    parent
                anchors.margins: 1
                contentWidth:    _edit.contentWidth + 16
                contentHeight:   _edit.contentHeight + 12
                clip: true

                TextEdit {
                    id:               _edit
                    x: 8; y: 6
                    width:            parent.parent.width - 16
                    text:             root.jsonText
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamilyMono
                    font.pixelSize:   Theme.textSm
                    wrapMode:         TextEdit.Wrap
                    readOnly:         root.readonly
                    selectionColor:   Qt.rgba(Qt.color(Theme.primary).r,
                                              Qt.color(Theme.primary).g,
                                              Qt.color(Theme.primary).b, 0.3)

                    onTextChanged: {
                        root._validate(text)
                        root.jsonEdited(text, root.valid)
                    }
                }
            }
        }

        // Error strip
        Rectangle {
            visible: !root.valid
            width:   parent.width
            height:  24
            color:   Qt.rgba(Qt.color(Theme.error).r, Qt.color(Theme.error).g, Qt.color(Theme.error).b, 0.1)
            border.color: Theme.error; border.width: 1

            Text {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 8 }
                text:           root.parseError
                color:          Theme.error
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textXs
                elide:          Text.ElideRight
            }
        }
    }
}
