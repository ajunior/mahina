pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Save/sync state indicator cycling through saved → syncing → error → modified.
//
// Usage:
//   SyncStatus {
//       syncState:    "syncing"       // "saved"|"syncing"|"error"|"modified"
//       errorMessage: "Network error"
//   }
Item {
    id: root

    property string syncState:    "saved"
    property string errorMessage: ""

    implicitWidth:  _syncRow.implicitWidth
    implicitHeight: 24

    function _icon(s: var): var {
        switch (s) {
            case "saved":    return "✓"
            case "syncing":  return "↻"
            case "error":    return "⚠"
            case "modified": return "●"
            default:         return "○"
        }
    }
    function _label(s: var): var {
        switch (s) {
            case "saved":    return "Saved"
            case "syncing":  return "Saving…"
            case "error":    return root.errorMessage !== "" ? root.errorMessage : "Save failed"
            case "modified": return "Unsaved changes"
            default:         return s
        }
    }
    function _color(s: var): var {
        switch (s) {
            case "saved":    return Theme.success
            case "syncing":  return Theme.primary
            case "error":    return Theme.error
            case "modified": return Theme.warning
            default:         return Theme.textDisabled
        }
    }

    Row {
        id:      _syncRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Text {
            id:             _syncIcon
            anchors.verticalCenter: parent.verticalCenter
            text:           root._icon(root.syncState)
            color:          root._color(root.syncState)
            font.pixelSize: Theme.textSm
            font.weight:    Font.Bold
            Behavior on color { ColorAnimation { duration: 200 } }

            // Spin animation when syncing
            NumberAnimation on rotation {
                from:     0; to: 360; duration: 1000
                loops:    Animation.Infinite
                running:  root.syncState === "syncing"
            }
            // Reset rotation when done
            onRotationChanged: { if (root.syncState !== "syncing") rotation = 0 }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:           root._label(root.syncState)
            color:          root._color(root.syncState)
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
