pragma Singleton
import QtQuick

QtObject {
    id: root

    // ── Color mode ────────────────────────────────────────────────────────────
    property bool dark: false

    // ── Primary ───────────────────────────────────────────────────────────────
    property color primary:       "#5B8DF6"
    property color primaryHover:  "#4878E8"
    property color primaryActive: "#3A66D0"
    property color primarySubtle: "#EEF3FD"

    // ── Semantic ──────────────────────────────────────────────────────────────
    property color success:       "#59A14F"
    property color warning:       "#F28E2B"
    property color error:         "#E15759"
    property color info:          "#2196E8"

    property color successSubtle: "#EEF8ED"
    property color warningSubtle: "#FEF4E7"
    property color errorSubtle:   "#FEF0F0"
    property color infoSubtle:    "#EFF7FE"

    property color textOnPrimary: "#FFFFFF"

    // ── Mode-aware backing properties ─────────────────────────────────────────
    // These are the only writable part of the light/dark system.
    // Public tokens below are computed from these and react to dark changes.
    property color _backgroundLight:     "#EDEEF6"
    property color _backgroundDark:      "#151922"
    property color _panelLight:          "#F4F4FA"
    property color _panelDark:           "#171D27"
    property color _surfaceLight:        "#FFFFFF"
    property color _surfaceDark:         "#1E2430"
    property color _surfaceVariantLight: "#F8F8FD"
    property color _surfaceVariantDark:  "#222A36"
    property color _overlayLight:        "#1E203066"
    property color _overlayDark:         "#00000099"
    property color _borderLight:         "#E2E5F0"
    property color _borderDark:          "#313B4C"
    property color _borderStrongLight:   "#C8CEDF"
    property color _borderStrongDark:    "#475569"
    property color _textPrimaryLight:    "#1E2030"
    property color _textPrimaryDark:     "#F4F7FB"
    property color _textSecondaryLight:  "#697180"
    property color _textSecondaryDark:   "#AAB4C4"
    property color _textDisabledLight:   "#9AA3AF"
    property color _textDisabledDark:    "#7F8A9A"
    property color _shadowColorLight:    "#1E2030"
    property color _shadowColorDark:     "#000000"

    // ── Public surface tokens (readonly — computed from backing pairs) ─────────
    readonly property color background:     dark ? _backgroundDark     : _backgroundLight
    readonly property color panel:          dark ? _panelDark          : _panelLight
    readonly property color surface:        dark ? _surfaceDark        : _surfaceLight
    readonly property color surfaceVariant: dark ? _surfaceVariantDark : _surfaceVariantLight
    readonly property color overlay:        dark ? _overlayDark        : _overlayLight
    readonly property color border:         dark ? _borderDark         : _borderLight
    readonly property color borderStrong:   dark ? _borderStrongDark   : _borderStrongLight
    readonly property color textPrimary:    dark ? _textPrimaryDark    : _textPrimaryLight
    readonly property color textSecondary:  dark ? _textSecondaryDark  : _textSecondaryLight
    readonly property color textDisabled:   dark ? _textDisabledDark   : _textDisabledLight
    readonly property color shadowColor:    dark ? _shadowColorDark    : _shadowColorLight

    // ── Spacing (4 px base grid) ──────────────────────────────────────────────
    readonly property real sp1:  4
    readonly property real sp2:  8
    readonly property real sp3:  12
    readonly property real sp4:  16
    readonly property real sp5:  20
    readonly property real sp6:  24
    readonly property real sp8:  32
    readonly property real sp10: 40
    readonly property real sp12: 48
    readonly property real sp16: 64

    // ── Border radius ─────────────────────────────────────────────────────────
    readonly property real radiusXs:   2
    readonly property real radiusSm:   4
    readonly property real radiusMd:   8
    readonly property real radiusLg:   12
    readonly property real radiusXl:   16
    readonly property real radiusFull: 9999

    // ── Typography ────────────────────────────────────────────────────────────
    property string fontFamily:     "Inter Variable"
    property string fontFamilyMono: "JetBrains Mono"

    readonly property real textXs:   11
    readonly property real textSm:   13
    readonly property real textBase: 15
    readonly property real textLg:   17
    readonly property real textXl:   20
    readonly property real text2xl:  24
    readonly property real text3xl:  30
    readonly property real text4xl:  36

    readonly property int weightLight:    300
    readonly property int weightRegular:  400
    readonly property int weightMedium:   500
    readonly property int weightSemibold: 600
    readonly property int weightBold:     700

    readonly property real lineHeightTight:   1.25
    readonly property real lineHeightNormal:  1.5
    readonly property real lineHeightRelaxed: 1.75

    // ── Animation ─────────────────────────────────────────────────────────────
    readonly property int durationFast:   80
    readonly property int durationNormal: 150
    readonly property int durationSlow:   250
    readonly property int easing:         Easing.OutCubic

    // ── Elevation ─────────────────────────────────────────────────────────────
    readonly property real shadowSmBlur:    6
    readonly property real shadowSmYOffset: 1
    readonly property real shadowSmOpacity: 0.06

    readonly property real shadowMdBlur:    16
    readonly property real shadowMdYOffset: 4
    readonly property real shadowMdOpacity: 0.10

    readonly property real shadowLgBlur:    32
    readonly property real shadowLgYOffset: 8
    readonly property real shadowLgOpacity: 0.14

    // ── Theme API ─────────────────────────────────────────────────────────────

    // Load a partial or full color schema. Only the keys you provide are changed;
    // everything else keeps its current value. Mode-dependent tokens are nested
    // under "light" and "dark" keys. All fields are optional.
    //
    // Theme.load({
    //     primary: "#7c3aed",
    //     light: { background: "#f8fafc", textPrimary: "#0f172a" },
    //     dark:  { background: "#0f172a", textPrimary: "#f8fafc" }
    // })
    function load(obj) {
        if (obj.primary       !== undefined) root.primary       = obj.primary
        if (obj.primaryHover  !== undefined) root.primaryHover  = obj.primaryHover
        if (obj.primaryActive !== undefined) root.primaryActive = obj.primaryActive
        if (obj.primarySubtle !== undefined) root.primarySubtle = obj.primarySubtle
        if (obj.success       !== undefined) root.success       = obj.success
        if (obj.warning       !== undefined) root.warning       = obj.warning
        if (obj.error         !== undefined) root.error         = obj.error
        if (obj.info          !== undefined) root.info          = obj.info
        if (obj.successSubtle !== undefined) root.successSubtle = obj.successSubtle
        if (obj.warningSubtle !== undefined) root.warningSubtle = obj.warningSubtle
        if (obj.errorSubtle   !== undefined) root.errorSubtle   = obj.errorSubtle
        if (obj.infoSubtle    !== undefined) root.infoSubtle    = obj.infoSubtle
        if (obj.textOnPrimary  !== undefined) root.textOnPrimary  = obj.textOnPrimary
        if (obj.fontFamily     !== undefined) root.fontFamily     = obj.fontFamily
        if (obj.fontFamilyMono !== undefined) root.fontFamilyMono = obj.fontFamilyMono

        const l = obj.light || {}
        if (l.background     !== undefined) root._backgroundLight     = l.background
        if (l.panel          !== undefined) root._panelLight          = l.panel
        if (l.surface        !== undefined) root._surfaceLight        = l.surface
        if (l.surfaceVariant !== undefined) root._surfaceVariantLight = l.surfaceVariant
        if (l.overlay        !== undefined) root._overlayLight        = l.overlay
        if (l.border         !== undefined) root._borderLight         = l.border
        if (l.borderStrong   !== undefined) root._borderStrongLight   = l.borderStrong
        if (l.textPrimary    !== undefined) root._textPrimaryLight    = l.textPrimary
        if (l.textSecondary  !== undefined) root._textSecondaryLight  = l.textSecondary
        if (l.textDisabled   !== undefined) root._textDisabledLight   = l.textDisabled
        if (l.shadowColor    !== undefined) root._shadowColorLight    = l.shadowColor

        const d = obj.dark || {}
        if (d.background     !== undefined) root._backgroundDark     = d.background
        if (d.panel          !== undefined) root._panelDark          = d.panel
        if (d.surface        !== undefined) root._surfaceDark        = d.surface
        if (d.surfaceVariant !== undefined) root._surfaceVariantDark = d.surfaceVariant
        if (d.overlay        !== undefined) root._overlayDark        = d.overlay
        if (d.border         !== undefined) root._borderDark         = d.border
        if (d.borderStrong   !== undefined) root._borderStrongDark   = d.borderStrong
        if (d.textPrimary    !== undefined) root._textPrimaryDark    = d.textPrimary
        if (d.textSecondary  !== undefined) root._textSecondaryDark  = d.textSecondary
        if (d.textDisabled   !== undefined) root._textDisabledDark   = d.textDisabled
        if (d.shadowColor    !== undefined) root._shadowColorDark    = d.shadowColor
    }

    // Restore Mahina's built-in defaults.
    function reset() {
        root.primary       = "#5B8DF6"
        root.primaryHover  = "#4878E8"
        root.primaryActive = "#3A66D0"
        root.primarySubtle = "#EEF3FD"
        root.success       = "#59A14F"
        root.warning       = "#F28E2B"
        root.error         = "#E15759"
        root.info          = "#2196E8"
        root.successSubtle = "#EEF8ED"
        root.warningSubtle = "#FEF4E7"
        root.errorSubtle   = "#FEF0F0"
        root.infoSubtle    = "#EFF7FE"
        root.textOnPrimary  = "#FFFFFF"
        root.fontFamily     = "Inter Variable"
        root.fontFamilyMono = "JetBrains Mono"

        root._backgroundLight     = "#EDEEF6"
        root._backgroundDark      = "#151922"
        root._panelLight          = "#F4F4FA"
        root._panelDark           = "#171D27"
        root._surfaceLight        = "#FFFFFF"
        root._surfaceDark         = "#1E2430"
        root._surfaceVariantLight = "#F8F8FD"
        root._surfaceVariantDark  = "#222A36"
        root._overlayLight        = "#1E203066"
        root._overlayDark         = "#00000099"
        root._borderLight         = "#E2E5F0"
        root._borderDark          = "#313B4C"
        root._borderStrongLight   = "#C8CEDF"
        root._borderStrongDark    = "#475569"
        root._textPrimaryLight    = "#1E2030"
        root._textPrimaryDark     = "#F4F7FB"
        root._textSecondaryLight  = "#697180"
        root._textSecondaryDark   = "#AAB4C4"
        root._textDisabledLight   = "#9AA3AF"
        root._textDisabledDark    = "#7F8A9A"
        root._shadowColorLight    = "#1E2030"
        root._shadowColorDark     = "#000000"
    }
}
