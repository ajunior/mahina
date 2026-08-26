pragma ComponentBehavior: Bound
import QtQuick
import Mahina

Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Color { Default, Primary, Success, Warning, Error, Info }

    property string text:             ""
    property string iconName:         ""
    property int    colorScheme:      Badge.Color.Default
    property bool   pill:             false
    property real   backgroundOpacity: 1.0

    // ── Resolved palette ──────────────────────────────────────────────────────
    readonly property color _bg: {
        switch (colorScheme) {
            case Badge.Color.Primary: return Theme.primarySubtle
            case Badge.Color.Success: return Theme.successSubtle
            case Badge.Color.Warning: return Theme.warningSubtle
            case Badge.Color.Error:   return Theme.errorSubtle
            case Badge.Color.Info:    return Theme.infoSubtle
            default:                  return Theme.surfaceVariant
        }
    }

    readonly property color _fg: {
        switch (colorScheme) {
            case Badge.Color.Primary: return Theme.primaryHover
            case Badge.Color.Success: return Qt.darker(Theme.success, 1.4)
            case Badge.Color.Warning: return Qt.darker(Theme.warning, 1.4)
            case Badge.Color.Error:   return Qt.darker(Theme.error,   1.3)
            case Badge.Color.Info:    return Qt.darker(Theme.info,    1.3)
            default:                  return Theme.textSecondary
        }
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth + Theme.sp3 * 2
    implicitHeight: Theme.textSm + Theme.sp1 * 2

    color:  Qt.rgba(_bg.r, _bg.g, _bg.b, _bg.a * root.backgroundOpacity)
    radius: pill ? Theme.radiusFull : Theme.radiusSm

    Row {
        id: _row
        anchors.centerIn: parent
        spacing: Theme.sp1

        Icon {
            name:    root.iconName
            size:    11
            color:   root._fg
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text:           root.text
            color:          root._fg
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Theme.weightSemibold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
