pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Collapsible task checklist with progress bar for user onboarding flows.
//
// Usage:
//   OnboardingChecklist {
//       title: "Get started"
//       tasks: [
//           { label: "Create your first project",  done: true  },
//           { label: "Invite a team member",       done: false },
//           { label: "Connect your data source",   done: false },
//           { label: "Publish your dashboard",     done: false },
//       ]
//       onTaskToggled: (i, done) => model.tasks[i].done = done
//   }
Item {
    id: root

    property string title: "Get started"
    property var    tasks: []
    property bool   collapsed: false

    signal taskToggled(int index, bool done)
    signal dismissed()

    readonly property int _doneCount: {
        var c = 0
        for (var i = 0; i < tasks.length; i++) if (tasks[i].done) c++
        return c
    }
    readonly property real _progress: tasks.length > 0 ? _doneCount / tasks.length : 0

    implicitWidth:  320
    implicitHeight: _col.implicitHeight

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusLg
        color:         Theme.surface
        border.color:  Theme.border
        border.width:  1
        clip:          true

        Column {
            id:     _col
            width:  parent.width
            spacing: 0

            // Header
            Rectangle {
                width: parent.width; height: 52
                color: "transparent"

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp3 }
                    spacing: Theme.sp2

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        width: parent.width - 48 - Theme.sp2

                        Row {
                            spacing: Theme.sp2
                            Text {
                                text:  root.title
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                font.weight: Theme.weightSemibold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: _pctText.implicitWidth + Theme.sp2 * 2; height: 16; radius: 8
                                color: root._progress >= 1 ? Theme.success : Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    id: _pctText
                                    anchors.centerIn: parent
                                    text: root._doneCount + "/" + root.tasks.length
                                    color: "#ffffff"; font.pixelSize: Theme.textXs; font.family: Theme.fontFamilyMono
                                }
                            }
                        }

                        // Mini progress bar
                        Rectangle {
                            width: parent.width; height: 4; radius: 2
                            color: Theme.border
                            Rectangle {
                                width: parent.width * root._progress; height: 4; radius: 2
                                color: root._progress >= 1 ? Theme.success : Theme.primary
                                Behavior on width { NumberAnimation { duration: Theme.durationNormal } }
                            }
                        }
                    }

                    // Collapse toggle
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: _chH.containsMouse ? Theme.panel : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        HoverHandler { id: _chH }
                        Text {
                            anchors.centerIn: parent
                            text:  root.collapsed ? "▼" : "▲"
                            color: Theme.textDisabled
                            font.pixelSize: 10
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.collapsed = !root.collapsed }
                    }

                    // Dismiss
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: _dH2.containsMouse ? Theme.panel : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        HoverHandler { id: _dH2 }
                        Text { anchors.centerIn: parent; text: "✕"; color: Theme.textDisabled; font.pixelSize: 10 }
                        MouseArea { anchors.fill: parent; onClicked: root.dismissed() }
                    }
                }
            }

            // Task list (collapsed hides it)
            Column {
                visible:  !root.collapsed
                width:    parent.width
                spacing:  0

                Rectangle { width: parent.width; height: 1; color: Theme.border }

                Repeater {
                    model: root.tasks
                    delegate: Rectangle {
                        id: _rq1
                        required property var  modelData
                        required property int  index
                        width:  parent.width; height: 44
                        color:  _tH.containsMouse ? Theme.panel : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _tH }

                        Row {
                            anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
                            spacing: Theme.sp3

                            // Checkbox
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color:  _rq1.modelData.done ? Theme.success : "transparent"
                                border.color: _rq1.modelData.done ? Theme.success : Theme.border
                                border.width: 2
                                Text {
                                    visible: _rq1.modelData.done
                                    anchors.centerIn: parent
                                    text: "✓"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.Bold
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:  _rq1.modelData.label ?? ""
                                color: _rq1.modelData.done ? Theme.textDisabled : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                font.strikeout: _rq1.modelData.done
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var newTasks = root.tasks.slice()
                                newTasks[_rq1.index] = { label: newTasks[_rq1.index].label, done: !newTasks[_rq1.index].done }
                                root.tasks = newTasks
                                root.taskToggled(_rq1.index, newTasks[_rq1.index].done)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Theme.border; visible: root.tasks.length > 0 }
            }
        }
    }
}
