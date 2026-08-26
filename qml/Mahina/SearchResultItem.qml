pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Structured search result row with title, excerpt, URL, meta, and icon.
//
// Usage:
//   SearchResultItem {
//       icon:    Icons.document
//       title:   "Getting started with Mahina"
//       excerpt: "Learn how to install and configure the Mahina component library..."
//       url:     "docs.example.com/glow/start"
//       meta:    "3 min read"
//       onActivated: openUrl()
//   }
Rectangle {
    id: root

    property string icon:    ""
    property string title:   ""
    property string excerpt: ""
    property string url:     ""
    property string meta:    ""
    property string badge:   ""

    signal activated()

    implicitWidth:  400
    implicitHeight: _inner.implicitHeight + Theme.sp3 * 2

    radius: Theme.radiusMd
    color:  _mah.hovered ? Theme.panel : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler { id: _mah }
    MouseArea {
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    Row {
        id:     _inner
        anchors {
            left: parent.left; right: parent.right
            top:  parent.top
            margins: Theme.sp3
        }
        spacing: Theme.sp3

        // Icon bubble
        Rectangle {
            width:  36; height: 36
            radius: Theme.radiusSm
            color:  Theme.surfaceVariant
            border.color: Theme.border; border.width: 1

            Text {
                anchors.centerIn: parent
                text:           root.icon
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textBase
                color:          Theme.textSecondary
            }
        }

        // Text column
        Column {
            width:   parent.width - 36 - Theme.sp3
            spacing: 2

            // Title + badge
            Row {
                width:   parent.width
                spacing: 6

                Text {
                    text:           root.title
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textBase
                    font.weight:    Font.Medium
                    elide:          Text.ElideRight
                    width:          parent.width - (root.badge !== "" ? _badgeRect.width + 8 : 0)
                }

                Rectangle {
                    id:      _badgeRect
                    visible: root.badge !== ""
                    height:  18; width: _badgeTxt.implicitWidth + 10; radius: 9
                    color:   Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                     Qt.color(Theme.primary).b, 0.12)
                    Text {
                        id:             _badgeTxt
                        anchors.centerIn: parent
                        text:           root.badge
                        color:          Theme.primary
                        font.pixelSize: Theme.textXs
                        font.family:    Theme.fontFamily
                        font.weight:    Font.Medium
                    }
                }
            }

            Text {
                visible:        root.excerpt !== ""
                text:           root.excerpt
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                elide:          Text.ElideRight
                width:          parent.width
            }

            Row {
                spacing: Theme.sp2
                visible: root.url !== "" || root.meta !== ""

                Text {
                    visible:        root.url !== ""
                    text:           root.url
                    color:          Theme.primary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    elide:          Text.ElideRight
                }
                Text {
                    visible:        root.url !== "" && root.meta !== ""
                    text:           "·"
                    color:          Theme.textDisabled
                    font.pixelSize: Theme.textXs
                }
                Text {
                    visible:        root.meta !== ""
                    text:           root.meta
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                }
            }
        }
    }
}
