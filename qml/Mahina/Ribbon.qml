pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // ribbonTabs: [{label, groups: [{label, actions: [{icon, label, action, separator}]}]}]
    property var ribbonTabs:    []
    property int activeRibbonTab: 0

    signal ribbonAction(string label)

    implicitWidth:  700
    implicitHeight: 90

    Rectangle {
        anchors.fill: parent
        color:  Theme.panel
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Tab row
            Rectangle {
                width: parent.width; height: 28
                color: Theme.surface
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp2; bottom: parent.bottom }
                    spacing: 0

                    Repeater {
                        model: root.ribbonTabs
                        delegate: Rectangle {
                            id: _rq1
                            required property var  modelData
                            required property int  index
                            height: 27
                            width:  _tabTxt.implicitWidth + Theme.sp4
                            color:  index === root.activeRibbonTab ? Theme.panel : "transparent"
                            Rectangle {
                                visible: _rq1.index === root.activeRibbonTab
                                anchors { left: parent.left; right: parent.right; top: parent.top }
                                height: 2; color: Theme.primary
                            }
                            Text {
                                id:    _tabTxt
                                anchors.centerIn: parent
                                text:  _rq1.modelData.label || ""
                                color: _rq1.index === root.activeRibbonTab ? Theme.primary : Theme.textSecondary
                                font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: _rq1.index === root.activeRibbonTab ? Font.Medium : Font.Normal }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeRibbonTab = _rq1.index
                            }
                        }
                    }
                }
            }

            // Content: groups of buttons
            Flickable {
                width:  parent.width
                height: 62
                contentWidth: _groupsRow.implicitWidth + Theme.sp3
                contentHeight: height
                clip: true
                QQC.ScrollBar.horizontal: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

                Row {
                    id:      _groupsRow
                    height:  parent.height
                    x:       Theme.sp2
                    spacing: 0

                    Repeater {
                        model: root.ribbonTabs.length > root.activeRibbonTab
                               ? root.ribbonTabs[root.activeRibbonTab].groups || []
                               : []
                        delegate: Row {
                            id: _rq2
                            required property var  modelData
                            required property int  index
                            height: parent.height
                            spacing: 0

                            // Group content
                            Column {
                                height: parent.height
                                width:  _actionsRow.implicitWidth
                                spacing: 0

                                Row {
                                    id:      _actionsRow
                                    height:  parent.height - 18
                                    spacing: 2
                                    topPadding: Theme.sp2
                                    leftPadding: Theme.sp2

                                    Repeater {
                                        model: _rq2.modelData.actions || []
                                        delegate: Loader {
                                            required property var  modelData
                                            required property int  index
                                            height: parent.height - 4
                                            width:  modelData.separator ? 1 : (modelData.large ? 52 : 44)
                                            sourceComponent: modelData.separator ? _sepComp : _btnComp
                                            property var actionData: modelData
                                        }
                                    }
                                }

                                // Group label
                                Text {
                                    height: 18
                                    width:  parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text:  _rq2.modelData.label || ""
                                    color: Theme.textDisabled
                                    font { family: Theme.fontFamily; pixelSize: 10 }
                                }
                            }

                            // Group divider
                            Rectangle {
                                width: 1; height: parent.height - 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.border
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: _sepComp
        Rectangle {
            width: 1; height: parent ? parent.height : 32
            color: Theme.border
        }
    }

    Component {
        id: _btnComp
        Rectangle {
            id:    _ribBtn
            width: parent ? parent.width : 44
            height: parent ? parent.height : 44
            radius: Theme.radiusSm
            property var actionData: parent ? (parent as Loader).actionData : ({})
            color: _rbH.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _rbH }
            border.color: _rbH.hovered ? Theme.border : "transparent"; border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  _ribBtn.actionData.icon || "□"
                    font.pixelSize: 16
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  _ribBtn.actionData.label || ""
                    color: Theme.textPrimary
                    font { family: Theme.fontFamily; pixelSize: 9 }
                    elide: Text.ElideRight
                    width: 42
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (_ribBtn.actionData.action) _ribBtn.actionData.action()
                    root.ribbonAction(_ribBtn.actionData.label || "")
                }
            }
        }
    }
}
