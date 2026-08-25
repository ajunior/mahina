import QtQuick
import Mahina

// Tabs + content panels wired together as one convenience component.
//
// Usage:
//   TabView {
//       tabs: ["Overview", "Analytics", "Settings"]
//       Overview  { TabView.index: 0 }
//       Analytics { TabView.index: 1 }
//       SettingsPage { TabView.index: 2 }
//   }
//
// OR with inline content via the 'panels' property:
//   TabView {
//       tabs: ["One", "Two"]
//       panels: [oneItem, twoItem]
//   }
Item {
    id: root

    property var    tabs:         []
    property var    panels:       []   // optional explicit panel list
    property int    currentIndex: 0

    default property alias children: _stack.children

    implicitWidth:  400
    implicitHeight: 300

    Column {
        anchors.fill: parent
        spacing: 0

        Tabs {
            id:      _tabs
            width:   parent.width
            model:   root.tabs
            current: root.currentIndex
            onTabSelected: (i) => root.currentIndex = i
        }

        Item {
            id:     _stack
            width:  parent.width
            height: parent.height - _tabs.height

            // Show panels from the panels property list
            Repeater {
                model: root.panels
                delegate: Item {
                    required property var  modelData
                    required property int  index
                    anchors.fill: parent
                    visible:      index === root.currentIndex
                    children:     [modelData]
                }
            }

            // Children with TabView.index attached property
            Component.onCompleted: {
                for (var i = 0; i < children.length; i++) {
                    var child = children[i]
                    if (child.hasOwnProperty("_tabIndex")) {
                        child.visible = Qt.binding(function() { return child._tabIndex === root.currentIndex })
                    }
                }
            }
        }
    }
}
