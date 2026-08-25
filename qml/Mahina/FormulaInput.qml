import QtQuick
import Mahina

// Math expression input with live evaluated preview.
//
// The expression is parsed, not evaluated as JavaScript: only numbers, the
// arithmetic operators, and names drawn from formulaVars and a fixed table of
// maths functions and constants are accepted. Anything else is a syntax error.
// So formulaText and formulaVars may be bound to input the application does not
// control.
//
// Usage:
//   FormulaInput {
//       formulaVars: ({ x: 5, y: 3 })
//       onEvaluated: (formula, result) => console.log(formula, "=", result)
//   }
//
// Supported: + - * / % ^, parentheses, and
//   sin cos tan asin acos atan atan2 sqrt cbrt abs exp log log2 log10
//   pow hypot floor ceil round trunc sign min max   (min/max/hypot variadic)
//   pi e tau                                        (case-insensitive)
// A key in formulaVars shadows a constant of the same name.
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

    // ── Evaluation ───────────────────────────────────────────────────────────
    //
    // A tokeniser plus a recursive-descent parser, rather than eval(). This
    // component's whole input surface is a string, and a consumer is free to
    // bind it to a document, a config file or a network payload; handing that
    // to the JS engine would hand over the QML scope with it -- Qt, and through
    // Qt anything Qt can reach. Nothing here is ever executed as code: the
    // tokeniser admits one closed set of characters, and every identifier is
    // resolved against the tables below.

    readonly property var _functions: ({
        "sin":   { f: Math.sin,   n:  1 },
        "cos":   { f: Math.cos,   n:  1 },
        "tan":   { f: Math.tan,   n:  1 },
        "asin":  { f: Math.asin,  n:  1 },
        "acos":  { f: Math.acos,  n:  1 },
        "atan":  { f: Math.atan,  n:  1 },
        "atan2": { f: Math.atan2, n:  2 },
        "sqrt":  { f: Math.sqrt,  n:  1 },
        "cbrt":  { f: Math.cbrt,  n:  1 },
        "abs":   { f: Math.abs,   n:  1 },
        "exp":   { f: Math.exp,   n:  1 },
        "log":   { f: Math.log,   n:  1 },
        "log2":  { f: Math.log2,  n:  1 },
        "log10": { f: Math.log10, n:  1 },
        "pow":   { f: Math.pow,   n:  2 },
        "floor": { f: Math.floor, n:  1 },
        "ceil":  { f: Math.ceil,  n:  1 },
        "round": { f: Math.round, n:  1 },
        "trunc": { f: Math.trunc, n:  1 },
        "sign":  { f: Math.sign,  n:  1 },
        "min":   { f: Math.min,   n: -1 },   // -1: variadic, at least one
        "max":   { f: Math.max,   n: -1 },
        "hypot": { f: Math.hypot, n: -1 }
    })

    readonly property var _constants: ({
        "pi":  Math.PI,
        "e":   Math.E,
        "tau": 2 * Math.PI
    })

    // Guards against a pathologically nested expression exhausting the JS stack.
    readonly property int _maxDepth: 64

    function _has(obj: var, key: string): bool {
        return Object.prototype.hasOwnProperty.call(obj, key)
    }

    function _tokenize(src: string): var {
        var toks = []
        var i    = 0
        while (i < src.length) {
            var c = src.charAt(i)
            if (c === " " || c === "\t" || c === "\n" || c === "\r") { i++; continue }

            var rest = src.substring(i)
            var m
            if ((c >= "0" && c <= "9") || c === ".") {
                m = /^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?/.exec(rest)
                if (!m) throw new Error("malformed number")
                toks.push({ t: "num", v: parseFloat(m[0]) })
                i += m[0].length
                continue
            }
            if (/^[A-Za-z_]/.test(c)) {
                m = /^[A-Za-z_][A-Za-z_0-9]*/.exec(rest)
                toks.push({ t: "id", v: m[0] })
                i += m[0].length
                continue
            }
            if ("+-*/%^(),".indexOf(c) !== -1) { toks.push({ t: c }); i++; continue }

            throw new Error("unexpected character " + JSON.stringify(c))
        }
        return toks
    }

    function _resolveName(name: string): real {
        var vars = root.formulaVars
        if (vars && root._has(vars, name)) {
            var n = Number(vars[name])
            if (isNaN(n)) throw new Error(name + " is not a number")
            return n
        }
        var lower = name.toLowerCase()
        if (root._has(root._constants, lower)) return root._constants[lower]
        throw new Error("unknown name " + name)
    }

    function _callFunction(name: string, args: var): real {
        var lower = name.toLowerCase()
        if (!root._has(root._functions, lower)) throw new Error("unknown function " + name)
        var spec = root._functions[lower]
        if (spec.n >= 0 && args.length !== spec.n)
            throw new Error(name + " takes " + spec.n + (spec.n === 1 ? " argument" : " arguments"))
        if (spec.n < 0 && args.length === 0)
            throw new Error(name + " needs at least one argument")
        return spec.f.apply(null, args)
    }

    // expr  := term (('+' | '-') term)*
    // term  := unary (('*' | '/' | '%') unary)*
    // unary := ('+' | '-') unary | power
    // power := primary ('^' unary)?        -- right-associative, so 2^-3 parses
    // prim  := num | '(' expr ')' | id | id '(' expr (',' expr)* ')'
    function _parseTokens(toks: var): real {
        var pos   = 0
        var depth = 0

        function peek() { return pos < toks.length ? toks[pos] : null }
        function take() { return toks[pos++] }
        function expect(t) {
            var tok = peek()
            if (!tok || tok.t !== t) throw new Error("expected " + t)
            return take()
        }
        function describe(tok) {
            return tok.v !== undefined ? String(tok.v) : tok.t
        }

        function expr() {
            if (++depth > root._maxDepth) throw new Error("expression nested too deeply")
            var v = term()
            for (;;) {
                var tok = peek()
                if      (tok && tok.t === "+") { take(); v = v + term() }
                else if (tok && tok.t === "-") { take(); v = v - term() }
                else { depth--; return v }
            }
        }
        function term() {
            var v = unary()
            for (;;) {
                var tok = peek()
                if      (tok && tok.t === "*") { take(); v = v * unary() }
                else if (tok && tok.t === "/") { take(); v = v / unary() }
                else if (tok && tok.t === "%") { take(); v = v % unary() }
                else return v
            }
        }
        function unary() {
            var tok = peek()
            if (tok && tok.t === "-") { take(); return -unary() }
            if (tok && tok.t === "+") { take(); return  unary() }
            return power()
        }
        function power() {
            var base = primary()
            var tok  = peek()
            if (tok && tok.t === "^") { take(); return Math.pow(base, unary()) }
            return base
        }
        function primary() {
            var tok = peek()
            if (!tok) throw new Error("unexpected end of expression")

            if (tok.t === "num") { take(); return tok.v }

            if (tok.t === "(") {
                take()
                var v = expr()
                expect(")")
                return v
            }

            if (tok.t === "id") {
                take()
                if (peek() && peek().t === "(") {
                    take()
                    var args = []
                    if (!peek() || peek().t !== ")") {
                        args.push(expr())
                        while (peek() && peek().t === ",") { take(); args.push(expr()) }
                    }
                    expect(")")
                    return root._callFunction(tok.v, args)
                }
                return root._resolveName(tok.v)
            }

            throw new Error("unexpected " + describe(tok))
        }

        var result = expr()
        if (pos < toks.length) throw new Error("unexpected " + describe(peek()))
        return result
    }

    function _evaluate(expr: string) {
        if (expr.trim() === "") {
            root.hasError      = false
            root.errorText     = ""
            root.formulaResult = null
            return
        }
        try {
            var res = root._parseTokens(root._tokenize(expr))
            root.formulaResult = res
            root.hasError      = false
            root.errorText     = ""
            root.evaluated(expr, res)
        } catch(e) {
            root.hasError      = true
            root.errorText     = e.message !== undefined ? e.message : String(e)
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
