import QtQuick
import QtQuick.Layouts
import Mahina

// A generic list row with hover highlight, title/subtitle on the left,
// and a trailing slot for badges and action buttons on the right.
//
// Usage:
//   ListRow {
//       title:    "production-db"
//       subtitle: "postgres@db.example.com:5432"
//
//       Badge   { text: "Key";    colorScheme: Badge.Color.Primary }
//       Button  { iconOnly: true; iconName: Icons.pencilSimple; variant: Button.Variant.Ghost }
//       Button  { iconOnly: true; iconName: Icons.trash;        variant: Button.Variant.Ghost }
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title:    ""
    property string subtitle: ""

    signal clicked()

    readonly property alias hovered: _hover.hovered

    default property alias actions: _trailing.data

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  400
    implicitHeight: _inner.implicitHeight + 8

    // ── Hover background ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusSm
        color:        Theme.border
        opacity:      _hover.hovered ? 0.5 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
    }

    HoverHandler { id: _hover; cursorShape: Qt.PointingHandCursor }
    TapHandler   { onTapped: root.clicked() }

    // ── Content ───────────────────────────────────────────────────────────────
    RowLayout {
        id: _inner
        anchors {
            left:   parent.left;  right:  parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 6;  rightMargin: 6
        }
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text:           root.title
                visible:        root.title !== ""
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text:           root.subtitle
                visible:        root.subtitle !== ""
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Row {
            id:                  _trailing
            spacing:             4
            Layout.alignment:    Qt.AlignVCenter
        }
    }
}
