import QtQuick
import QtQuick.Layouts
import Mahina

// Toast / notification banner.
//
// Usage:
//   Notification {
//       type:    Notification.Type.Success
//       title:   "Changes saved"
//       message: "Your profile was updated successfully."
//       onClosed: destroy()
//   }
Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Type { Info, Success, Warning, Error }

    property int    type:      Notification.Type.Info
    property string title:     ""
    property string message:   ""
    property bool   closeable: true

    signal closed()

    // ── Resolved colors ───────────────────────────────────────────────────────
    readonly property color _accent: {
        switch (root.type) {
            case Notification.Type.Success: return Theme.success
            case Notification.Type.Warning: return Theme.warning
            case Notification.Type.Error:   return Theme.error
            default:                        return Theme.info
        }
    }

    readonly property color _subtle: {
        switch (root.type) {
            case Notification.Type.Success: return Theme.successSubtle
            case Notification.Type.Warning: return Theme.warningSubtle
            case Notification.Type.Error:   return Theme.errorSubtle
            default:                        return Theme.infoSubtle
        }
    }

    readonly property string _icon: {
        switch (root.type) {
            case Notification.Type.Success: return Icons.checkCircle
            case Notification.Type.Warning: return Icons.warning
            case Notification.Type.Error:   return Icons.xCircle
            default:                        return Icons.info
        }
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  360
    implicitHeight: _inner.implicitHeight + Theme.sp4 * 2

    // ── Appearance ────────────────────────────────────────────────────────────
    color:        Theme.surface
    radius:       Theme.radiusMd
    border.color: Theme.border
    border.width: 1

    // Left accent stripe
    Rectangle {
        anchors.left:   parent.left
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 1
        width:          3
        radius:         Theme.radiusMd
        color:          root._accent
    }

    // ── Content ───────────────────────────────────────────────────────────────
    RowLayout {
        id: _inner
        anchors {
            left:        parent.left
            right:       parent.right
            top:         parent.top
            leftMargin:  Theme.sp4 + 6
            rightMargin: Theme.sp4
            topMargin:   Theme.sp4
        }
        spacing: Theme.sp3

        Icon {
            name:  root._icon
            color: root._accent
            size:  18
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 1
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing:          Theme.sp1

            Text {
                text:            root.title
                visible:         root.title !== ""
                color:           Theme.textPrimary
                font.family:     Theme.fontFamily
                font.pixelSize:  Theme.textSm
                font.weight:     Theme.weightSemibold
                wrapMode:        Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text:            root.message
                visible:         root.message !== ""
                color:           Theme.textSecondary
                font.family:     Theme.fontFamily
                font.pixelSize:  Theme.textSm
                wrapMode:        Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // Close button
        Item {
            width:   24
            height:  24
            visible: root.closeable
            Layout.alignment: Qt.AlignTop

            Rectangle {
                anchors.fill: parent
                radius:       Theme.radiusSm
                color:        _closeMouse.containsMouse ? Theme.border : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text:             "×"
                color:            Theme.textDisabled
                font.pixelSize:   17
                font.weight:      Theme.weightRegular
            }

            MouseArea {
                id:           _closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.closed()
            }
        }
    }
}
