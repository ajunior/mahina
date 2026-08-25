import QtQuick
import Mahina

// Settings page with a left section-nav and a scrollable content panel.
//
// Usage:
//   PreferencesLayout {
//       prefSections: [
//           { id: "general",  label: "General",     icon: "⚙" },
//           { id: "editor",   label: "Editor",       icon: "✏" },
//           { id: "privacy",  label: "Privacy",      icon: "🔒" },
//       ]
//       currentSection: "general"
//       onSectionSelected: (id) => loadSection(id)
//       // Put section content as default children
//       Text { text: "General settings content here" }
//   }
Item {
    id: root

    property var    prefSections:   []
    property string currentSection: ""
    property int    navWidth:       200

    signal sectionSelected(string sectionId)

    default property alias content: _contentArea.data

    implicitWidth:  600
    implicitHeight: 400

    // ── Left nav ──────────────────────────────────────────────────────
    Rectangle {
        id:    _nav
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width:  root.navWidth
        color:  Theme.surfaceVariant

        Rectangle {
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 1; color: Theme.border
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: Theme.sp3 }
            spacing: 2

            Repeater {
                model: root.prefSections
                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    required property int  index

                    readonly property bool isActive: root.currentSection === (modelData.id || "")

                    anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                    height: 36; radius: Theme.radiusMd
                    color: isActive ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                              Qt.color(Theme.primary).b, 0.12)
                                    : (_pvH.hovered ? Theme.panel : "transparent")
                    Behavior on color { ColorAnimation { duration: 80 } }
                    HoverHandler { id: _pvH }

                    Row {
                        anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        spacing: Theme.sp2

                        Text {
                            visible: (_rq1.modelData.icon || "") !== ""
                            text:           _rq1.modelData.icon || ""
                            font.pixelSize: 14
                        }

                        Text {
                            text:           _rq1.modelData.label || ""
                            color:          isActive ? Theme.primary : Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    isActive ? Font.Medium : Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentSection = _rq1.modelData.id || ""
                            root.sectionSelected(_rq1.modelData.id || "")
                        }
                    }
                }
            }
        }
    }

    // ── Content area ──────────────────────────────────────────────────
    ScrollArea {
        anchors { left: _nav.right; right: parent.right; top: parent.top; bottom: parent.bottom }
        clip: true

        Item {
            id:    _contentArea
            width: parent.width
            implicitHeight: childrenRect.height + Theme.sp6 * 2
        }
    }
}
