import QtQuick
import QtQuick.Layouts
import Mahina

// Compact interactive label — use for filters, tags, and input tokens.
//
// Usage:
//   // Filter chip (togglable)
//   Chip { text: "TypeScript"; selected: true; onClicked: selected = !selected }
//
//   // Removable input chip
//   Chip { text: "anna@example.com"; removable: true; onRemoved: model.remove(index) }
//
//   // Static colored tag
//   Chip { text: "Design"; colorScheme: Chip.Color.Primary }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Color { Default, Primary, Success, Warning, Error, Info }

    property string text:        ""
    property string iconName:    ""       // leading icon glyph
    property int    colorScheme: Chip.Color.Default
    property bool   selected:    false
    property bool   removable:   false    // shows trailing × button
    property bool   interactive: true     // shows pointer cursor + hover states

    signal clicked()
    signal removed()

    // ── Palette lookup ────────────────────────────────────────────────────────
    readonly property color _fg: {
        if (root.selected) return Theme.primary
        switch (root.colorScheme) {
            case Chip.Color.Primary: return Theme.primary
            case Chip.Color.Success: return Theme.success
            case Chip.Color.Warning: return Theme.warning
            case Chip.Color.Error:   return Theme.error
            case Chip.Color.Info:    return Theme.info
            default:                 return Theme.textSecondary
        }
    }

    readonly property color _bg: {
        if (root.selected) return Theme.primarySubtle
        switch (root.colorScheme) {
            case Chip.Color.Primary: return Theme.primarySubtle
            case Chip.Color.Success: return Theme.successSubtle
            case Chip.Color.Warning: return Theme.warningSubtle
            case Chip.Color.Error:   return Theme.errorSubtle
            case Chip.Color.Info:    return Theme.infoSubtle
            default:                 return _hover.containsMouse && root.interactive
                                            ? Theme.panel : Theme.surfaceVariant
        }
    }

    readonly property color _border: {
        if (root.selected) return Theme.primary
        switch (root.colorScheme) {
            case Chip.Color.Primary: return Qt.rgba(Theme.primary.r,  Theme.primary.g,  Theme.primary.b,  0.35)
            case Chip.Color.Success: return Qt.rgba(Theme.success.r,  Theme.success.g,  Theme.success.b,  0.35)
            case Chip.Color.Warning: return Qt.rgba(Theme.warning.r,  Theme.warning.g,  Theme.warning.b,  0.35)
            case Chip.Color.Error:   return Qt.rgba(Theme.error.r,    Theme.error.g,    Theme.error.b,    0.35)
            case Chip.Color.Info:    return Qt.rgba(Theme.info.r,     Theme.info.g,     Theme.info.b,     0.35)
            default:                 return Theme.border
        }
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth  + Theme.sp3 * 2
    implicitHeight: 28

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       height / 2
        color:        root._bg
        border.color: root._border
        border.width: 1

        Behavior on color        { ColorAnimation { duration: Theme.durationFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
    }

    HoverHandler { id: _hover; enabled: root.interactive || root.removable }

    // ── Content ───────────────────────────────────────────────────────────────
    RowLayout {
        id:                  _row
        anchors.centerIn:    parent
        spacing:             Theme.sp2

        Icon {
            name:    root.iconName
            size:    12
            color:   root._fg
            visible: root.iconName !== ""
        }

        Text {
            text:           root.text
            color:          root._fg
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    root.selected ? Theme.weightSemibold : Theme.weightMedium

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }

        // Remove button
        Item {
            visible:        root.removable
            implicitWidth:  14
            implicitHeight: 14

            Rectangle {
                anchors.fill: parent
                radius:       width / 2
                color:        _removeHover.containsMouse
                              ? Qt.rgba(root._fg.r, root._fg.g, root._fg.b, 0.15)
                              : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text:             "×"
                color:            root._fg
                font.pixelSize:   12
                font.weight:      Theme.weightRegular
            }

            MouseArea {
                id:           _removeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    (e) => { e.accepted = true; root.removed() }
            }
        }
    }

    // ── Click handler ─────────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        enabled:      root.interactive
        cursorShape:  Qt.PointingHandCursor
        // Stop at the remove button — its MouseArea handles its own click
        propagateComposedEvents: false
        onClicked:    root.clicked()
    }
}
