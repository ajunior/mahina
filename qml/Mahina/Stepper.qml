pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Horizontal multi-step progress indicator.
//
// Usage:
//   Stepper {
//       steps: ["Account", "Plan", "Payment", "Review"]
//       currentStep: 2   // 0-based; steps 0 and 1 are completed, 2 is active
//   }
//
//   // With descriptions:
//   Stepper {
//       steps: [
//           { label: "Account",  description: "Create your account"  },
//           { label: "Plan",     description: "Choose a plan"        },
//           { label: "Payment",  description: "Enter payment info"   },
//       ]
//       currentStep: 1
//   }
//
//   // Navigate:
//   Button { text: "Next"; onClicked: stepper.currentStep++ }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var steps:       []
    property int currentStep: 0      // 0-based; -1 = none active

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  300
    implicitHeight: _row.implicitHeight

    readonly property real _circleSz: 28
    readonly property real _connH:     2

    RowLayout {
        id:      _row
        width:   parent.width
        spacing: 0

        Repeater {
            model: root.steps

            delegate: RowLayout {
                id: _step
                required property var modelData
                required property int index

                spacing: 0
                Layout.fillWidth: true

                readonly property bool isCompleted: index < root.currentStep
                readonly property bool isActive:    index === root.currentStep
                readonly property bool isPending:   index > root.currentStep
                readonly property string stepLabel: typeof modelData === "string"
                                                    ? modelData : (modelData.label ?? "")
                readonly property string stepDesc:  typeof modelData === "object" && modelData !== null
                                                    ? (modelData.description ?? "") : ""

                // ── Left half-connector ───────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height:           root._connH
                    Layout.alignment: Qt.AlignVCenter
                    // Hidden for first step but kept for even spacing
                    opacity:          _step.index > 0 ? 1 : 0
                    color:            _step.index <= root.currentStep ? Theme.primary : Theme.border

                    Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
                }

                // ── Step column: circle + labels ──────────────────────────────
                ColumnLayout {
                    spacing:          Theme.sp2
                    Layout.alignment: Qt.AlignTop

                    // Circle
                    Rectangle {
                        id:               _circle
                        implicitWidth:    root._circleSz
                        implicitHeight:   root._circleSz
                        radius:           root._circleSz / 2
                        Layout.alignment: Qt.AlignHCenter

                        color: _step.isCompleted ? Theme.primary
                             : _step.isActive    ? Theme.primarySubtle
                             : Theme.surface

                        border.color: _step.isPending ? Theme.border : Theme.primary
                        border.width: _step.isActive  ? 2 : 1

                        Behavior on color        { ColorAnimation { duration: Theme.durationNormal } }
                        Behavior on border.color { ColorAnimation { duration: Theme.durationNormal } }

                        // Checkmark (completed)
                        Text {
                            anchors.centerIn: parent
                            visible:          _step.isCompleted
                            text:             "✓"
                            color:            "#FFFFFF"
                            font.pixelSize:   12
                            font.weight:      Theme.weightBold
                        }

                        // Step number (active or pending)
                        Text {
                            anchors.centerIn: parent
                            visible:          !_step.isCompleted
                            text:             String(_step.index + 1)
                            color:            _step.isActive  ? Theme.primary
                                            : Theme.textDisabled
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textXs
                            font.weight:      Theme.weightSemibold

                            Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
                        }
                    }

                    // Label
                    Text {
                        text:             _step.stepLabel
                        color:            _step.isPending ? Theme.textDisabled : Theme.textPrimary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textXs
                        font.weight:      _step.isActive ? Theme.weightSemibold : Theme.weightRegular
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter

                        Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
                    }

                    // Description (optional)
                    Text {
                        visible:          _step.stepDesc !== ""
                        text:             _step.stepDesc
                        color:            Theme.textSecondary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textXs
                        wrapMode:         Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.maximumWidth: 80
                    }
                }

                // ── Right half-connector ──────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height:           root._connH
                    Layout.alignment: Qt.AlignVCenter
                    opacity:          _step.index < root.steps.length - 1 ? 1 : 0
                    color:            _step.index < root.currentStep ? Theme.primary : Theme.border

                    Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
                }
            }
        }
    }
}
