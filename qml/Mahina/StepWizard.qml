pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Multi-step form wizard with progress indicator, back/next navigation.
//
// Usage:
//   StepWizard {
//       steps: [
//           { title: "Account",  content: accountForm  },
//           { title: "Profile",  content: profileForm  },
//           { title: "Confirm",  content: confirmPage  },
//       ]
//       onFinished: submitForm()
//   }
Item {
    id: root

    property var    steps:       []
    property int    currentStep: 0
    property string finishLabel: "Finish"
    property string nextLabel:   "Next"
    property string backLabel:   "Back"

    signal finished()
    signal stepChanged(int step)

    implicitWidth:  500
    implicitHeight: 400

    function next(): void {
        if (root.currentStep < root.steps.length - 1) {
            root.currentStep++
            root.stepChanged(root.currentStep)
        } else {
            root.finished()
        }
    }
    function back(): void {
        if (root.currentStep > 0) {
            root.currentStep--
            root.stepChanged(root.currentStep)
        }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Step indicator
        Rectangle {
            width: parent.width; height: 64
            color: Theme.surface
            border.color: Theme.border; border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 0

                Repeater {
                    model: root.steps
                    delegate: Row {
                        id: _rq1
                        required property var  modelData
                        required property int  index
                        spacing: 0

                        // Connector line (before each step except first)
                        Rectangle {
                            visible: _rq1.index > 0
                            width:  40; height: 2
                            color:  _rq1.index <= root.currentStep ? Theme.primary : Theme.border
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Step circle
                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width:  28; height: 28; radius: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                                color:  _rq1.index < root.currentStep ? Theme.primary :
                                        _rq1.index === root.currentStep ? Theme.primary : Theme.panel
                                border.color: _rq1.index === root.currentStep ? Theme.primary : Theme.border
                                border.width: _rq1.index === root.currentStep ? 2 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text:  _rq1.index < root.currentStep ? "✓" : (_rq1.index + 1)
                                    color: _rq1.index <= root.currentStep ? "#ffffff" : Theme.textDisabled
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.textXs
                                    font.weight: Theme.weightBold
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:  _rq1.modelData.title ?? ""
                                color: _rq1.index === root.currentStep ? Theme.primary : Theme.textDisabled
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight: _rq1.index === root.currentStep ? Theme.weightSemibold : Theme.weightRegular
                            }
                        }
                    }
                }
            }
        }

        // Content area
        Rectangle {
            width:  parent.width
            height: parent.height - 64 - 60
            color:  Theme.background
            clip:   true

            Repeater {
                model: root.steps
                delegate: Item {
                    required property var  modelData
                    required property int  index
                    anchors.fill: parent
                    visible:      index === root.currentStep
                    children:     modelData.content ? [modelData.content] : []
                }
            }
        }

        // Footer / nav buttons
        Rectangle {
            width:  parent.width; height: 60
            color:  Theme.surface
            border.color: Theme.border; border.width: 1

            Row {
                anchors { right: parent.right; rightMargin: Theme.sp4; verticalCenter: parent.verticalCenter }
                spacing: Theme.sp2

                Button {
                    visible:  root.currentStep > 0
                    text:     root.backLabel
                    variant:  Button.Variant.Ghost
                    onClicked: root.back()
                }

                Button {
                    text:     root.currentStep === root.steps.length - 1 ? root.finishLabel : root.nextLabel
                    onClicked: root.next()
                }
            }

            Text {
                anchors { left: parent.left; leftMargin: Theme.sp4; verticalCenter: parent.verticalCenter }
                text:  "Step " + (root.currentStep + 1) + " of " + root.steps.length
                color: Theme.textDisabled
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }
}
