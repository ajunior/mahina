pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Renders a Phosphor icon glyph.
//
// Usage:
//   Icon { name: Icons.gear }
//   Icon { name: Icons.heart; weight: Icon.Weight.Fill; color: "red" }
//   Icon { name: Icons.sun;   weight: Icon.Weight.Duotone; size: 32 }
//
// Duotone renders two overlapping glyphs: background at secondaryColor/20%
// opacity, foreground at full color. Both layers use "Phosphor-Duotone".
Item {
    id: root

    enum Weight { Thin, Light, Regular, Bold, Fill, Duotone }

    property string name:           ""
    property real   size:           20
    property color  color:          Theme.textPrimary
    property color  secondaryColor: root.color
    property int    weight:         Icon.Weight.Regular

    implicitWidth:  size
    implicitHeight: size

    readonly property string _family: {
        switch (root.weight) {
            case Icon.Weight.Thin:    return "Phosphor-Thin"
            case Icon.Weight.Light:   return "Phosphor-Light"
            case Icon.Weight.Bold:    return "Phosphor-Bold"
            case Icon.Weight.Fill:    return "Phosphor-Fill"
            case Icon.Weight.Duotone: return "Phosphor-Duotone"
            default:                  return "Phosphor"
        }
    }

    // Duotone foreground glyph sits one codepoint above the base glyph.
    readonly property string _fgGlyph: root.name.length > 0
        ? String.fromCodePoint(root.name.codePointAt(0) + 1) : ""

    // ── Background / single-weight glyph ─────────────────────────────────────
    Text {
        anchors.fill:        parent
        text:                root.name
        font.family:         root._family
        font.pixelSize:      root.size
        color:               root.weight === Icon.Weight.Duotone ? root.secondaryColor : root.color
        opacity:             root.weight === Icon.Weight.Duotone ? 0.2 : 1.0
        lineHeight:          1
        verticalAlignment:   Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    // ── Duotone foreground glyph ──────────────────────────────────────────────
    Text {
        visible:             root.weight === Icon.Weight.Duotone
        anchors.fill:        parent
        text:                root._fgGlyph
        font.family:         root._family
        font.pixelSize:      root.size
        color:               root.color
        lineHeight:          1
        verticalAlignment:   Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
