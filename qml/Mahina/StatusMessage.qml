import QtQuick
import Mahina

// System / bot message in a chat thread — centered, subdued styling.
//
// Usage:
//   StatusMessage {
//       body:       "Alice started a thread"
//       time:       "2:14 PM"
//       statusType: "system"   // "system"|"info"|"success"|"error"
//   }
Item {
    id: root

    property string body:       ""
    property string time:       ""
    property string icon:       ""
    property string statusType: "system"  // "system"|"info"|"success"|"error"

    implicitWidth:  400
    implicitHeight: _row.implicitHeight + 8

    function _iconFor(t) {
        if (root.icon !== "") return root.icon
        switch (t) {
            case "success": return "✓"
            case "error":   return "✕"
            case "info":    return "ℹ"
            default:        return "•"
        }
    }
    function _colorFor(t) {
        switch (t) {
            case "success": return Theme.success
            case "error":   return Theme.error
            case "info":    return Theme.primary
            default:        return Theme.textDisabled
        }
    }

    // Horizontal rule lines + centered content
    Row {
        id:     _row
        width:  parent.width
        height: 20
        anchors.verticalCenter: parent.verticalCenter

        Rectangle { width: (_row.width - _center.implicitWidth - 16) / 2; height: 1; anchors.verticalCenter: parent.verticalCenter; color: Theme.border }
        Item { width: 8; height: 1 }

        Row {
            id:      _center
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root._iconFor(root.statusType)
                color:          root._colorFor(root.statusType)
                font.pixelSize: 10
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.body
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }

            Text {
                visible:        root.time !== ""
                anchors.verticalCenter: parent.verticalCenter
                text:           "·  " + root.time
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }

        Item { width: 8; height: 1 }
        Rectangle { width: (_row.width - _center.implicitWidth - 16) / 2; height: 1; anchors.verticalCenter: parent.verticalCenter; color: Theme.border }
    }
}
