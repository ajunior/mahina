pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// ListView wrapper that emits loadMore() when the user scrolls near the bottom.
// Show a Spinner footer while loading. Set loading: false once data is appended.
//
// Usage:
//   InfiniteScroll {
//       model:    myModel
//       delegate: MyDelegate { }
//       loading:  vm.isLoading
//       onLoadMore: vm.fetchNextPage()
//   }
Item {
    id: root

    property alias model:        _list.model
    property alias delegate:     _list.delegate
    property alias currentIndex: _list.currentIndex
    property alias spacing:      _list.spacing
    property alias clip:         _list.clip
    property bool  loading:      false
    property real  threshold:    120    // px from bottom that triggers loadMore

    signal loadMore()

    implicitWidth:  400
    implicitHeight: 300

    ListView {
        id:           _list
        anchors.fill: parent
        clip:         true

        QQC.ScrollBar.vertical: QQC.ScrollBar {
            contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
            background:  Rectangle { color: "transparent" }
        }

        footer: Item {
            width:   _list.width
            height:  root.loading ? 52 : 0
            visible: root.loading
            Spinner {
                anchors.centerIn: parent
                size:    20
                visible: root.loading
            }
        }

        onContentYChanged: _checkLoadMore()
        onCountChanged:    _checkLoadMore()

        function _checkLoadMore(): void {
            if (root.loading) return
            if (contentHeight <= height) return
            var distFromBottom = contentHeight - (contentY + height)
            if (distFromBottom < root.threshold) root.loadMore()
        }
    }
}
