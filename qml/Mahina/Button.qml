import QtQuick
import QtQuick.Controls.Basic
import Mahina

AbstractButton {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Variant { Filled, Outlined, Ghost, Danger }
    enum Size    { Sm, Md, Lg }

    property int variant: Button.Variant.Filled
    property int size:    Button.Size.Md
    property string iconName:   ""
    property int    iconWeight: Icon.Weight.Regular
    property bool   loading:    false
    property bool   iconOnly:   false

    // ── Sizing ───────────────────────────────────────────────────────────────
    readonly property real _hPad: size === Button.Size.Sm ? Theme.sp3
                                : size === Button.Size.Lg ? Theme.sp6
                                : Theme.sp4

    readonly property real _vPad: size === Button.Size.Sm ? Theme.sp1 + 2
                                : size === Button.Size.Lg ? Theme.sp3
                                : Theme.sp2

    readonly property real _fontSize: size === Button.Size.Sm ? Theme.textSm
                                    : size === Button.Size.Lg ? Theme.textLg
                                    : Theme.textBase

    readonly property real _iconSize: size === Button.Size.Sm ? 14
                                    : size === Button.Size.Lg ? 20
                                    : 16

    readonly property real _radius: Theme.radiusSm

    // ── Resolved colors ───────────────────────────────────────────────────────
    readonly property color _bg: {
        if (!enabled)              return Theme.surfaceVariant
        if (variant === Button.Variant.Filled) {
            if (pressed)           return Theme.primaryActive
            if (hovered)           return Theme.primaryHover
            return Theme.primary
        }
        if (variant === Button.Variant.Danger) {
            if (pressed)           return Qt.darker(Theme.error, 1.15)
            if (hovered)           return Qt.darker(Theme.error, 1.07)
            return Theme.error
        }
        if (pressed)               return Theme.primarySubtle
        if (hovered)               return Theme.primarySubtle
        return Qt.rgba(Theme.primarySubtle.r, Theme.primarySubtle.g, Theme.primarySubtle.b, 0)
    }

    readonly property color _fg: {
        if (!enabled)                              return Theme.textDisabled
        if (variant === Button.Variant.Filled)     return Theme.textOnPrimary
        if (variant === Button.Variant.Danger)     return Theme.textOnPrimary
        if (hovered || pressed)                    return Theme.primary
        return variant === Button.Variant.Outlined ? Theme.primary : Theme.textPrimary
    }

    readonly property color _border: {
        if (!enabled)                              return Theme.border
        if (variant === Button.Variant.Outlined)   return hovered ? Theme.primaryHover : Theme.primary
        return "transparent"
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  iconOnly ? implicitHeight : _row.implicitWidth + _hPad * 2
    implicitHeight: Math.max(_iconSize, _fontSize) + _vPad * 2

    focusPolicy: Qt.TabFocus
    enabled: !loading

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    // ── Background ────────────────────────────────────────────────────────────
    background: Rectangle {
        color:        root._bg
        radius:       root._radius
        border.color: root._border
        border.width: root.variant === Button.Variant.Outlined ? 1 : 0

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    // ── Focus ring ────────────────────────────────────────────────────────────
    Rectangle {
        visible:      root.activeFocus
        anchors.fill: parent
        anchors.margins: -3
        radius:       root._radius + 3
        color:        "transparent"
        border.color: Theme.primary
        border.width: 2
        opacity:      0.6
    }

    // ── Content ───────────────────────────────────────────────────────────────
    // Wrapper Item lets AbstractButton resize it to the full button area while
    // the inner Row centers itself freely without conflicting with C++ layout.
    contentItem: Item {
        Row {
            id: _row
            anchors.centerIn: parent
            spacing: root.iconName !== "" && root.text !== "" ? Theme.sp2 : 0

            Icon {
                id: _icon
                name:    root.loading ? Icons.spinner : root.iconName
                weight:  root.iconWeight
                size:    root._iconSize
                color:   root._fg
                visible: root.iconName !== "" || root.loading
                anchors.verticalCenter: parent.verticalCenter

                RotationAnimator on rotation {
                    running: root.loading
                    from: 0; to: 360
                    duration: 800
                    loops: Animation.Infinite
                }
            }

            Text {
                id: _label
                text:              root.text
                visible:           root.text !== "" && !root.iconOnly
                color:             root._fg
                font.family:       Theme.fontFamily
                font.pixelSize:    root._fontSize
                font.weight:       Theme.weightMedium
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }
        }
    }
}
