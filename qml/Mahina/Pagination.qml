pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Page navigation controls.
//
// Usage:
//   Pagination {
//       currentPage: 3
//       totalPages:  20
//       onPageChanged: (p) => loadPage(p)
//   }
//
//   // Compact: fewer visible page buttons
//   Pagination { currentPage: 1; totalPages: 5; windowSize: 3 }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property int currentPage: 1
    property int totalPages:  1
    property int windowSize:  3      // page buttons visible around current

    signal pageChanged(int page)

    // -1 in the list means "…" (ellipsis)
    readonly property var _pages: {
        var cur   = root.currentPage
        var total = root.totalPages
        var win   = root.windowSize

        if (total <= 0)           return []
        if (total <= win + 2)     {
            var a = []; for (var i = 1; i <= total; i++) a.push(i); return a
        }

        var half  = Math.floor(win / 2)
        var start = Math.max(2, cur - half)
        var end   = Math.min(total - 1, cur + half)

        // Expand window if near edges
        if (cur - half <= 1) end   = Math.min(total - 1, 1 + win)
        if (cur + half >= total) start = Math.max(2, total - win)

        var pages = [1]
        if (start > 2)          pages.push(-1)
        for (var j = start; j <= end; j++) pages.push(j)
        if (end < total - 1)    pages.push(-1)
        pages.push(total)
        return pages
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    readonly property real _btnSz: 32

    RowLayout {
        id:      _row
        spacing: Theme.sp1

        // ── Previous ──────────────────────────────────────────────────────────
        Rectangle {
            width:   root._btnSz
            height:  root._btnSz
            radius:  Theme.radiusSm
            color:   !_prevEn ? "transparent"
                   : _prevHov.hovered ? Theme.hover : "transparent"

            readonly property bool _prevEn: root.currentPage > 1

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _prevHov; enabled: parent._prevEn }

            Icon {
                anchors.centerIn: parent
                name:  Icons.caretLeft
                size:  14
                color: parent._prevEn ? Theme.textPrimary : Theme.textDisabled
            }

            MouseArea {
                anchors.fill: parent
                enabled:      parent._prevEn
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.pageChanged(root.currentPage - 1)
            }
        }

        // ── Page buttons ──────────────────────────────────────────────────────
        Repeater {
            model: root._pages

            delegate: Rectangle {
                id: _rq1
                required property var modelData
                required property int index

                readonly property bool isEllipsis: modelData === -1
                readonly property bool isCurrent:  modelData === root.currentPage

                width:  root._btnSz
                height: root._btnSz
                radius: Theme.radiusSm
                color:  isCurrent  ? Theme.primary
                      : isEllipsis ? "transparent"
                      : _pHov.hovered ? Theme.hover
                      : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                HoverHandler { id: _pHov; enabled: !_rq1.isCurrent && !_rq1.isEllipsis }

                Text {
                    anchors.centerIn: parent
                    text:           _rq1.isEllipsis ? "…" : String(_rq1.modelData)
                    color:          _rq1.isCurrent  ? Theme.textOnPrimary
                                  : _rq1.isEllipsis ? Theme.textDisabled
                                  : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    _rq1.isCurrent ? Theme.weightSemibold : Theme.weightRegular
                }

                MouseArea {
                    anchors.fill: parent
                    enabled:      !_rq1.isCurrent && !_rq1.isEllipsis
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.pageChanged(_rq1.modelData)
                }
            }
        }

        // ── Next ──────────────────────────────────────────────────────────────
        Rectangle {
            width:  root._btnSz
            height: root._btnSz
            radius: Theme.radiusSm
            color:  !_nextEn ? "transparent"
                  : _nextHov.hovered ? Theme.hover : "transparent"

            readonly property bool _nextEn: root.currentPage < root.totalPages

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            HoverHandler { id: _nextHov; enabled: parent._nextEn }

            Icon {
                anchors.centerIn: parent
                name:  Icons.caretRight
                size:  14
                color: parent._nextEn ? Theme.textPrimary : Theme.textDisabled
            }

            MouseArea {
                anchors.fill: parent
                enabled:      parent._nextEn
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.pageChanged(root.currentPage + 1)
            }
        }
    }
}
