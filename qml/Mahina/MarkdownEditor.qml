pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Split-pane markdown editor with live preview rendered as styled text.
//
// Usage:
//   MarkdownEditor { initialText: "# Hello\n\nWorld" }
//   MarkdownEditor { showPreview: false }   // editor only
Item {
    id: root

    property string text:        ""
    property bool   showPreview: true
    property bool   showToolbar: true

    signal editingChanged(string t)

    implicitWidth:  640
    implicitHeight: 400

    // The preview is a Text.RichText document, so every character of the source
    // has to be escaped before any markup is wrapped around it. Qt's rich text
    // does not run scripts, but it does fetch remote resources: an unescaped
    // <img src="http://..."> in a document is a tracking beacon that fires on
    // render, and an <a href> is a phishing link wearing whatever text it likes.
    function _escape(s: string): string {
        return String(s)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
    }

    // Minimal markdown → HTML converter for preview.
    // Block prefixes are matched on the raw line -- escaping first would turn
    // "> quote" into "&gt; quote" and the test would miss -- and only the body
    // that survives the prefix is escaped and emitted.
    function _toHtml(md: string): string {
        var lines = String(md).split("\n")
        var out   = []
        for (var i = 0; i < lines.length; i++) {
            var raw = lines[i]
            var l
            if (/^### /.test(raw))      l = "<h3>" + root._escape(raw.substring(4)) + "</h3>"
            else if (/^## /.test(raw))  l = "<h2>" + root._escape(raw.substring(3)) + "</h2>"
            else if (/^# /.test(raw))   l = "<h1>" + root._escape(raw.substring(2)) + "</h1>"
            else if (/^> /.test(raw))   l = "<blockquote>" + root._escape(raw.substring(2)) + "</blockquote>"
            else if (/^- /.test(raw))   l = "<li>" + root._escape(raw.substring(2)) + "</li>"
            else if (raw === "")        l = "<br/>"
            else                        l = "<p>" + root._escape(raw) + "</p>"
            // Inline runs, applied to already-escaped text: the only < and > in
            // the string at this point are the tags emitted just above.
            l = l.replace(/\*\*([^*]+)\*\*/g, "<b>$1</b>")
            l = l.replace(/\*([^*]+)\*/g,   "<i>$1</i>")
            l = l.replace(/`([^`]+)`/g,      "<code>$1</code>")
            out.push(l)
        }
        return out.join("")
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Toolbar
        Rectangle {
            visible: root.showToolbar
            width:   parent.width; height: 36
            color:   Theme.panel
            border.color: Theme.border; border.width: 1

            Row {
                anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                spacing: Theme.sp1

                Repeater {
                    model: [
                        { label: "B",  insert: "**bold**"   },
                        { label: "I",  insert: "*italic*"   },
                        { label: "`",  insert: "`code`"     },
                        { label: "H1", insert: "# "         },
                        { label: "H2", insert: "## "        },
                        { label: "—",  insert: "\n---\n"    },
                    ]
                    delegate: Rectangle {
                        id: _tbBtn
                        required property var modelData
                        width: 28; height: 24; radius: Theme.radiusSm
                        color: _tbHover.hovered ? Theme.hover : "transparent"
                        HoverHandler { id: _tbHover }
                        Text {
                            anchors.centerIn: parent
                            text:           _tbBtn.modelData.label
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamilyMono
                            font.pixelSize: Theme.textXs
                            font.weight:    Theme.weightBold
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                _editor.insert(_editor.cursorPosition, _tbBtn.modelData.insert)
                                _editor.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            // Toggle preview
            Rectangle {
                anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                width: 80; height: 24; radius: Theme.radiusSm
                color: _pvHover.hovered ? Theme.hover : "transparent"
                HoverHandler { id: _pvHover }
                Text {
                    anchors.centerIn: parent
                    text:           root.showPreview ? "Editor" : "Preview"
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
                MouseArea { anchors.fill: parent; onClicked: root.showPreview = !root.showPreview }
            }
        }

        // Panes
        Row {
            width:  parent.width
            height: parent.height - (root.showToolbar ? 36 : 0)

            // Editor pane
            Rectangle {
                width:  root.showPreview ? parent.width / 2 : parent.width
                height: parent.height
                color:  Theme.surface
                border.color: Theme.border; border.width: 1

                QQC.ScrollView {
                    anchors.fill: parent
                    contentWidth: availableWidth

                    TextEdit {
                        id:             _editor
                        width:          parent.width
                        padding:        Theme.sp3
                        text:           root.text
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textSm
                        wrapMode:       TextEdit.Wrap
                        selectByMouse:  true

                        onTextChanged: {
                            root.text = text
                            root.editingChanged(text)
                        }
                    }
                }
            }

            // Preview pane
            Rectangle {
                visible: root.showPreview
                width:   parent.width / 2
                height:  parent.height
                color:   Theme.background
                border.color: Theme.border; border.width: 1

                QQC.ScrollView {
                    anchors.fill: parent
                    contentWidth: availableWidth

                    Text {
                        width:          parent.width
                        padding:        Theme.sp3
                        textFormat:     Text.RichText
                        text:           root._toHtml(root.text)
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        wrapMode:       Text.Wrap
                    }
                }
            }
        }
    }
}
