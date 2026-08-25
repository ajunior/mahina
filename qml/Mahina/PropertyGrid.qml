import QtQuick
import QtQuick.Layouts
import Mahina

// Two-column key/value inspector. Supports multiple value types.
//
// Usage:
//   PropertyGrid {
//       model: [
//           { key: "Status",  value: "Active",     type: "badge", badgeColor: Theme.success },
//           { key: "Version", value: "2.4.1" },
//           { key: "Dark",    value: true,          type: "boolean" },
//           { key: "Theme",   value: "#5B8DF6",     type: "color" },
//           { key: "Docs",    value: "glow.dev",    type: "link" },
//       ]
//       keyWidth: 100
//   }
//
// Types: "text" (default) | "badge" | "color" | "boolean" | "link"
Item {
    id: root

    property var    model:     []
    property real   keyWidth:  120
    property bool   zebra:     true
    property string emptyText: "No properties"

    signal linkClicked(int index, string value)

    implicitWidth:  300
    implicitHeight: _col.implicitHeight

    Column {
        id:    _col
        width: parent.width

        Repeater {
            model: root.model
            delegate: Rectangle {
                id: _rq1
                required property var modelData
                required property int index

                readonly property string _type: modelData.type ?? "text"

                width:  _col.width
                height: 36
                color:  root.zebra && index % 2 === 1 ? Theme.surfaceVariant : "transparent"

                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 1; color: Theme.border
                }

                RowLayout {
                    anchors {
                        left: parent.left; right: parent.right
                        leftMargin: Theme.sp3; rightMargin: Theme.sp3
                        verticalCenter: parent.verticalCenter
                    }
                    height: parent.height
                    spacing: Theme.sp3

                    Text {
                        Layout.preferredWidth: root.keyWidth
                        Layout.alignment:      Qt.AlignVCenter
                        text:           _rq1.modelData.key ?? ""
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        elide:          Text.ElideRight
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        height: 24

                        // text (default)
                        Text {
                            visible:        _type === "text"
                            anchors.verticalCenter: parent.verticalCenter
                            width:          parent.width
                            text:           String(_rq1.modelData.value ?? "")
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            elide:          Text.ElideRight
                        }

                        // badge
                        Rectangle {
                            visible:  _type === "badge"
                            anchors.verticalCenter: parent.verticalCenter
                            height:       20
                            width:        _badgeLbl.implicitWidth + Theme.sp3 * 2
                            radius:       Theme.radiusFull
                            color:        _rq1.modelData.badgeColor ?? Theme.primarySubtle
                            Text {
                                id:              _badgeLbl
                                anchors.centerIn: parent
                                text:            String(_rq1.modelData.value ?? "")
                                color:           _rq1.modelData.badgeColor ? Theme.textOnPrimary : Theme.primary
                                font.family:     Theme.fontFamily
                                font.pixelSize:  Theme.textXs
                                font.weight:     Theme.weightMedium
                            }
                        }

                        // color swatch
                        Row {
                            visible:  _type === "color"
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:  Theme.sp2
                            Rectangle {
                                width: 16; height: 16; radius: Theme.radiusXs
                                color: {
                                    var v = String(_rq1.modelData.value ?? "")
                                    try { return Qt.color(v) } catch(e) { return "transparent" }
                                }
                                border.color: Theme.border; border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           String(_rq1.modelData.value ?? "")
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamilyMono
                                font.pixelSize: Theme.textSm
                            }
                        }

                        // boolean
                        Row {
                            visible:  _type === "boolean"
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:  Theme.sp1
                            readonly property bool _bval: _rq1.modelData.value === true || _rq1.modelData.value === "true"
                            Icon {
                                name:  parent._bval ? Icons.checkCircle : Icons.xCircle
                                size:  16
                                color: parent._bval ? Theme.success : Theme.error
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:           parent._bval ? "true" : "false"
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamilyMono
                                font.pixelSize: Theme.textSm
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // link
                        Text {
                            visible:  _type === "link"
                            anchors.verticalCenter: parent.verticalCenter
                            width:          parent.width
                            text:           String(_rq1.modelData.value ?? "")
                            color:          Theme.primary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            elide:          Text.ElideRight

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.linkClicked(_rq1.index, String(_rq1.modelData.value ?? ""))
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible:             root.model.length === 0
            width:               _col.width
            height:              48
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            text:                root.emptyText
            color:               Theme.textDisabled
            font.family:         Theme.fontFamily
            font.pixelSize:      Theme.textSm
        }
    }
}
