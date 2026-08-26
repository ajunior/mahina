pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// User avatar — image, initials, or icon fallback.
//
// Usage:
//   Avatar { name: "João Ribeiro" }
//   Avatar { source: "https://..."; size: Avatar.Size.Lg }
//   Avatar { name: "Ana Silva"; status: Avatar.Status.Online }
//   Avatar { size: Avatar.Size.Sm; square: true }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Size   { Xs, Sm, Md, Lg, Xl }
    enum Status { None, Online, Away, Busy, Offline }

    property string source: ""          // image URL / path
    property string name:   ""          // used for initials + background color
    property int    size:   Avatar.Size.Md
    property bool   square: false       // pill → rounded square
    property int    status: Avatar.Status.None

    // ── Resolved dimensions ───────────────────────────────────────────────────
    readonly property real _sz: {
        switch (root.size) {
            case Avatar.Size.Xs: return 24
            case Avatar.Size.Sm: return 32
            case Avatar.Size.Lg: return 56
            case Avatar.Size.Xl: return 72
            default:             return 40
        }
    }

    readonly property real _radius: root.square
        ? (root._sz <= 32 ? Theme.radiusSm : Theme.radiusMd)
        : root._sz / 2

    readonly property real _dotSz: Math.round(Math.max(8, root._sz * 0.22))

    // ── Initials ─────────────────────────────────────────────────────────────
    readonly property string _initials: {
        if (root.name === "") return ""
        var parts = root.name.trim().split(/\s+/)
        return parts.length >= 2
            ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
            : root.name[0].toUpperCase()
    }

    // Deterministic background from name — drawn from the Mahina palette
    readonly property color _bgColor: {
        if (root.name === "") return Theme.surfaceVariant
        var palette = [
            "#5B8DF6", "#59A14F", "#F28E2B",
            "#E15759", "#8661C1", "#2196E8",
            "#4E9DA8", "#C46E8D"
        ]
        var hash = 0
        for (var i = 0; i < root.name.length; i++)
            hash = ((hash * 31) + root.name.charCodeAt(i)) >>> 0
        return palette[hash % palette.length]
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  _sz
    implicitHeight: _sz

    // ── Avatar body ───────────────────────────────────────────────────────────
    Rectangle {
        id:     _body
        width:  root._sz
        height: root._sz
        radius: root._radius
        color:  root.source !== "" ? Theme.surfaceVariant : root._bgColor
        clip:   true

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        // Photo
        Image {
            anchors.fill: parent
            source:       root.source
            fillMode:     Image.PreserveAspectCrop
            visible:      root.source !== "" && status === Image.Ready
        }

        // Initials (when no image)
        Text {
            anchors.centerIn: parent
            visible:          root.source === "" && root._initials !== ""
            text:             root._initials
            color:            "#FFFFFF"
            font.family:      Theme.fontFamily
            font.pixelSize:   Math.round(root._sz * 0.36)
            font.weight:      Theme.weightSemibold
        }

        // Generic person icon (when no image and no name)
        Icon {
            anchors.centerIn: parent
            visible:          root.source === "" && root._initials === ""
            name:             Icons.user
            size:             Math.round(root._sz * 0.52)
            color:            Theme.textDisabled
        }
    }

    // ── Status dot ────────────────────────────────────────────────────────────
    Rectangle {
        visible:        root.status !== Avatar.Status.None
        width:          root._dotSz
        height:         root._dotSz
        radius:         root._dotSz / 2
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        color: {
            switch (root.status) {
                case Avatar.Status.Online:  return Theme.success
                case Avatar.Status.Away:    return Theme.warning
                case Avatar.Status.Busy:    return Theme.error
                default:                   return Theme.textDisabled
            }
        }
        // White ring isolates the dot from the avatar edge
        border.color: Theme.surface
        border.width: 2
    }
}
