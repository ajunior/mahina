pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Zero-data placeholder — icon, title, description, and optional CTA.
//
// Usage:
//   EmptyState {
//       icon:        Icons.ghost
//       title:       "No results"
//       description: "Try a different search term or clear your filters."
//       action:      "Clear filters"
//       onActionClicked: clearFilters()
//   }
//
//   EmptyState {
//       icon:   Icons.folderOpen
//       title:  "No files yet"
//       action: "Upload file"
//       onActionClicked: openFilePicker()
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string icon:        Icons.ghost
    property string title:       "Nothing here yet"
    property string description: ""
    property string action:      ""
    property int    iconSize:    48

    signal actionClicked()

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  280
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp3

        Icon {
            name:              root.icon
            size:              root.iconSize
            color:             Theme.textDisabled
            Layout.alignment:  Qt.AlignHCenter
        }

        Text {
            text:              root.title
            color:             Theme.textPrimary
            font.family:       Theme.fontFamily
            font.pixelSize:    Theme.textLg
            font.weight:       Theme.weightSemibold
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth:  true
        }

        Text {
            visible:           root.description !== ""
            text:              root.description
            color:             Theme.textSecondary
            font.family:       Theme.fontFamily
            font.pixelSize:    Theme.textSm
            wrapMode:          Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth:  true
        }

        Button {
            visible:          root.action !== ""
            text:             root.action
            Layout.alignment: Qt.AlignHCenter
            onClicked:        root.actionClicked()
        }
    }
}
