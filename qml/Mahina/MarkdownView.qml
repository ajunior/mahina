pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Read-only rendered Markdown display. Renders with Qt's native Markdown
// support (headings, lists, tables, links, inline code, fenced blocks),
// wraps to its width and grows to fit its content. Text is selectable and
// links open in the default browser.
//
// Usage:
//   MarkdownView { width: 400; text: "# Hello\n\nSome **bold** text." }
//
// A link whose scheme is not in allowedLinkSchemes is not opened; it raises
// linkBlocked instead, so an application can decide for itself.
//
//   MarkdownView {
//       allowedLinkSchemes: ["https"]
//       onLinkBlocked: (link) => console.warn("refused", link)
//   }
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

    // Schemes handed to the platform opener. A markdown document is not
    // necessarily the user's own -- it can arrive in a file, a paste or a
    // payload -- and Qt passes whatever the link says straight to the desktop
    // handler, which will act on file://, and on every other scheme anything
    // installed has registered for. Only the ones that mean "open in a browser"
    // are safe to forward blindly.
    property var allowedLinkSchemes: ["http", "https", "mailto"]

    // Raised instead of opening, when a link's scheme is not allowed.
    signal linkBlocked(string link)

    function _linkScheme(link: string): string {
        var m = /^([A-Za-z][A-Za-z0-9+.\-]*):/.exec(String(link))
        return m ? m[1].toLowerCase() : ""
    }

    onLinkActivated: (link) => {
        // A relative link has no scheme and nowhere to go: blocked with the rest.
        if (root.allowedLinkSchemes.indexOf(root._linkScheme(link)) !== -1)
            Qt.openUrlExternally(link)
        else
            root.linkBlocked(link)
    }

    HoverHandler {
        enabled:     root.hoveredLink !== ""
        cursorShape: Qt.PointingHandCursor
    }
}
