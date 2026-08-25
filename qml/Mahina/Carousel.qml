import QtQuick
import QtQuick.Layouts
import Mahina

// Swipeable content slider with arrow navigation and dot indicators.
//
// Usage (model-based):
//   Carousel {
//       model: mediaItems
//       delegate: Image { source: modelData.url; fillMode: Image.PreserveAspectCrop }
//   }
//
// Usage (inline children via default alias):
//   Carousel {
//       Text { text: "Slide 1" }
//       Image { source: "slide2.png" }
//       Column { Text { text: "Slide 3" } }
//   }
//
// Children (or model delegates) are placed inside the carousel and receive
// implicitWidth/height from the Carousel; fill them with anchors.fill: parent.
Item {
    id: root

    // Two usage modes: model/delegate (dynamic) OR children via default alias
    property var      model:        null
    property Component delegate:    null
    property int      currentIndex: 0
    property bool     showArrows:   true
    property bool     showDots:     true
    property bool     loop:         false
    property int      animDuration: Theme.durationNormal

    // Static children slot (alternative to model/delegate)
    default property alias children_: _staticSlot.data

    signal indexChanged(int index)

    implicitWidth:  400
    implicitHeight: 260

    readonly property bool _usingModel: root.model !== null && root.delegate !== null
    readonly property int  _count:      _usingModel ? _repeater.count : _staticSlot.children.length

    function next() {
        if (root._count < 2) return
        if (root.currentIndex < root._count - 1) root.currentIndex++
        else if (root.loop) root.currentIndex = 0
    }
    function previous() {
        if (root._count < 2) return
        if (root.currentIndex > 0) root.currentIndex--
        else if (root.loop) root.currentIndex = root._count - 1
    }
    function goTo(i) {
        if (i >= 0 && i < root._count) root.currentIndex = i
    }

    onCurrentIndexChanged: root.indexChanged(currentIndex)

    clip: true

    // ── Slide strip ───────────────────────────────────────────────────────────
    Item {
        id:     _strip
        width:  root.width * Math.max(1, root._count)
        height: root.height
        x:      -root.currentIndex * root.width
        Behavior on x { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

        // Dynamic model slides
        Repeater {
            id:      _repeater
            model:   root._usingModel ? root.model : 0
            delegate: Loader {
                required property var modelData
                required property int index
                x:          index * root.width
                width:      root.width
                height:     root.height
                sourceComponent: root.delegate
            }
        }

        // Static children container
        Item {
            id:      _staticSlot
            visible: !root._usingModel
            width:   root.width * Math.max(1, _staticSlot.children.length)
            height:  root.height

            function _reposition() {
                for (var i = 0; i < children.length; i++) {
                    children[i].x      = i * root.width
                    children[i].width  = root.width
                    children[i].height = root.height
                }
            }

            onChildrenChanged:  _reposition()
            Component.onCompleted: _reposition()

            Connections {
                target: root
                function onWidthChanged()  { _staticSlot._reposition() }
                function onHeightChanged() { _staticSlot._reposition() }
            }
        }
    }

    // ── Swipe ─────────────────────────────────────────────────────────────────
    MouseArea {
        anchors.fill:    parent
        property real _startX: 0
        onPressed:  (mouse) => _startX = mouse.x
        onReleased: (mouse) => {
            var delta = mouse.x - _startX
            if (delta < -40)      root.next()
            else if (delta > 40)  root.previous()
        }
    }

    // ── Arrows ────────────────────────────────────────────────────────────────
    Loader {
        active:           root.showArrows && root._count > 1
        anchors.fill:     parent

        sourceComponent: Component {
            Item {
                // Left arrow
                Rectangle {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    width:   36; height: 36; radius: 18
                    color:   _lH.containsMouse ? Theme.surface : Qt.rgba(0,0,0,0.3)
                    border.color: Theme.border; border.width: 1
                    opacity: (root.currentIndex > 0 || root.loop) ? 1 : 0.3
                    Behavior on color   { ColorAnimation  { duration: Theme.durationFast } }
                    Behavior on opacity { NumberAnimation  { duration: Theme.durationFast } }
                    HoverHandler { id: _lH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: root.currentIndex > 0 || root.loop
                        onClicked: root.previous()
                    }
                    Icon { anchors.centerIn: parent; name: Icons.caretLeft; size: 16; color: Theme.textPrimary }
                }

                // Right arrow
                Rectangle {
                    anchors { right: parent.right; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    width:   36; height: 36; radius: 18
                    color:   _rH.containsMouse ? Theme.surface : Qt.rgba(0,0,0,0.3)
                    border.color: Theme.border; border.width: 1
                    opacity: (root.currentIndex < root._count - 1 || root.loop) ? 1 : 0.3
                    Behavior on color   { ColorAnimation  { duration: Theme.durationFast } }
                    Behavior on opacity { NumberAnimation  { duration: Theme.durationFast } }
                    HoverHandler { id: _rH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: root.currentIndex < root._count - 1 || root.loop
                        onClicked: root.next()
                    }
                    Icon { anchors.centerIn: parent; name: Icons.caretRight; size: 16; color: Theme.textPrimary }
                }
            }
        }
    }

    // ── Dots ──────────────────────────────────────────────────────────────────
    Loader {
        active:           root.showDots && root._count > 1
        anchors {
            bottom: parent.bottom; bottomMargin: Theme.sp3
            horizontalCenter: parent.horizontalCenter
        }

        sourceComponent: Component {
            Row {
                spacing: Theme.sp1

                Repeater {
                    model: root._count
                    delegate: Rectangle {
                        id: _rq1
                        required property int index
                        readonly property bool _sel: index === root.currentIndex
                        width:  _sel ? 16 : 8; height: 8; radius: 4
                        color:  _sel ? Theme.primary : Theme.border
                        Behavior on width { NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation  { duration: Theme.durationFast } }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.goTo(_rq1.index) }
                    }
                }
            }
        }
    }
}
