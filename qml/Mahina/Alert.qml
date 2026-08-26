pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Inline static alert banner. For ephemeral toasts use Toaster instead.
//
// Usage:
//   Alert { message: "Your session expires in 5 minutes." }
//   Alert { type: Alert.Type.Success; title: "Saved!"; message: "Changes were applied." }
//   Alert { type: Alert.Type.Error;   message: "Upload failed."; dismissible: true }
Item {
    id: root

    enum Type { Info, Success, Warning, Error }

    property int    type:        Alert.Type.Info
    property string title:       ""
    property string message:     ""
    property bool   dismissible: false
    property string icon:        ""    // override default icon

    signal dismissed()

    implicitWidth:  300
    implicitHeight: visible ? _row.implicitHeight + Theme.sp3 * 2 : 0
    visible:        true

    Behavior on implicitHeight { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color _accent: {
        switch (root.type) {
            case Alert.Type.Success: return Theme.success
            case Alert.Type.Warning: return Theme.warning
            case Alert.Type.Error:   return Theme.error
            default:                 return Theme.info
        }
    }
    readonly property color _subtle: {
        switch (root.type) {
            case Alert.Type.Success: return Theme.successSubtle
            case Alert.Type.Warning: return Theme.warningSubtle
            case Alert.Type.Error:   return Theme.errorSubtle
            default:                 return Theme.infoSubtle
        }
    }
    readonly property string _icon: {
        if (root.icon !== "") return root.icon
        switch (root.type) {
            case Alert.Type.Success: return Icons.checkCircle
            case Alert.Type.Warning: return Icons.warningCircle
            case Alert.Type.Error:   return Icons.xCircle
            default:                 return Icons.info
        }
    }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        root._subtle
        radius:       0
        border.color: root._accent
        border.width: 1
        opacity:      root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
    }

    // Left stripe
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width:  3
        color:  root._accent
        visible: root.visible
    }

    RowLayout {
        id:      _row
        anchors {
            left:           parent.left
            right:          parent.right
            verticalCenter: parent.verticalCenter
            leftMargin:     Theme.sp3 + 3
            rightMargin:    Theme.sp3
        }
        spacing: Theme.sp3

        Icon { name: root._icon; size: 18; color: root._accent }

        ColumnLayout {
            Layout.fillWidth: true
            spacing:          Theme.sp1

            Text {
                visible:          root.title !== ""
                text:             root.title
                color:            Theme.textPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                font.weight:      Theme.weightSemibold
                Layout.fillWidth: true
            }

            Text {
                visible:          root.message !== ""
                text:             root.message
                color:            Theme.textSecondary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                wrapMode:         Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Rectangle {
            visible:  root.dismissible
            width:    24; height: 24; radius: Theme.radiusSm
            color:    _dxHov.hovered ? Qt.rgba(root._accent.r, root._accent.g, root._accent.b, 0.15) : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _dxHov }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: { root.visible = false; root.dismissed() }
            }
            Icon { anchors.centerIn: parent; name: Icons.x; size: 12; color: root._accent }
        }
    }
}
