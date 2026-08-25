import QtQuick
import Mahina

// Read-only rendered Markdown display. Renders with Qt's native Markdown
// support (headings, lists, tables, links, inline code, fenced blocks),
// wraps to its width and grows to fit its content. Text is selectable and
// links open in the default browser.
//
// Usage:
//   MarkdownView { width: 400; text: "# Hello\n\nSome **bold** text." }
TextEdit {
    id: root

    readOnly:          true
    textFormat:        TextEdit.MarkdownText
    wrapMode:          TextEdit.Wrap
    selectByMouse:     true

    color:             Theme.textPrimary
    selectionColor:    Theme.primary
    selectedTextColor: Theme.textOnPrimary
    font.family:       Theme.fontFamily
    font.pixelSize:    Theme.textSm

    onLinkActivated: (link) => Qt.openUrlExternally(link)

    HoverHandler {
        enabled:     root.hoveredLink !== ""
        cursorShape: Qt.PointingHandCursor
    }
}
