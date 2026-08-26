pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Step-by-step onboarding overlay. Highlights a target item and shows a
// tooltip-style popover with navigation controls.
//
// Usage:
//   Tour {
//       id:    tour
//       steps: [
//           { target: _sidebar,   title: "Navigation",  body: "Switch between sections here." },
//           { target: _addButton, title: "Add items",   body: "Click to create a new entry."  },
//           { target: null,       title: "You're ready!", body: "That's the quick tour."        },
//       ]
//   }
//   Button { text: "Take a tour"; onClicked: tour.start() }
//
// step shape: { target?: Item, title: string, body: string }
// If `target` is null or omitted the overlay centers the card.
Item {
    id: root

    property var steps:        []
    property int currentStep:  0

    signal started()
    signal finished()
    signal stepChanged(int step)

    function start(): void {
        root.currentStep = 0
        root.visible     = true
        root.started()
    }

    function next(): void {
        if (root.currentStep < root.steps.length - 1) {
            root.currentStep++
            root.stepChanged(root.currentStep)
        } else {
            _finishAnim.start()
        }
    }

    function previous(): void {
        if (root.currentStep > 0) {
            root.currentStep--
            root.stepChanged(root.currentStep)
        }
    }

    function stop(): void {
        _finishAnim.start()
    }

    anchors.fill: parent
    visible:      false
    z:            9900

    readonly property var _step: steps.length > 0 ? steps[Math.max(0, Math.min(currentStep, steps.length - 1))] : null
    readonly property Item _target: (_step && _step.target) ? _step.target : null

    // Finish animation. The teardown runs from onFinished rather than a
    // trailing ScriptAction: a ScriptAction's `script` is a QQmlScriptString,
    // which qmlcachegen cannot compile — and it stops compiling the rest of the
    // document when it meets one, so a ScriptAction near the top of a file
    // costs every binding below it. onFinished is an ordinary signal handler.
    SequentialAnimation {
        id: _finishAnim
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: Theme.durationNormal }
        onFinished: {
            root.visible = false
            root.opacity = 1
            root.finished()
        }
    }

    // ── Dimmed backdrop ───────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.overlay
        opacity:      0.75
    }

    // ── Spotlight: bright border around target ────────────────────────────────
    Rectangle {
        id:      _spotlight
        visible: root._target !== null

        readonly property point _origin: {
            if (!root._target) return Qt.point(0, 0)
            return root.mapFromItem(root._target, 0, 0)
        }

        x:      _origin.x - Theme.sp2
        y:      _origin.y - Theme.sp2
        width:  root._target ? root._target.width  + Theme.sp4 : 0
        height: root._target ? root._target.height + Theme.sp4 : 0
        radius: Theme.radiusMd
        color:  "transparent"
        border.color: Theme.primary
        border.width: 2

        Behavior on x      { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on y      { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on width  { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        // Glow ring → highlight ring
        Rectangle {
            anchors { fill: parent; margins: -4 }
            radius:       parent.radius + 4
            color:        "transparent"
            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
            border.width: 4
        }
    }

    // ── Popover card ──────────────────────────────────────────────────────────
    Rectangle {
        id:     _card
        width:  300
        height: _cardCol.implicitHeight + Theme.sp5 * 2
        radius: Theme.radiusLg
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1

        // Position: below target if possible, else above; or center if no target
        property real _tx: {
            if (!root._target) return root.width / 2 - width / 2
            var ox = root.mapFromItem(root._target, 0, 0).x
            return Math.max(Theme.sp4, Math.min(root.width - width - Theme.sp4,
                   ox + root._target.width / 2 - width / 2))
        }
        property real _ty: {
            if (!root._target) return root.height / 2 - height / 2
            var origin = root.mapFromItem(root._target, 0, 0)
            var below  = origin.y + root._target.height + Theme.sp3 + Theme.sp2
            if (below + height < root.height - Theme.sp4) return below
            return origin.y - height - Theme.sp3
        }

        x: _tx
        y: _ty

        Behavior on x { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id:      _cardCol
            anchors {
                left:   parent.left; right: parent.right; top: parent.top
                margins: Theme.sp5
            }
            spacing: Theme.sp3

            // Step counter pill
            Rectangle {
                Layout.alignment: Qt.AlignLeft
                height:           22; radius: Theme.radiusFull
                width:            _stepText.implicitWidth + Theme.sp3 * 2
                color:            Theme.primarySubtle

                Text {
                    id:             _stepText
                    anchors.centerIn: parent
                    text:           (root.currentStep + 1) + " / " + root.steps.length
                    color:          Theme.primary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightSemibold
                }
            }

            // Title
            Text {
                visible:          root._step && root._step.title
                text:             root._step ? root._step.title ?? "" : ""
                color:            Theme.textPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textBase
                font.weight:      Theme.weightSemibold
                wrapMode:         Text.WordWrap
                Layout.fillWidth: true
            }

            // Body
            Text {
                visible:          root._step && root._step.body
                text:             root._step ? root._step.body ?? "" : ""
                color:            Theme.textSecondary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                wrapMode:         Text.WordWrap
                Layout.fillWidth: true
            }

            // Step dots
            Row {
                spacing:          Theme.sp1
                Layout.alignment: Qt.AlignHCenter
                Repeater {
                    model: root.steps.length
                    delegate: Rectangle {
                        required property int index
                        width:  index === root.currentStep ? 16 : 6
                        height: 6; radius: 3
                        color:  index === root.currentStep ? Theme.primary : Theme.border
                        Behavior on width { NumberAnimation { duration: Theme.durationFast } }
                        Behavior on color { ColorAnimation  { duration: Theme.durationFast } }
                    }
                }
            }

            // Navigation row
            RowLayout {
                Layout.fillWidth: true
                spacing:          Theme.sp2

                // Skip
                Rectangle {
                    visible:  root.steps.length > 1
                    implicitHeight: 32; radius: Theme.radiusMd
                    implicitWidth:  _skipTxt.implicitWidth + Theme.sp3 * 2
                    color:    _skipH.containsMouse ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _skipH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.stop() }
                    Text {
                        id:             _skipTxt
                        anchors.centerIn: parent
                        text:           "Skip"
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                    }
                }

                Item { Layout.fillWidth: true }

                // Previous
                Rectangle {
                    visible: root.currentStep > 0
                    implicitHeight: 32; radius: Theme.radiusMd
                    implicitWidth:  _prevTxt.implicitWidth + Theme.sp3 * 2
                    color:   _prevH.containsMouse ? Theme.panel : Theme.panel
                    border.color: Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _prevH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.previous() }
                    Text {
                        id:             _prevTxt
                        anchors.centerIn: parent
                        text:           "Back"
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Theme.weightMedium
                    }
                }

                // Next / Done
                Rectangle {
                    implicitHeight: 32; radius: Theme.radiusMd
                    implicitWidth:  _nextTxt.implicitWidth + Theme.sp4 * 2
                    color:        _nextH.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _nextH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.next() }
                    Text {
                        id:             _nextTxt
                        anchors.centerIn: parent
                        text:           root.currentStep === root.steps.length - 1 ? "Done" : "Next"
                        color:          "#ffffff"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    Theme.weightMedium
                    }
                }
            }
        }
    }
}
