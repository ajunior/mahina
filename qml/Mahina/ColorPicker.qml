pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// HSV color picker with hue bar and hex input.
//
// Usage:
//   ColorPicker { label: "Brand color"; color: "#5B8DF6" }
//   ColorPicker { onColorPicked: (c) => Theme.primary = c }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property color  color:      "#5B8DF6"
    property string label:      ""
    property string helper:     ""
    property string errorText:  ""
    property bool   disabled:   false

    readonly property bool hasError: errorText !== ""

    signal colorPicked(color c)

    // ── Internal HSV state ────────────────────────────────────────────────────
    property real _hue:        0.0    // 0–360
    property real _sat:        0.0    // 0–1
    property real _val:        1.0    // 0–1
    property bool _syncing:    false

    // Sync color → HSV on external change
    onColorChanged: {
        if (_syncing) return
        var hsv = _toHsv(root.color)
        _syncing = true
        root._hue = hsv.h
        root._sat = hsv.s
        root._val = hsv.v
        _syncing  = false
    }

    // Sync HSV → color when knobs move
    function _applyHsv(): void {
        if (_syncing) return
        _syncing     = true
        root.color   = Qt.hsva(root._hue / 360, root._sat, root._val, 1.0)
        _hexInput.text = _toHex(root.color)
        root.colorPicked(root.color)
        _syncing     = false
    }

    // ── Colour math helpers ───────────────────────────────────────────────────
    function _toHsv(c: var): var {
        var r = c.r, g = c.g, b = c.b
        var mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn
        var h = 0, s = mx === 0 ? 0 : d / mx, v = mx
        if (d > 0) {
            if      (mx === r) h = 60 * (((g - b) / d) % 6)
            else if (mx === g) h = 60 * ((b - r) / d + 2)
            else               h = 60 * ((r - g) / d + 4)
            if (h < 0) h += 360
        }
        return { h: h, s: s, v: v }
    }

    function _toHex(c: var): var {
        function h(v) { return Math.round(v * 255).toString(16).padStart(2, "0") }
        return "#" + h(c.r) + h(c.g) + h(c.b)
    }

    function _fromHex(hex: var): var {
        hex = hex.replace(/^#/, "")
        if (hex.length !== 6) return null
        var r = parseInt(hex.slice(0,2), 16) / 255
        var g = parseInt(hex.slice(2,4), 16) / 255
        var b = parseInt(hex.slice(4,6), 16) / 255
        if (isNaN(r) || isNaN(g) || isNaN(b)) return null
        return Qt.rgba(r, g, b, 1.0)
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    readonly property real _fieldH: Theme.textBase + Theme.sp2 * 2 + 2

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        // Label
        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          root.hasError ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Trigger ───────────────────────────────────────────────────────────
        Rectangle {
            id:           _trigger
            Layout.fillWidth: true
            height:       root._fieldH
            color:        Theme.surface
            radius:       Theme.radiusSm
            border.color: root.hasError          ? Theme.error
                        : _pop.opened            ? Theme.primary
                        : _trigH.hovered   ? Theme.borderStrong
                        : Theme.border
            border.width: _pop.opened ? 2 : 1
            enabled:      !root.disabled

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _trigH }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                spacing: Theme.sp2

                // Color swatch
                Rectangle {
                    width:   20; height: 20; radius: Theme.radiusSm
                    color:   root.color
                    border.color: Theme.border; border.width: 1
                }

                Text {
                    text:           root._toHex(root.color).toUpperCase()
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                    Layout.fillWidth: true
                }

                Icon { name: Icons.eyedropper; size: 14; color: Theme.textSecondary }
            }

            MouseArea {
                anchors.fill: parent
                enabled:      !root.disabled
                cursorShape:  Qt.PointingHandCursor
                onClicked:    _pop.opened ? _pop.close() : _pop.open()
            }
        }

        // Helper / error
        Text {
            visible:        root.errorText !== "" || root.helper !== ""
            text:           root.errorText !== "" ? root.errorText : root.helper
            color:          root.errorText !== "" ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    // ── Picker popup ──────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _pop
        parent:      _trigger
        y:           _trigger.height + Theme.sp1
        width:       260
        padding:     Theme.sp4
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast  } }

        background: Rectangle {
            color: Theme.surface; radius: Theme.radiusMd
            border.color: Theme.border; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: Theme.sp3

            // ── SV square ─────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                height:           width * 0.6
                clip:             true

                // Base hue
                Rectangle {
                    anchors.fill: parent
                    color: Qt.hsva(root._hue / 360, 1, 1, 1)
                }
                // White overlay (saturation)
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#FFFFFFFF" }
                        GradientStop { position: 1.0; color: "#00FFFFFF" }
                    }
                }
                // Black overlay (value)
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#FF000000" }
                    }
                }

                // Handle
                Rectangle {
                    x: root._sat * parent.width  - width  / 2
                    y: (1 - root._val) * parent.height - height / 2
                    width:        12; height: 12; radius: 6
                    border.color: "white"; border.width: 2; color: "transparent"
                    // Drop shadow
                    Rectangle {
                        anchors.fill:    parent; anchors.margins: -1
                        radius:          parent.radius + 1
                        color:           "transparent"
                        border.color:    "#40000000"; border.width: 1
                        z: -1
                    }
                }

                MouseArea {
                    anchors.fill:  parent
                    onClicked:     (m) => { root._sat = Math.max(0, Math.min(1, m.x / width)); root._val = Math.max(0, Math.min(1, 1 - m.y / height)); root._applyHsv() }
                    onPositionChanged: (m) => { if (pressed) { root._sat = Math.max(0, Math.min(1, m.x / width)); root._val = Math.max(0, Math.min(1, 1 - m.y / height)); root._applyHsv() } }
                }
            }

            // ── Hue bar ───────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                height:           16

                Rectangle {
                    anchors.fill: parent; radius: height / 2
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0/6;  color: "#FF0000" }
                        GradientStop { position: 1/6;  color: "#FFFF00" }
                        GradientStop { position: 2/6;  color: "#00FF00" }
                        GradientStop { position: 3/6;  color: "#00FFFF" }
                        GradientStop { position: 4/6;  color: "#0000FF" }
                        GradientStop { position: 5/6;  color: "#FF00FF" }
                        GradientStop { position: 1.0;  color: "#FF0000" }
                    }
                }

                // Handle
                Rectangle {
                    x: (root._hue / 360) * parent.width - width / 2
                    y: (parent.height - height) / 2
                    width: 10; height: 18; radius: Theme.radiusXs
                    border.color: "white"; border.width: 2; color: "transparent"
                    Rectangle { anchors.fill: parent; anchors.margins: -1; radius: parent.radius + 1; color: "transparent"; border.color: "#40000000"; border.width: 1; z: -1 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:     (m) => { root._hue = Math.max(0, Math.min(360, (m.x / width) * 360)); root._applyHsv() }
                    onPositionChanged: (m) => { if (pressed) { root._hue = Math.max(0, Math.min(360, (m.x / width) * 360)); root._applyHsv() } }
                }
            }

            // ── Preview + hex input ───────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.sp3

                Rectangle {
                    width: 36; height: 36; radius: Theme.radiusMd
                    color: root.color; border.color: Theme.border; border.width: 1
                }

                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: Theme.surface; radius: Theme.radiusSm
                    border.color: _hexInput.activeFocus ? Theme.primary : Theme.border; border.width: _hexInput.activeFocus ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                    RowLayout {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                        spacing: Theme.sp1
                        Text { text: "#"; color: Theme.textDisabled; font.family: Theme.fontFamilyMono; font.pixelSize: Theme.textSm }
                        TextInput {
                            id: _hexInput
                            text: root._toHex(root.color).slice(1).toUpperCase()
                            color: Theme.textPrimary; font.family: Theme.fontFamilyMono; font.pixelSize: Theme.textSm
                            maximumLength: 6; Layout.fillWidth: true
                            validator: RegularExpressionValidator { regularExpression: /^[0-9A-Fa-f]{0,6}$/ }
                            onEditingFinished: {
                                var c = root._fromHex("#" + text.toUpperCase())
                                if (c) { root.color = c; root.colorPicked(c) }
                                else   text = root._toHex(root.color).slice(1).toUpperCase()
                            }
                        }
                    }
                }
            }
        }
    }
}
