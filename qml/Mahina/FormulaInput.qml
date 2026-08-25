import QtQuick
import Mahina

// Math expression input with live evaluated preview using JS Math.
//
// Usage:
//   FormulaInput {
//       formulaVars: ({ x: 5, y: 3, pi: Math.PI })
//       onEvaluated: (formula, result) => console.log(formula, "=", result)
//   }
Rectangle {
    id: root

    property var    formulaVars: ({})
    property string formulaText: ""
    property var    formulaResult: null
    property bool   hasError:    false
    property string errorText:   ""

    signal evaluated(string formula, var result)

    implicitWidth:  340
    implicitHeight: 84

    radius: Theme.radiusMd
    color:  Theme.surface
    border.color: root.hasError ? Theme.error : (_fInput.activeFocus ? Theme.primary : Theme.border)
    border.width: root.hasError || _fInput.activeFocus ? 2 : 1
    Behavior on border.color { ColorAnimation { duration: 120 } }

    function _evaluate(expr) {
        if (expr.trim() === "") {
            root.hasError   = false
            root.formulaResult = null
            return
        }
        try {
            // Build a safe math context
            var vars  = root.formulaVars
            var parts = []
            for (var k in vars) parts.push("var " + k + " = " + vars[k] + ";")
            var ctx   = parts.join(" ")
            // Replace common math names
            var safe  = expr
                .replace(/\bsin\b/g, "Math.sin")
                .replace(/\bcos\b/g, "Math.cos")
                .replace(/\btan\b/g, "Math.tan")
                .replace(/\bsqrt\b/g, "Math.sqrt")
                .replace(/\babs\b/g, "Math.abs")
                .replace(/\blog\b/g, "Math.log")
                .replace(/\bpow\b/g, "Math.pow")
                .replace(/\bfloor\b/g, "Math.floor")
                .replace(/\bceil\b/g, "Math.ceil")
                .replace(/\bround\b/g, "Math.round")
                .replace(/\bpi\b/gi, "Math.PI")
                .replace(/\be\b/g, "Math.E")
            // eslint-disable-next-line no-eval
            var res = eval(ctx + " (" + safe + ")")
            root.formulaResult = res
            root.hasError   = false
            root.errorText  = ""
            root.evaluated(expr, res)
        } catch(e) {
            root.hasError  = true
            root.errorText = e.toString().replace("EvalError: ","").replace("SyntaxError: ","")
            root.formulaResult = null
        }
    }

    Column {
        anchors { fill: parent; margins: 10 }
        spacing: 6

        // Input row
        Row {
            width: parent.width; height: 24
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           "ƒ(x)"
                color:          Theme.primary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textSm
                font.weight:    Font.Bold
            }

            TextInput {
                id:             _fInput
                anchors.verticalCenter: parent.verticalCenter
                width:          parent.width - 40
                text:           root.formulaText
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textBase
                selectByMouse:  true

                onTextChanged: {
                    root.formulaText = text
                    root._evaluate(text)
                }
            }
        }

        // Result / error
        Rectangle {
            width:  parent.width; height: 24; radius: Theme.radiusSm
            color:  root.hasError
                    ? Qt.rgba(Qt.color(Theme.error).r, Qt.color(Theme.error).g, Qt.color(Theme.error).b, 0.08)
                    : Theme.surfaceVariant

            Row {
                anchors { fill: parent; leftMargin: 8 }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "="
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (root.hasError) return root.errorText
                        if (root.formulaResult === null) return "—"
                        return root.formulaResult.toString()
                    }
                    color:          root.hasError ? Theme.error : Theme.textPrimary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                    elide:          Text.ElideRight
                    width:          parent.width - 28
                }
            }
        }
    }
}
