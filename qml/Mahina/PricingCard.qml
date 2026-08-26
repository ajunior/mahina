pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// SaaS-style pricing tier card with feature list and CTA button.
//
// Usage:
//   PricingCard {
//       tier:       "Pro"
//       price:      "$29"
//       period:     "/ mo"
//       tagline:    "For growing teams"
//       features:   ["Unlimited projects", "Priority support", "Advanced analytics", "SSO"]
//       ctaLabel:   "Get started"
//       highlighted: true
//       onCtaClicked: Qt.openUrlExternally("https://example.com/signup")
//   }
Item {
    id: root

    property string tier:        ""
    property string price:       ""
    property string period:      "/ mo"
    property string tagline:     ""
    property var    features:    []
    property string ctaLabel:    "Get started"
    property bool   highlighted: false
    property string badge:       ""

    signal ctaClicked()

    implicitWidth:  260
    implicitHeight: _col.implicitHeight + Theme.sp5 * 2

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusLg
        color:         root.highlighted ? Theme.primary : Theme.surface
        border.color:  root.highlighted ? "transparent" : Theme.border
        border.width:  1

        // Highlighted glow ring
        Rectangle {
            visible:       root.highlighted
            anchors { fill: parent; margins: -2 }
            radius:        Theme.radiusLg + 2
            color:         "transparent"
            border.color:  Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.4)
            border.width:  2
        }

        // Badge
        Rectangle {
            visible: root.badge !== ""
            anchors { top: parent.top; topMargin: -10; horizontalCenter: parent.horizontalCenter }
            width:  _badgeText.implicitWidth + Theme.sp3 * 2
            height: 20; radius: 10
            color:  root.highlighted ? "#ffffff" : Theme.primary

            Text {
                id:             _badgeText
                anchors.centerIn: parent
                text:           root.badge
                color:          root.highlighted ? Theme.primary : "#ffffff"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                font.weight:    Theme.weightBold
            }
        }

        Column {
            id:     _col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp5 }
            spacing: Theme.sp4

            // Tier name
            Text {
                text:           root.tier
                color:          root.highlighted ? "#ffffff" : Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
            }

            // Price
            Row {
                spacing: Theme.sp1
                Text {
                    text:           root.price
                    color:          root.highlighted ? "#ffffff" : Theme.textPrimary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.text2xl
                    font.weight:    Theme.weightBold
                    anchors.baseline: _periodText.baseline
                }
                Text {
                    id:             _periodText
                    text:           root.period
                    color:          root.highlighted ? Qt.rgba(1,1,1,0.7) : Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    anchors.bottom: parent.bottom
                    bottomPadding:  4
                }
            }

            // Tagline
            Text {
                visible:        root.tagline !== ""
                text:           root.tagline
                color:          root.highlighted ? Qt.rgba(1,1,1,0.75) : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                wrapMode:       Text.Wrap
                width:          parent.width
            }

            // Divider
            Rectangle { width: parent.width; height: 1; color: root.highlighted ? Qt.rgba(1,1,1,0.2) : Theme.border }

            // Features
            Column {
                width: parent.width
                spacing: Theme.sp2

                Repeater {
                    model: root.features
                    delegate: Row {
                        id: _rq1
                        required property string modelData
                        spacing: Theme.sp2
                        width: parent.width

                        Text {
                            text:           "✓"
                            color:          root.highlighted ? "#ffffff" : Theme.success
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Theme.weightBold
                        }
                        Text {
                            text:           _rq1.modelData
                            color:          root.highlighted ? Qt.rgba(1,1,1,0.85) : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            wrapMode:       Text.Wrap
                            width:          parent.width - 20
                        }
                    }
                }
            }

            // CTA button
            Rectangle {
                width:  parent.width; height: 40; radius: Theme.radiusMd
                color:  root.highlighted ? "#ffffff" : Theme.primary
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                Text {
                    anchors.centerIn: parent
                    text:           root.ctaLabel
                    color:          root.highlighted ? Theme.primary : "#ffffff"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Theme.weightSemibold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.ctaClicked()
                }
            }
        }
    }
}
