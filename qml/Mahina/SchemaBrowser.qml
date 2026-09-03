pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────

    // [{name, tables: [{name, type, columns: [{name, type, pk, fk, nullable}]}]}]
    property var schemas: []

    property string databaseName:     ""
    // The selected table, as the pair that actually identifies one: two schemas
    // may each hold a "users", and highlighting both was the visible half of a
    // tree that only ever reported the table's name to its host.
    property string activeTable:      ""
    property string activeSchema:     ""
    property string searchText:       ""
    property bool   showBrowseAction: false

    // A frame of its own is right when this sits on a page by itself and
    // wrong inside a SplitPane, where the divider already draws that line:
    // the two together make a 2px seam sitting next to the 1px ones the rest
    // of the window uses. The host turns it off, and the seam then belongs to
    // whatever is between the panels rather than to the panels themselves.
    property bool   framed: true

    // Every one of these carries the schema the row lives under. A bare table
    // name is not an address: the host has to qualify it before it can put it
    // in an editor or run it, and it cannot recover a schema the tree knew and
    // did not pass on.
    signal schemaDoubleClicked(string schema)
    signal tableSelected(string schema, string name)
    signal columnClicked(string schema, string table, string column)
    signal tableDoubleClicked(string schema, string name)
    signal columnDoubleClicked(string schema, string table, string column)
    signal tableQuickBrowseRequested(string schema, string name)
    signal tableStatsRequested(string schema, string name)
    signal tableDdlRequested(string schema, string name)
    // The host owns the clipboard: a browser that reaches for it would be
    // deciding, on the host's behalf, whether the name it copies is worth
    // qualifying with its schema.
    signal tableCopyNameRequested(string schema, string name)
    signal schemaCopyNameRequested(string schema)

    // ── Internal ──────────────────────────────────────────────────────────────
    readonly property int _tableCount: {
        var n = 0
        for (var i = 0; i < schemas.length; i++) n += (schemas[i].tables || []).length
        return n
    }

    // ── Expansion state ───────────────────────────────────────────────────────
    // Keys: "s::<schemaName>" for schemas, "t::<schemaName>::<tableName>" for tables
    property var _expanded: ({})

    // Auto-expand new schemas when the schemas prop changes
    onSchemasChanged: {
        var e = Object.assign({}, root._expanded)
        for (var i = 0; i < schemas.length; i++) {
            var key = "s::" + schemas[i].name
            if (e[key] === undefined) e[key] = true
        }
        root._expanded = e
    }

    function _toggleSchema(name: var): void {
        var e = Object.assign({}, root._expanded)
        e["s::" + name] = !e["s::" + name]
        root._expanded = e
    }

    function _toggleTable(schemaName: var, tableName: var): void {
        var e = Object.assign({}, root._expanded)
        var key = "t::" + schemaName + "::" + tableName
        e[key] = !e[key]
        root._expanded = e
    }

    function _isSchemaExpanded(name: var): var {
        return root._expanded["s::" + name] !== false
    }

    function _isTableExpanded(schemaName: var, tableName: var): var {
        return root._expanded["t::" + schemaName + "::" + tableName] === true
    }

    function _filteredTables(tables: var): var {
        var q = root.searchText.toLowerCase()
        if (!q) return tables || []
        return (tables || []).filter(function(t) {
            if (t.name.toLowerCase().indexOf(q) >= 0) return true
            return t.columns && t.columns.some(function(c) {
                return c.name.toLowerCase().indexOf(q) >= 0
            })
        })
    }

    function _tableIcon(type: var): var {
        if (type === "view")  return Icons.eye
        if (type === "index") return Icons.hash
        return Icons.table
    }

    function _colIcon(col: var): var {
        if (col.pk)       return "🔑"
        if (col.fk)       return "🔗"
        if (col.nullable) return "◌"
        return "◆"
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    implicitWidth:  260
    implicitHeight: 380

    Rectangle {
        anchors.fill: parent
        color:        Theme.surface
        border.color: Theme.border
        border.width: root.framed ? 1 : 0
        radius:       0
        clip:         true

        Column {
            anchors.fill: parent
            spacing:      0

            // ── Header ────────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 36
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                Row {
                    anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Icon { name: Icons.database; size: 14; color: Theme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text:  root.databaseName || "Schemas"
                        color: Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: Font.Medium }
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        text:  "(" + root.schemas.length + ")"
                        color: Theme.textDisabled
                        font { family: Theme.fontFamily; pixelSize: 11 }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── Search ────────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 32
                color: "transparent"
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                Row {
                    anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                    spacing: Theme.sp2
                    Icon { name: Icons.magnifyingGlass; size: 12; color: Theme.textDisabled; anchors.verticalCenter: parent.verticalCenter }
                    TextInput {
                        id:    _sbSearch
                        width: parent.width - 12 - Theme.sp2 - (_sbSearch.text !== "" ? 16 + Theme.sp2 : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.textPrimary
                        font  { family: Theme.fontFamily; pixelSize: Theme.textSm }
                        onTextChanged: root.searchText = text
                        Text {
                            visible: _sbSearch.text === ""
                            text:    "Search tables…"
                            color:   Theme.textDisabled
                            font:    _sbSearch.font
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Item {
                        width: 16; height: 16
                        visible: _sbSearch.text !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        HoverHandler { id: _xHov }
                        Icon { anchors.centerIn: parent; name: Icons.x; size: 11; color: _xHov.hovered ? Theme.textSecondary : Theme.textDisabled }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _sbSearch.text = "" }
                    }
                }
            }

            // ── Tree ──────────────────────────────────────────────────────────
            Flickable {
                width:         parent.width
                height:        root.height - 36 - 32
                contentHeight: _treeCol.implicitHeight
                clip:          true
                QQC.ScrollBar.vertical: QQC.ScrollBar {}

                Column {
                    id:    _treeCol
                    width: parent.width

                    Repeater {
                        model: root.schemas

                        delegate: Column {
                            id:    _sDel
                            required property var modelData
                            required property int index
                            width: parent ? parent.width : 0

                            readonly property var    _sb:        root
                            readonly property string _sName:     modelData.name
                            readonly property bool   _sExpanded: root._isSchemaExpanded(_sName)
                            readonly property var    _sTables:   root._filteredTables(modelData.tables)

                            // ── Schema row ────────────────────────────────────
                            Rectangle {
                                width:   parent.width; height: 30
                                color:   _schHov.hovered ? Theme.hover : "transparent"
                                HoverHandler { id: _schHov }
                                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                                Row {
                                    anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                                    spacing: Theme.sp2

                                    Icon {
                                        name:     Icons.caretRight
                                        size:     10
                                        color:    Theme.textSecondary
                                        rotation: _sDel._sExpanded ? 90 : 0
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on rotation { NumberAnimation { duration: Theme.durationFast } }
                                    }
                                    // A schema is not a database. The two rows sat under the
                                    // same cylinder, so the tree read as a database holding
                                    // databases — and the one thing a reader needs from this
                                    // row is which of the two levels they are looking at.
                                    Icon { name: Icons.treeStructure; size: 13; color: Theme.primary; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text:  _sDel._sName
                                        color: Theme.textPrimary
                                        font { family: Theme.fontFamilyMono; pixelSize: Theme.textSm; weight: Font.Medium }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text:  "(" + _sDel._sTables.length + ")"
                                        color: Theme.textDisabled
                                        font  { family: Theme.fontFamily; pixelSize: 10 }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: _sDel._sb._toggleSchema(_sDel._sName)
                                    // The two clicks that precede it have already
                                    // toggled the schema open and shut again, so the
                                    // row is left exactly as it was found.
                                    onDoubleClicked: _sDel._sb.schemaDoubleClicked(_sDel._sName)
                                }

                                // ··· menu (hover-only), matching the table rows.
                                // Declared after the row's MouseArea so it sits on
                                // top of it: a click here must not also collapse
                                // the schema underneath.
                                Rectangle {
                                    id: _schMoreBtn
                                    visible: _schHov.hovered
                                    anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                                    width: 22; height: 22; radius: Theme.radiusSm
                                    color: _schMoreHov.hovered ? Theme.hover : "transparent"
                                    HoverHandler { id: _schMoreHov }
                                    Icon { anchors.centerIn: parent; name: Icons.dotsThree; size: 13; color: Theme.textSecondary }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: (mouse) => {
                                            mouse.accepted = true
                                            _schMoreMenu.open()
                                        }
                                    }
                                    Menu {
                                        id:     _schMoreMenu
                                        anchor: _schMoreBtn
                                        model: [
                                            { label: "Copy name", icon: Icons.copy, act: "copy" },
                                        ]
                                        onTriggered: (index, item) => {
                                            if (item.act === "copy")
                                                _sDel._sb.schemaCopyNameRequested(_sDel._sName)
                                        }
                                    }
                                }
                            }

                            // ── Tables (visible when schema expanded) ─────────
                            Column {
                                visible: _sDel._sExpanded
                                width:   parent.width

                                Repeater {
                                    model: _sDel._sTables

                                    delegate: Column {
                                        id:    _tDel
                                        required property var modelData
                                        required property int index
                                        width: parent ? parent.width : 0

                                        readonly property var    _sb:        _sDel._sb
                                        readonly property string _tName:     modelData.name
                                        readonly property string _sName:     _sDel._sName
                                        readonly property bool   _active:    modelData.name === root.activeTable
                                                                                 && _sDel._sName === root.activeSchema
                                        readonly property bool   _tExpanded: root._isTableExpanded(_sName, _tName)
                                        readonly property int    _indent:    Theme.sp4 + Theme.sp2

                                        // Table row
                                        Rectangle {
                                            width:  parent.width; height: 32
                                            color:  _tDel._active
                                                    ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10)
                                                    : (_tblH.hovered ? Theme.hover : "transparent")
                                            HoverHandler { id: _tblH }
                                            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }

                                            Row {
                                                anchors { left: parent.left; leftMargin: _tDel._indent; verticalCenter: parent.verticalCenter }
                                                spacing: Theme.sp2

                                                Icon {
                                                    name:     Icons.caretRight
                                                    size:     10
                                                    color:    Theme.textSecondary
                                                    rotation: _tDel._tExpanded ? 90 : 0
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    Behavior on rotation { NumberAnimation { duration: Theme.durationFast } }
                                                }
                                                Icon {
                                                    name:  root._tableIcon(_tDel.modelData.type)
                                                    size:  13
                                                    color: _tDel.modelData.type === "view" ? Theme.info : Theme.primary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text:  _tDel._tName
                                                    color: _tDel._active ? Theme.primary : Theme.textPrimary
                                                    font  { family: Theme.fontFamilyMono; pixelSize: Theme.textSm; weight: _tDel._active ? Font.Medium : Font.Normal }
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text:  _tDel.modelData.columns ? "(" + _tDel.modelData.columns.length + ")" : ""
                                                    color: Theme.textDisabled
                                                    font  { family: Theme.fontFamily; pixelSize: 10 }
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    _tDel._sb._toggleTable(_tDel._sName, _tDel._tName)
                                                    _tDel._sb.activeTable  = _tDel._tName
                                                    _tDel._sb.activeSchema = _tDel._sName
                                                    _tDel._sb.tableSelected(_tDel._sName, _tDel._tName)
                                                }
                                                onDoubleClicked: _tDel._sb.tableDoubleClicked(_tDel._sName, _tDel._tName)
                                            }

                                            // ··· context menu button (hover-only)
                                            Rectangle {
                                                id: _moreBtn
                                                visible: _tblH.hovered
                                                anchors {
                                                    right: parent.right
                                                    rightMargin: root.showBrowseAction ? 32 : 6
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                width: 22; height: 22; radius: Theme.radiusSm
                                                color: _statsHov.hovered ? Theme.hover : "transparent"
                                                HoverHandler { id: _statsHov }
                                                Icon { anchors.centerIn: parent; name: Icons.dotsThree; size: 13; color: Theme.textSecondary }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: (mouse) => {
                                                        mouse.accepted = true
                                                        _moreMenu.open()
                                                    }
                                                }
                                                Menu {
                                                    id:     _moreMenu
                                                    anchor: _moreBtn
                                                    model: [
                                                        { label: "Copy name",  icon: Icons.copy,     act: "copy"  },
                                                        { label: "Statistics", icon: Icons.chartBar, act: "stats" },
                                                        { label: "View DDL",   icon: Icons.code,     act: "ddl"   },
                                                    ]
                                                    // On the act rather than the index: the
                                                    // handler used to say "index 0 means
                                                    // Statistics", which stops being true the
                                                    // moment an entry is added above it.
                                                    onTriggered: (index, item) => {
                                                        const sb = _tDel._sb
                                                        switch (item.act) {
                                                        case "copy":  sb.tableCopyNameRequested(_tDel._sName, _tDel._tName); break
                                                        case "stats": sb.tableStatsRequested(_tDel._sName, _tDel._tName);    break
                                                        case "ddl":   sb.tableDdlRequested(_tDel._sName, _tDel._tName);      break
                                                        }
                                                    }
                                                }
                                            }

                                            // Quick-browse play button (hover-only)
                                            Rectangle {
                                                visible: root.showBrowseAction && _tblH.hovered
                                                anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                                                width: 22; height: 22; radius: Theme.radiusSm
                                                color: _browseHov.hovered
                                                       ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.18)
                                                       : Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.08)
                                                HoverHandler { id: _browseHov }
                                                Icon { anchors.centerIn: parent; name: Icons.play; size: 11; color: Theme.primary }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: (mouse) => {
                                                        mouse.accepted = true
                                                        _tDel._sb.tableQuickBrowseRequested(_tDel._sName, _tDel._tName)
                                                    }
                                                }
                                            }
                                        }

                                        // ── Columns (visible when table expanded) ──
                                        Column {
                                            visible: _tDel._tExpanded
                                            width:   parent.width

                                            Repeater {
                                                model: _tDel.modelData.columns || []
                                                delegate: Rectangle {
                                                    id:    _cDel
                                                    required property var modelData
                                                    required property int index
                                                    width:  parent ? parent.width : 0; height: 26

                                                    readonly property var _sb: _tDel._sb
                                                    color:  _colH.hovered ? Theme.hover : "transparent"
                                                    HoverHandler { id: _colH }
                                                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border; opacity: 0.5 }

                                                    Row {
                                                        anchors { left: parent.left; leftMargin: _tDel._indent + 24; verticalCenter: parent.verticalCenter }
                                                        spacing: Theme.sp2

                                                        Text {
                                                            text:  root._colIcon(_cDel.modelData)
                                                            color: _cDel.modelData.pk ? Theme.warning : (_cDel.modelData.fk ? Theme.info : Theme.textDisabled)
                                                            font.pixelSize: 9
                                                            width: 14
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                        Text {
                                                            text:  _cDel.modelData.name
                                                            color: Theme.textPrimary
                                                            font  { family: Theme.fontFamilyMono; pixelSize: 12 }
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                        Text {
                                                            text:  _cDel.modelData.type || ""
                                                            color: Theme.textDisabled
                                                            font  { family: Theme.fontFamily; pixelSize: 10 }
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                        Text {
                                                            visible: _cDel.modelData.nullable === false
                                                            text:    "NOT NULL"
                                                            color:   Theme.error
                                                            font     { family: Theme.fontFamily; pixelSize: 9 }
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                        onClicked:       _cDel._sb.columnClicked(_tDel._sName, _tDel._tName, _cDel.modelData.name)
                                                        onDoubleClicked: _cDel._sb.columnDoubleClicked(_tDel._sName, _tDel._tName, _cDel.modelData.name)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
