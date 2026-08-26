pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Breadcrumb navigation trail.
//
// Usage:
//   Breadcrumb {
//       model: ["Home", "Products", "Electronics"]
//       onCrumbClicked: (i) => navigate(model[i])
//   }
//
//   // Object model with labels:
//   Breadcrumb {
//       model: [{ label: "Home" }, { label: "Settings" }, { label: "Account" }]
//   }
//
//   // Custom separator:
//   Breadcrumb { model: ["Root", "Child"]; separator: "›" }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:     []
    property string separator: "/"

    signal crumbClicked(int index)

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    RowLayout {
        id:      _row
        spacing: 0

        Repeater {
            model: root.model

            delegate: RowLayout {
                id:       _item
                required property var modelData
                required property int index

                spacing: Theme.sp2

                readonly property bool isLast:  index === root.model.length - 1
                readonly property string label: typeof modelData === "string"
                                                ? modelData : (modelData.label ?? "")

                // Separator (hidden before first crumb)
                Text {
                    visible:        _item.index > 0
                    text:           root.separator
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }

                // Crumb label
                Item {
                    id:             _crumbItem
                    implicitWidth:  _label.implicitWidth
                    implicitHeight: _label.implicitHeight
                    // Local hover flag avoids undefined forward-reference to HoverHandler
                    property bool _hov: false

                    Text {
                        id:             _label
                        text:           _item.label
                        color:          _item.isLast ? Theme.textPrimary
                                      : _crumbItem._hov ? Theme.primary
                                      : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    _item.isLast ? Theme.weightMedium : Theme.weightRegular

                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    }

                    // Underline on hover for non-last crumbs
                    Rectangle {
                        visible:  !_item.isLast && _crumbItem._hov
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1
                        color:  Theme.primary
                    }

                    HoverHandler {
                        enabled:          !_item.isLast
                        onHoveredChanged: _crumbItem._hov = hovered
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled:      !_item.isLast
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.crumbClicked(_item.index)
                    }
                }
            }
        }
    }
}
