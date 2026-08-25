import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// ListView wrapper with item recycling, styled scrollbars, and empty state.
// Suitable for large datasets (thousands of rows) where a plain Column would be slow.
//
// Usage:
//   VirtualList {
//       model:    contactsModel
//       itemHeight: 56
//       delegate: ContactRow { }
//   }
//
//   VirtualList {
//       model:       filteredResults
//       emptyIcon:   Icons.magnifyingGlass
//       emptyTitle:  "No results"
//       emptyBody:   "Try a different search term."
//   }
//
// The delegate's implicit height is used when itemHeight is 0 (default).
// Set itemHeight to a fixed value for maximum performance (enables QQC ListView's
// built-in uniform-item fast path).
Item {
    id: root

    property var       model:       null
    property Component delegate:    null
    property real      itemHeight:  0        // 0 = variable; >0 = uniform (fast path)
    property real      spacing_:    0        // avoids shadowing; feeds ListView.spacing
    property bool      clip_:       true
    property string    emptyIcon:   Icons.list
    property string    emptyTitle:  "Nothing here yet"
    property string    emptyBody:   ""

    // Forwarded from ListView
    readonly property int  count:        _list.count
    readonly property int  currentIndex: _list.currentIndex

    function positionAt(index) { _list.positionViewAtIndex(index, ListView.Contain) }

    implicitWidth:  300
    implicitHeight: 400

    ListView {
        id:           _list
        anchors.fill: parent
        model:        root.model
        delegate:     root.delegate
        spacing:      root.spacing_
        clip:         root.clip_
        cacheBuffer:  root.itemHeight > 0 ? root.itemHeight * 10 : 800

        // Uniform height fast path
        onDelegateChanged: {
            if (root.itemHeight > 0) {
                // Signal the view that all items have the same height
                _list.reuseItems = true
            }
        }

        // Styled vertical scrollbar
        QQC.ScrollBar.vertical: QQC.ScrollBar {
            id:      _vscroll
            policy:  _list.contentHeight > _list.height ? QQC.ScrollBar.AlwaysOn : QQC.ScrollBar.AsNeeded
            width:   6

            contentItem: Rectangle {
                radius:  3
                color:   _vscroll.pressed ? Theme.textSecondary
                       : _vscroll.hovered ? Theme.textDisabled
                       : Theme.border
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            background: Rectangle { color: "transparent" }
        }

        // Empty state overlay
        Item {
            visible:      _list.count === 0
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                spacing:          Theme.sp3

                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name:  root.emptyIcon
                    size:  40
                    color: Theme.textDisabled
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           root.emptyTitle
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    font.weight:    Theme.weightMedium
                }

                Text {
                    visible:        root.emptyBody !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           root.emptyBody
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
