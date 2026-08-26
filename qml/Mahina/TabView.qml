import QtQuick
import Mahina

// A tab header wired to a set of panels, only one of which is visible.
//
// Prefer Tabs for new code: it is the same header over a StackLayout and takes
// its pages as plain children. TabView is for the case where the panels are
// already held in a list and selected by index.
//
// Usage:
//   TabView {
//       tabs: ["Overview", "Analytics", "Settings"]
//       Overview {}       // panels in declaration order, one per tab
//       Analytics {}
//       SettingsPage {}
//   }
//
// OR with the panels supplied as a list:
//   TabView {
//       tabs:   ["One", "Two"]
//       panels: [oneItem, twoItem]
//   }
Item {
    id: root

    property var tabs:         []
    property var panels:       []   // optional explicit panel list
    property int currentIndex: 0

    // Named 'content' rather than 'children': a 'children' alias shadows the
    // one every Item already has, which breaks anything reading root.children.
    default property alias content: _declared.data

    implicitWidth:  400
    implicitHeight: 300

    Column {
        anchors.fill: parent
        spacing: 0

        Tabs {
            id:     _tabs
            width:  parent.width
            model:  root.tabs
            onTabChanged: (i) => root.currentIndex = i
        }

        Item {
            width:  parent.width
            height: parent.height - _tabs.height

            // Panels given as a list.
            Repeater {
                model: root.panels
                delegate: Item {
                    required property var modelData
                    required property int index
                    anchors.fill: parent
                    visible:      index === root.currentIndex
                    children:     [modelData]
                }
            }

            // Panels given as children. Their visibility is bound here rather
            // than declared, because the panels are written by the caller.
            Item {
                id: _declared
                anchors.fill: parent

                onChildrenChanged:    _declared.bindPanels()
                Component.onCompleted: _declared.bindPanels()

                function bindPanels() {
                    for (let i = 0; i < children.length; ++i) {
                        // 'let' per iteration: a 'var' would leave every panel
                        // reading the loop's final value.
                        let panel = children[i], at = i
                        panel.anchors.fill = _declared   // a panel is the whole area
                        panel.visible = Qt.binding(() => at === root.currentIndex)
                    }
                }
            }
        }
    }

    // Tabs writes its own currentIndex when a header is clicked, which would
    // destroy a plain binding after the first click; Binding re-applies it.
    Binding {
        target:      _tabs
        property:    "currentIndex"
        value:       root.currentIndex
        restoreMode: Binding.RestoreNone
    }
}
