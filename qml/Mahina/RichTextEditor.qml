pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Toolbar + TextEdit with bold/italic/underline/lists formatting.
//
// Usage:
//   RichTextEditor { width: 600; height: 300 }
//   RichTextEditor { html: "<b>Hello</b> world" }
Item {
    id: root

    property string html:   ""
    property bool   readOnly: false

    signal contentChanged(string h)

    implicitWidth:  480
    implicitHeight: 300

    Column {
        anchors.fill: parent
        spacing: 0

        // Toolbar
        Rectangle {
            width:  parent.width; height: 36
            color:  Theme.panel
            border.color: Theme.border; border.width: 1

            Row {
                anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                spacing: 2

                Repeater {
                    model: [
                        { icon: "B",    cmd: "bold",              tip: "Bold (Ctrl+B)"        },
                        { icon: "I",    cmd: "italic",            tip: "Italic (Ctrl+I)"      },
                        { icon: "U",    cmd: "underline",         tip: "Underline (Ctrl+U)"   },
                        { icon: "S",    cmd: "strikethrough",     tip: "Strikethrough"        },
                        { icon: "•",    cmd: "insertUnorderedList",tip: "Bullet list"         },
                        { icon: "1.",   cmd: "insertOrderedList",  tip: "Numbered list"       },
                        { icon: "‹›",   cmd: "code",              tip: "Inline code"          },
                    ]
                    delegate: Rectangle {
                        id: _rq1
                        required property var modelData
                        width: 28; height: 26; radius: Theme.radiusSm
                        color: _tbH.containsMouse ? Theme.surfaceVariant : "transparent"
                        HoverHandler { id: _tbH }

                        Text {
                            anchors.centerIn: parent
                            text:           _rq1.modelData.icon
                            color:          Theme.textPrimary
                            font.family:    _rq1.modelData.cmd === "italic" ? "serif" : Theme.fontFamilyMono
                            font.pixelSize: Theme.textXs
                            font.bold:      _rq1.modelData.cmd === "bold"
                            font.italic:    _rq1.modelData.cmd === "italic"
                            font.underline: _rq1.modelData.cmd === "underline"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                _edit.forceActiveFocus()
                                if (_rq1.modelData.cmd === "bold")        _edit.font.bold      = !_edit.font.bold
                                else if (_rq1.modelData.cmd === "italic") _edit.font.italic    = !_edit.font.italic
                                else if (_rq1.modelData.cmd === "underline") _edit.font.underline = !_edit.font.underline
                            }
                        }
                    }
                }

                Rectangle { width: 1; height: 20; color: Theme.border; anchors.verticalCenter: parent.verticalCenter }

                // Font size
                Row {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: [
                            { label: "H1", size: 22 },
                            { label: "H2", size: 18 },
                            { label: "H3", size: 14 },
                        ]
                        delegate: Rectangle {
                            id: _rq2
                            required property var modelData
                            width: 26; height: 26; radius: Theme.radiusSm
                            color: _hH.containsMouse ? Theme.surfaceVariant : "transparent"
                            HoverHandler { id: _hH }
                            Text {
                                anchors.centerIn: parent
                                text: _rq2.modelData.label
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight: Theme.weightBold
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    _edit.forceActiveFocus()
                                    _edit.font.pixelSize = _rq2.modelData.size
                                }
                            }
                        }
                    }
                }
            }
        }

        // Editor
        Rectangle {
            width:  parent.width
            height: parent.height - 36
            color:  Theme.surface
            border.color: Theme.border; border.width: 1

            QQC.ScrollView {
                anchors.fill: parent
                contentWidth: availableWidth

                TextEdit {
                    id:             _edit
                    width:          parent.width
                    padding:        Theme.sp4
                    text:           root.html
                    textFormat:     TextEdit.RichText
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    wrapMode:       TextEdit.Wrap
                    selectByMouse:  true
                    readOnly:       root.readOnly

                    onTextChanged: {
                        root.html = text
                        root.contentChanged(text)
                    }
                }
            }
        }
    }
}
