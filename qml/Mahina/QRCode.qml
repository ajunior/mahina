pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// QR Code renderer (byte mode, Level L, versions 1–4).
// Handles strings up to ~78 characters. Renders on a Canvas.
//
// Usage:
//   QRCode { text: "https://example.com"; size: 200 }
//   QRCode { text: email; size: 160; darkColor: "#000"; lightColor: "#fff"; quietZone: 3 }
Item {
    id: root

    property string text:       ""
    property real   size:       200
    property color  darkColor:  Theme.textPrimary
    property color  lightColor: Theme.surface
    property int    quietZone:  4   // modules of white border

    implicitWidth:  root.size
    implicitHeight: root.size

    width:  root.size
    height: root.size

    Canvas {
        id:           _canvas
        anchors.fill: parent
        renderTarget: Canvas.Image

        Connections {
            target: root
            function onTextChanged()      { _canvas.requestPaint() }
            function onDarkColorChanged() { _canvas.requestPaint() }
            function onLightColorChanged(){ _canvas.requestPaint() }
            function onSizeChanged()      { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (root.text === "") {
                ctx.fillStyle = root.lightColor.toString()
                ctx.fillRect(0, 0, width, height)
                return
            }

            var matrix = _makeQR(root.text)
            if (!matrix) {
                ctx.fillStyle = root.lightColor.toString()
                ctx.fillRect(0, 0, width, height)
                return
            }

            var n      = matrix.length
            var total  = n + root.quietZone * 2
            var cell   = width / total

            ctx.fillStyle = root.lightColor.toString()
            ctx.fillRect(0, 0, width, height)

            ctx.fillStyle = root.darkColor.toString()
            for (var r = 0; r < n; r++) {
                for (var c = 0; c < n; c++) {
                    if (matrix[r][c]) {
                        var x = (c + root.quietZone) * cell
                        var y = (r + root.quietZone) * cell
                        ctx.fillRect(x, y, cell, cell)
                    }
                }
            }
        }

        // ── QR encoder ───────────────────────────────────────────────────────
        function _makeQR(str) {
            // Version table [size, dataCodewords, ecCodewords] for Level L
            var VER = [[21,19,7],[25,34,10],[29,55,15],[33,80,20]]

            // Encode as UTF-8 bytes
            var bytes = []
            for (var i = 0; i < str.length; i++) {
                var cp = str.charCodeAt(i)
                if (cp < 0x80) { bytes.push(cp) }
                else if (cp < 0x800) { bytes.push(0xC0|(cp>>6)); bytes.push(0x80|(cp&0x3F)) }
                else { bytes.push(0xE0|(cp>>12)); bytes.push(0x80|((cp>>6)&0x3F)); bytes.push(0x80|(cp&0x3F)) }
            }

            // Pick version
            var ver = -1
            for (var v = 0; v < VER.length; v++) {
                if (bytes.length <= VER[v][1] - 3) { ver = v; break }
            }
            if (ver === -1) return null  // too long

            var sz   = VER[ver][0]
            var dcw  = VER[ver][1]
            var eccw = VER[ver][2]

            // GF(256) tables
            var EXP = [], LOG = new Array(256).fill(0)
            var x = 1
            for (var i2 = 0; i2 < 255; i2++) {
                EXP.push(x); LOG[x] = i2
                x = (x * 2) ^ (x >= 128 ? 0x11d : 0)
            }
            EXP.push(1)
            for (var j2 = 256; j2 < 512; j2++) EXP.push(EXP[j2-255])

            function gfMul(a, b) { return a && b ? EXP[LOG[a] + LOG[b]] : 0 }

            function rsGen(n) {
                var g = [1]
                for (var k = 0; k < n; k++) {
                    var ng = new Array(g.length + 1).fill(0)
                    for (var m = 0; m < g.length; m++) {
                        ng[m]   ^= gfMul(g[m], EXP[k])
                        ng[m+1] ^= g[m]
                    }
                    g = ng
                }
                return g
            }

            function rsEncode(data, n) {
                var g   = rsGen(n)
                var msg = data.slice().concat(new Array(n).fill(0))
                for (var i3 = 0; i3 < data.length; i3++) {
                    var c = msg[i3]
                    if (c) for (var j3 = 0; j3 < g.length; j3++) msg[i3+j3] ^= gfMul(g[j3], c)
                }
                return msg.slice(data.length)
            }

            // Build bit stream
            var bits = []
            function pushBits(val, len) {
                for (var b = len - 1; b >= 0; b--) bits.push((val >> b) & 1)
            }
            pushBits(0b0100, 4)                 // byte mode indicator
            pushBits(bytes.length, 8)            // character count
            for (var i4 = 0; i4 < bytes.length; i4++) pushBits(bytes[i4], 8)
            pushBits(0, 4)                       // terminator
            while (bits.length % 8 !== 0) bits.push(0)

            // Pad to data capacity
            var dataBits = dcw * 8
            var padBytes = [0xEC, 0x11]
            var pi2 = 0
            while (bits.length < dataBits) { pushBits(padBytes[pi2 % 2], 8); pi2++ }

            // Data codewords
            var dataCW = []
            for (var i5 = 0; i5 < dcw; i5++) {
                var byte2 = 0
                for (var b2 = 0; b2 < 8; b2++) byte2 = (byte2 << 1) | (bits[i5*8+b2] || 0)
                dataCW.push(byte2)
            }
            var ecCW = rsEncode(dataCW, eccw)

            // All codewords
            var allCW = dataCW.concat(ecCW)
            var allBits = []
            for (var i6 = 0; i6 < allCW.length; i6++) pushBits2(allCW[i6], 8)
            function pushBits2(val, len) {
                for (var b3 = len - 1; b3 >= 0; b3--) allBits.push((val >> b3) & 1)
            }

            // ── Matrix construction ────────────────────────────────────────────
            var mat  = []
            var used = []
            for (var r = 0; r < sz; r++) {
                mat.push(new Array(sz).fill(0))
                used.push(new Array(sz).fill(false))
            }

            function setMod(r2, c2, v, isFixed) {
                if (r2 < 0 || r2 >= sz || c2 < 0 || c2 >= sz) return
                mat[r2][c2]  = v
                if (isFixed) used[r2][c2] = true
            }

            // Finder pattern (7x7 with separator)
            function finder(tr, tc) {
                for (var dr = 0; dr < 7; dr++) for (var dc = 0; dc < 7; dc++) {
                    var ring = Math.max(Math.abs(dr-3), Math.abs(dc-3))
                    setMod(tr+dr, tc+dc, ring === 0 || ring === 2 || ring === 3 ? 0 : 1, true)
                }
                // separator
                for (var s = -1; s <= 7; s++) {
                    setMod(tr+7, tc+s, 0, true); setMod(tr-1, tc+s, 0, true)
                    setMod(tr+s, tc+7, 0, true); setMod(tr+s, tc-1, 0, true)
                }
            }
            finder(0, 0); finder(0, sz-7); finder(sz-7, 0)

            // Timing
            for (var t = 8; t < sz - 8; t++) {
                setMod(6, t, t%2===0 ? 1 : 0, true)
                setMod(t, 6, t%2===0 ? 1 : 0, true)
            }

            // Dark module
            setMod(sz-8, 8, 1, true)

            // Alignment (version 2+)
            var ALIGN_POS = [[],[6,18],[6,22],[6,26]]
            var ap = ALIGN_POS[ver]
            for (var ai = 0; ai < ap.length; ai++) for (var aj = 0; aj < ap.length; aj++) {
                var ar = ap[ai], ac = ap[aj]
                if (used[ar][ac]) continue
                for (var dr2 = -2; dr2 <= 2; dr2++) for (var dc2 = -2; dc2 <= 2; dc2++) {
                    var ring2 = Math.max(Math.abs(dr2), Math.abs(dc2))
                    setMod(ar+dr2, ac+dc2, ring2===0||ring2===2 ? 1 : 0, true)
                }
            }

            // Format info placeholders (mark as used)
            var fmtCells = [
                [8,0],[8,1],[8,2],[8,3],[8,4],[8,5],[8,7],[8,8],
                [7,8],[5,8],[4,8],[3,8],[2,8],[1,8],[0,8],
                [sz-1,8],[sz-2,8],[sz-3,8],[sz-4,8],[sz-5,8],[sz-6,8],[sz-7,8],
                [8,sz-8],[8,sz-7],[8,sz-6],[8,sz-5],[8,sz-4],[8,sz-3],[8,sz-2],[8,sz-1]
            ]
            for (var fi = 0; fi < fmtCells.length; fi++) used[fmtCells[fi][0]][fmtCells[fi][1]] = true

            // Place data bits in zigzag
            var bi = 0
            var col2 = sz - 1
            var dir  = -1  // -1 = up
            while (col2 >= 0) {
                if (col2 === 6) { col2--; continue }
                for (var rr = 0; rr < sz; rr++) {
                    var row2 = dir === -1 ? sz - 1 - rr : rr
                    for (var cc = col2; cc >= col2 - 1; cc--) {
                        if (!used[row2][cc] && bi < allBits.length) {
                            mat[row2][cc] = allBits[bi++]
                        }
                    }
                }
                col2 -= 2
                dir = -dir
            }

            // Apply mask 0: (r+c) % 2 === 0
            for (var mr = 0; mr < sz; mr++) for (var mc = 0; mc < sz; mc++) {
                if (!used[mr][mc] && (mr + mc) % 2 === 0) mat[mr][mc] ^= 1
            }

            // BCH format info
            function bch(data) {
                var d = data << 10
                for (var ii = 14; ii >= 10; ii--) {
                    if (d & (1 << ii)) d ^= (0x537 << (ii - 10))
                }
                return ((data << 10) | (d & 0x3ff)) ^ 0x5412
            }
            // Level L = 1, mask 0 = 0  → data = 0b01_000 = 8
            var fmt = bch(8)  // Level L, mask 0

            var fmtBits = []
            for (var fb = 14; fb >= 0; fb--) fmtBits.push((fmt >> fb) & 1)

            var fmtLeft = [[8,0],[8,1],[8,2],[8,3],[8,4],[8,5],[8,7],[8,8],[7,8],[5,8],[4,8],[3,8],[2,8],[1,8],[0,8]]
            var fmtRight = [[sz-1,8],[sz-2,8],[sz-3,8],[sz-4,8],[sz-5,8],[sz-6,8],[sz-7,8],[8,sz-8],[8,sz-7],[8,sz-6],[8,sz-5],[8,sz-4],[8,sz-3],[8,sz-2],[8,sz-1]]

            for (var fj = 0; fj < 15; fj++) {
                mat[fmtLeft[fj][0]][fmtLeft[fj][1]]   = fmtBits[fj]
                mat[fmtRight[fj][0]][fmtRight[fj][1]] = fmtBits[fj]
            }

            // Invert dark/light (QR: 1 = dark module)
            var out = []
            for (var r3 = 0; r3 < sz; r3++) {
                out.push([])
                for (var c3 = 0; c3 < sz; c3++) out[r3].push(mat[r3][c3] === 1)
            }
            return out
        }
    }
}
