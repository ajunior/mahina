import QtQuick
import Mahina

// Multi-page form with step indicator and per-step validation.
//
// Usage:
//   MultiStepForm {
//       steps: [
//           { title: "Account",  valid: emailOk          },
//           { title: "Profile",  valid: nameOk           },
//           { title: "Review",   valid: true              },
//       ]
//       onStepChanged: (i) => loadStepContent(i)
//       onCompleted:   () => submitForm()
//   }
Rectangle {
    id: root

    property var formSteps:    []
    property int currentStep:  0

    signal stepChanged(int step)
    signal completed()

    implicitWidth:  480
    implicitHeight: 360

    radius: Theme.radiusMd
    color:  Theme.surface
    border.color: Theme.border; border.width: 1

    readonly property bool canAdvance: root.formSteps.length > 0 &&
                                       root.currentStep < root.formSteps.length &&
                                       !!(root.formSteps[root.currentStep] &&
                                          root.formSteps[root.currentStep].valid)

    Column {
        anchors.fill: parent
        spacing: 0

        // Step indicator
        Rectangle {
            width: parent.width; height: 60
            color: Theme.surfaceVariant
            border.color: Theme.border; border.width: 0

            // Top rounded corners
            radius: Theme.radiusMd
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: parent.radius; color: parent.color
            }

            Row {
                anchors.centerIn: parent
                spacing: 0

                Repeater {
                    model: root.formSteps
                    delegate: Row {
                        id: _rq1
                        required property var  modelData
                        required property int  index

                        readonly property bool isDone:    index < root.currentStep
                        readonly property bool isCurrent: index === root.currentStep

                        spacing: 0

                        // Connector line
                        Rectangle {
                            visible: _rq1.index > 0
                            width: 40; height: 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: isDone ? Theme.primary : Theme.border
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        // Step circle
                        Column {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: isDone ? Theme.primary
                                             : (isCurrent ? Qt.rgba(Qt.color(Theme.primary).r,
                                                                    Qt.color(Theme.primary).g,
                                                                    Qt.color(Theme.primary).b, 0.12)
                                                          : Theme.surfaceVariant)
                                border.color: isDone || isCurrent ? Theme.primary : Theme.border
                                border.width: 2
                                Behavior on color { ColorAnimation { duration: 200 } }

                                Text {
                                    anchors.centerIn: parent
                                    text:           isDone ? "✓" : (_rq1.index + 1).toString()
                                    color:          isDone ? Theme.textOnPrimary
                                                          : (isCurrent ? Theme.primary : Theme.textDisabled)
                                    font.pixelSize: 11; font.weight: Font.Bold; font.family: Theme.fontFamily
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           _rq1.modelData.title || ""
                                color:          isCurrent ? Theme.primary : Theme.textDisabled
                                font.family:    Theme.fontFamily
                                font.pixelSize: 9
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle { width: parent.width; height: 1; color: Theme.border }

        // Step title
        Rectangle {
            width: parent.width; height: 40; color: "transparent"
            Text {
                anchors { left: parent.left; leftMargin: Theme.sp5; verticalCenter: parent.verticalCenter }
                text:  root.formSteps.length > root.currentStep
                       ? (root.formSteps[root.currentStep].title || "Step " + (root.currentStep + 1))
                       : ""
                color: Theme.textPrimary; font.family: Theme.fontFamily
                font.pixelSize: Theme.textBase; font.weight: Font.Medium
            }
        }

        // Content slot
        Item {
            id:     _stepContent
            width:  parent.width
            height: parent.height - 60 - 1 - 40 - 1 - 52
        }

        // Separator
        Rectangle { width: parent.width; height: 1; color: Theme.border }

        // Navigation
        Rectangle {
            width: parent.width; height: 52; color: "transparent"

            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: Theme.sp4 }
                spacing: Theme.sp3

                // Back
                Rectangle {
                    visible: root.currentStep > 0
                    width: _backTxt.implicitWidth + 24; height: 34; radius: Theme.radiusMd
                    color: _backH.hovered ? Theme.panel : "transparent"
                    border.color: Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }
                    HoverHandler { id: _backH }
                    Text { id: _backTxt; anchors.centerIn: parent; text: "Back"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.currentStep -= 1; root.stepChanged(root.currentStep) } }
                }

                // Next / Complete
                Rectangle {
                    width:  _nextTxt.implicitWidth + 24; height: 34; radius: Theme.radiusMd
                    color:  root.canAdvance ? (_nextH.hovered ? Qt.darker(Theme.primary, 1.1) : Theme.primary) : Theme.surfaceVariant
                    Behavior on color { ColorAnimation { duration: 100 } }
                    HoverHandler { id: _nextH; enabled: root.canAdvance }
                    Text {
                        id: _nextTxt
                        anchors.centerIn: parent
                        text:  root.currentStep >= root.formSteps.length - 1 ? "Complete" : "Next"
                        color: root.canAdvance ? Theme.textOnPrimary : Theme.textDisabled
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: root.canAdvance ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (!root.canAdvance) return
                            if (root.currentStep >= root.formSteps.length - 1) {
                                root.completed()
                            } else {
                                root.currentStep += 1
                                root.stepChanged(root.currentStep)
                            }
                        }
                    }
                }
            }
        }
    }
}
