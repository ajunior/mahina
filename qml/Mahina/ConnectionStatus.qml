import QtQuick
import Mahina

// Network online/offline/reconnecting indicator with pulse animation.
//
// Usage:
//   ConnectionStatus {
//       netStatus:  "reconnecting"   // "online"|"offline"|"reconnecting"
//       showLabel:  true
//   }
Item {
    id: root

    property string netStatus: "online"   // "online"|"offline"|"reconnecting"
    property bool   showLabel: true

    implicitWidth:  showLabel ? _row.implicitWidth : 12
    implicitHeight: 20

    function _color(s) {
        switch (s) {
            case "online":        return Theme.success
            case "reconnecting":  return Theme.warning
            default:              return Theme.error
        }
    }
    function _label(s) {
        switch (s) {
            case "online":        return "Connected"
            case "reconnecting":  return "Reconnecting…"
            default:              return "Offline"
        }
    }

    Row {
        id:      _row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Item {
            width: 12; height: 12
            anchors.verticalCenter: parent.verticalCenter

            // Outer pulse ring (reconnecting only)
            Rectangle {
                id:     _ring
                width:  12; height: 12; radius: 6
                anchors.centerIn: parent
                color:  "transparent"
                border.color: root._color(root.netStatus)
                border.width: 2
                visible: root.netStatus === "reconnecting"

                SequentialAnimation on scale {
                    loops: Animation.Infinite; running: root.netStatus === "reconnecting"
                    NumberAnimation { to: 1.8; duration: 700; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 1.0; duration: 0   }
                }
                SequentialAnimation on opacity {
                    loops: Animation.Infinite; running: root.netStatus === "reconnecting"
                    NumberAnimation { to: 0;   duration: 700 }
                    NumberAnimation { to: 0.7; duration: 0   }
                }
            }

            Rectangle {
                width: 8; height: 8; radius: 4
                anchors.centerIn: parent
                color: root._color(root.netStatus)
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }

        Text {
            visible:        root.showLabel
            anchors.verticalCenter: parent.verticalCenter
            text:           root._label(root.netStatus)
            color:          root._color(root.netStatus)
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Font.Medium
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }
}
