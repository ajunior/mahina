pragma ComponentBehavior: Bound
import QtQuick
import Mahina

Item {
    id: root

    property string cronExpression: "* * * * *"

    signal expressionChanged(string expr)

    implicitWidth:  440
    implicitHeight: 180

    // Parse cron into 5 fields
    property var _fields: cronExpression.split(" ").concat(["*","*","*","*","*"]).slice(0,5)

    function _rebuild(): void {
        var expr = [_mF.fieldValue, _hF.fieldValue, _dF.fieldValue, _moF.fieldValue, _wF.fieldValue].join(" ")
        root.cronExpression = expr
        root.expressionChanged(expr)
    }

    readonly property var _months: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    readonly property var _days:   ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Header with expression preview
            Rectangle {
                width: parent.width; height: 44
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                Row {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp3
                    Text {
                        text: "⏱"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Cron Expression"; color: Theme.textPrimary
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width:  _exprTxt.implicitWidth + 16; height: 28; radius: Theme.radiusSm
                        color:  Theme.panel; border.color: Theme.border; border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: _exprTxt
                            anchors.centerIn: parent
                            text:  root.cronExpression
                            color: Theme.primary
                            font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
                        }
                    }
                }
            }

            // Field labels
            Row {
                width: parent.width
                height: 24
                Repeater {
                    model: ["Minute", "Hour", "Day", "Month", "Weekday"]
                    delegate: Item {
                        id: _rq1
                        required property string modelData
                        width: parent.width / 5; height: 24
                        Text {
                            anchors.centerIn: parent
                            text:  _rq1.modelData
                            color: Theme.textSecondary
                            font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                        }
                    }
                }
            }

            // Field inputs
            Row {
                width: parent.width
                height: 48
                padding: Theme.sp3
                spacing: Theme.sp2

                CronField { id: _mF;  fieldLabel: "0-59"; fieldValue: root._fields[0]; onFieldValueChanged: root._rebuild() }
                CronField { id: _hF;  fieldLabel: "0-23"; fieldValue: root._fields[1]; onFieldValueChanged: root._rebuild() }
                CronField { id: _dF;  fieldLabel: "1-31"; fieldValue: root._fields[2]; onFieldValueChanged: root._rebuild() }
                CronField { id: _moF; fieldLabel: "1-12"; fieldValue: root._fields[3]; onFieldValueChanged: root._rebuild() }
                CronField { id: _wF;  fieldLabel: "0-6";  fieldValue: root._fields[4]; onFieldValueChanged: root._rebuild() }
            }

            // Quick presets
            Rectangle {
                width: parent.width; height: 1; color: Theme.border
            }
            Row {
                width: parent.width
                height: 44
                padding: Theme.sp3
                spacing: Theme.sp2

                Repeater {
                    model: [
                        { label: "Every min",  expr: "* * * * *"  },
                        { label: "Hourly",     expr: "0 * * * *"  },
                        { label: "Daily",      expr: "0 0 * * *"  },
                        { label: "Weekly",     expr: "0 0 * * 0"  },
                        { label: "Monthly",    expr: "0 0 1 * *"  },
                    ]
                    delegate: Rectangle {
                        id: _rq2
                        required property var  modelData
                        required property int  index
                        width:  (parent.width - 24 - Theme.sp2 * 4) / 5
                        height: 28; radius: Theme.radiusSm
                        color:  _pstH.hovered ? Theme.panel : "transparent"
                        border.color: Theme.border; border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }
                        HoverHandler { id: _pstH }
                        Text {
                            anchors.centerIn: parent
                            text:  _rq2.modelData.label
                            color: Theme.textPrimary
                            font { family: Theme.fontFamily; pixelSize: 11 }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.cronExpression = _rq2.modelData.expr
                                root.expressionChanged(_rq2.modelData.expr)
                            }
                        }
                    }
                }
            }
        }
    }

    component CronField: Rectangle {
        id: _field
        property string fieldLabel: "*"
        property string fieldValue: "*"

        width:  (root.width - Theme.sp3 * 2 - Theme.sp2 * 4) / 5
        height: 36
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: _cfInput.activeFocus ? Theme.primary : Theme.border
        border.width: _cfInput.activeFocus ? 2 : 1

        TextInput {
            id:    _cfInput
            anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            text:  _field.fieldValue
            color: Theme.textPrimary
            font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm }
            selectByMouse: true
            onTextChanged: {
                if (text !== _field.fieldValue) {
                    _field.fieldValue = text
                }
            }
        }

        Text {
            anchors { bottom: parent.bottom; bottomMargin: -Theme.sp4; horizontalCenter: parent.horizontalCenter }
            text:  _field.fieldLabel
            color: Theme.textDisabled
            font { family: Theme.fontFamily; pixelSize: 10 }
        }
    }
}
