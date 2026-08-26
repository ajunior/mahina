pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Grouped notification tray panel with dismiss-all and per-item dismiss.
//
// Usage:
//   NotificationCenter {
//       open: _notifOpen
//       notifications: [
//           { id: "1", title: "Build succeeded", body: "main branch is green", time: "2m ago", type: "success", read: false },
//           { id: "2", title: "PR #42 approved",  body: "Bob approved your PR",  time: "8m ago", type: "info",    read: false },
//           { id: "3", title: "Deploy failed",    body: "prod deploy timed out", time: "1h ago", type: "error",   read: true  },
//       ]
//       onDismiss: (id) => notifications = notifications.filter(n => n.id !== id)
//       onDismissAll: notifications = []
//   }
Item {
    id: root

    property bool open:          false
    property var  notifications: []
    property int  panelWidth:    320

    signal dismiss(string id)
    signal dismissAll()
    signal notifClicked(var notif)

    readonly property int _unread: {
        var c = 0
        for (var i = 0; i < notifications.length; i++) if (!notifications[i].read) c++
        return c
    }

    function _typeColor(t: var): var {
        if (t === "success") return Theme.success
        if (t === "error")   return Theme.error
        if (t === "warning") return Theme.warning
        return Theme.primary
    }

    // Panel
    Rectangle {
        visible:  root.open
        width:    root.panelWidth
        height:   parent.height
        color:    Theme.surface
        border.color: Theme.border; border.width: 1
        radius:   Theme.radiusLg

        Column {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                width: parent.width; height: 52
                color: "transparent"
                border.color: Theme.border; border.width: 0

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
                    spacing: Theme.sp2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  "Notifications" + (root._unread > 0 ? "  " + root._unread : "")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        font.weight: Theme.weightSemibold
                    }

                    Item { width: 1; height: 1 }

                    Text {
                        visible:        root.notifications.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text:           "Clear all"
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.dismissAll() }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // List
            QQC.ScrollView {
                width:  parent.width
                height: parent.height - 52 - 1
                clip:   true
                contentWidth: availableWidth

                Column {
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: root.notifications
                        delegate: Rectangle {
                            id: _rq1
                            required property var  modelData
                            required property int  index
                            width:  parent.width; height: 72
                            color:  !modelData.read ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.05) : "transparent"

                            Rectangle {
                                width: parent.width; height: 1
                                color: Theme.border
                                anchors.bottom: parent.bottom
                                visible: _rq1.index < root.notifications.length - 1
                            }

                            Row {
                                anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp3; topMargin: Theme.sp3; bottomMargin: Theme.sp3 }
                                spacing: Theme.sp3

                                // Type indicator dot
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: root._typeColor(_rq1.modelData.type ?? "info")
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: _rq1.modelData.read ? 0.4 : 1
                                }

                                // Content
                                Column {
                                    width: parent.width - 8 - 24 - Theme.sp3 * 2
                                    spacing: Theme.sp1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text:           _rq1.modelData.title ?? ""
                                        color:          _rq1.modelData.read ? Theme.textSecondary : Theme.textPrimary
                                        font.family:    Theme.fontFamily
                                        font.pixelSize: Theme.textSm
                                        font.weight:    _rq1.modelData.read ? Theme.weightRegular : Theme.weightSemibold
                                        elide:          Text.ElideRight
                                        width:          parent.width
                                    }
                                    Text {
                                        visible:        (_rq1.modelData.body ?? "") !== ""
                                        text:           _rq1.modelData.body ?? ""
                                        color:          Theme.textSecondary
                                        font.family:    Theme.fontFamily
                                        font.pixelSize: Theme.textXs
                                        elide:          Text.ElideRight
                                        width:          parent.width
                                    }
                                    Text {
                                        visible:        (_rq1.modelData.time ?? "") !== ""
                                        text:           _rq1.modelData.time ?? ""
                                        color:          Theme.textDisabled
                                        font.family:    Theme.fontFamily
                                        font.pixelSize: Theme.textXs
                                    }
                                }

                                // Dismiss button
                                Rectangle {
                                    width: 20; height: 20; radius: 10
                                    color: _dH.containsMouse ? Theme.panel : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter
                                    HoverHandler { id: _dH }
                                    Text { anchors.centerIn: parent; text: "✕"; color: Theme.textDisabled; font.pixelSize: 10 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.dismiss(_rq1.modelData.id ?? "") }
                                }
                            }

                            MouseArea { anchors.fill: parent; onClicked: root.notifClicked(_rq1.modelData) }
                        }
                    }

                    // Empty state
                    Item {
                        visible: root.notifications.length === 0
                        width:   parent.width; height: 120
                        Text {
                            anchors.centerIn: parent
                            text:  "All caught up!"
                            color: Theme.textDisabled
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                    }
                }
            }
        }
    }
}
