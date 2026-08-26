pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Full-width announcement strip pinned to the top or bottom of its parent,
// or used inline as a tall alert.
//
// Usage (inline):
//   Banner { message: "We've updated our privacy policy." }
//
// Usage (pinned, anchored to window or page root):
//   Banner {
//       anchors { left: parent.left; right: parent.right; top: parent.top }
//       type:    Banner.Type.Warning
//       message: "Scheduled maintenance in 1 hour."
//       actionText: "Learn more"
//       dismissible: true
//       onActionClicked: Qt.openUrlExternally(statusUrl)
//   }
Item {
    id: root

    enum Type { Info, Success, Warning, Error, Announcement }

    property int    type:        Banner.Type.Info
    property string message:     ""
    property string actionText:  ""
    property bool   dismissible: false

    signal dismissed()
    signal actionClicked()

    implicitWidth:  300
    implicitHeight: visible ? _row.implicitHeight + Theme.sp3 * 2 : 0
    visible:        true

    Behavior on implicitHeight { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color _accent: {
        switch (root.type) {
            case Banner.Type.Success:      return Theme.success
            case Banner.Type.Warning:      return Theme.warning
            case Banner.Type.Error:        return Theme.error
            case Banner.Type.Announcement: return "#7c3aed"   // violet
            default:                       return Theme.info
        }
    }
    readonly property color _subtle: {
        switch (root.type) {
            case Banner.Type.Success:      return Theme.successSubtle
            case Banner.Type.Warning:      return Theme.warningSubtle
            case Banner.Type.Error:        return Theme.errorSubtle
            case Banner.Type.Announcement: return "#ede9fe"
            default:                       return Theme.infoSubtle
        }
    }
    readonly property string _icon: {
        switch (root.type) {
            case Banner.Type.Success:      return Icons.checkCircle
            case Banner.Type.Warning:      return Icons.warningCircle
            case Banner.Type.Error:        return Icons.xCircle
            case Banner.Type.Announcement: return Icons.sparkle
            default:                       return Icons.info
        }
    }

    Rectangle {
        anchors.fill:  parent
        color:         root._subtle
        border.color:  root._accent
        border.width:  1
    }

    RowLayout {
        id:      _row
        anchors {
            left:           parent.left
            right:          parent.right
            verticalCenter: parent.verticalCenter
            leftMargin:     Theme.sp4
            rightMargin:    Theme.sp3
        }
        spacing: Theme.sp3

        Icon { name: root._icon; size: 18; color: root._accent }

        Text {
            text:             root.message
            color:            Theme.textPrimary
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.textSm
            wrapMode:         Text.WordWrap
            Layout.fillWidth: true
        }

        // Action link
        Rectangle {
            visible:  root.actionText !== ""
            height:   28; radius: Theme.radiusSm
            width:    _actTxt.implicitWidth + Theme.sp3 * 2
            color:    _actH.hovered ? Qt.rgba(root._accent.r, root._accent.g, root._accent.b, 0.15) : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _actH }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.actionClicked() }
            Text {
                id:             _actTxt
                anchors.centerIn: parent
                text:           root.actionText
                color:          root._accent
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
            }
        }

        // Dismiss button
        Rectangle {
            visible:  root.dismissible
            width: 28; height: 28; radius: Theme.radiusSm
            color: _dH.hovered ? Qt.rgba(root._accent.r, root._accent.g, root._accent.b, 0.15) : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _dH }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.visible = false; root.dismissed() } }
            Icon { anchors.centerIn: parent; name: Icons.x; size: 12; color: root._accent }
        }
    }
}
