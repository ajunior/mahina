# Changelog

All notable changes to Mahina are documented here.

Entry prefixes: **New** (new component or asset), **Feat** (new capability on an
existing component), **Fix** (bug fix), **Break** (breaking change), **Docs**.

## 0.45.1

- **Fix** Mahina overrode the consumer's `QT_QML_OUTPUT_DIRECTORY` — it passed `OUTPUT_DIRECTORY` to `qt_add_qml_module` unconditionally, and Qt reads that argument before consulting the variable, so a consumer collecting every QML module in their build under one directory was silently ignored. Both `Mahina` and `MahinaExtras` now defer to it when set, and fall back to their previous location when it is not
- **Fix** The QML module install rule pointed at a hardcoded build path rather than asking the target where its module was written; with `QT_QML_OUTPUT_DIRECTORY` in play it would have installed nothing while still reporting success
- **Docs** README now covers declaring Mahina as a QML module dependency (`DEPENDENCIES TARGET Mahina` under policy `QTP0005`). Linking alone leaves `qmlcachegen` and `qmllint` unable to resolve any Mahina type, silently dropping every binding that touches one out of ahead-of-time compilation — worth ~48 percentage points of AOT coverage in a real consumer

## 0.45.0

- **Break** Mahina no longer builds the example app or generates install rules when it is consumed as a subproject (FetchContent / `add_subdirectory`) — new `MAHINA_EXAMPLE` and `MAHINA_INSTALL` options, both defaulting to `${PROJECT_IS_TOP_LEVEL}`. A standalone build is unaffected; a superbuild that relied on Mahina installing itself must now pass `-DMAHINA_INSTALL=ON`
- **Fix** QML module output no longer lands in the consumer's top-level build directory — `Mahina`, `MahinaExtras` and the example app used `CMAKE_BINARY_DIR` where they meant `CMAKE_CURRENT_BINARY_DIR`
- **Fix** `MahinaExtras` did not compile at all — `SyntaxHighlighter`'s header forward-declared `QQuickTextDocument` while exposing it as a `Q_PROPERTY` pointer type, and the metatype moc generates for such a property static-asserts that the pointed-to type is complete. The library has never built since it was introduced in 0.44.8; the header now includes `<QQuickTextDocument>`
- **New** IRC components — `IrcTextView` (message pane: mIRC control codes, per-nick colouring, highlights, clickable URLs, unread marker, cross-line selection), `IrcNickList` (virtualised, mode-sorted roster) and `IrcInput` (Tab-cycle nick/command completion, send history), sharing colour rules via the new `IrcPalette` singleton
- **Docs** `ModelTable`'s model contract is now documented — models must expose `display` and `isNull` roles; added `example/DemoTableModel` as a minimal conforming `QAbstractTableModel`
- **Fix** Example app failed to start — `SchemaBrowser` in `example/main.qml` still used the removed `schema` prop; migrated to `schemas`
- **Fix** Example `ModelTable` demo rendered empty — it used QML `TableModel`, which cannot supply the required `isNull` role; replaced with `DemoTableModel`

## 0.44.8 (first public release)

- **New** `ModelTable` component — themed table backed by `QAbstractItemModel`; rows stay in the C++ model with no JS array copy, uses Qt Quick's native `TableView` for virtualized rendering
- **New** `MahinaExtras` companion library — optional C++ extensions including `SyntaxHighlighter` for `CodeEditor` (13 languages)
- **New** `SidebarSection` and `SidebarEntry` layout components
- **New** `Theme.load(obj)` and `Theme.reset()` — runtime theme switching from a partial or full color schema
- **New** Bundled fonts: [Inter](https://rsms.me/inter/) (variable) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/) (variable) as official UI and mono fonts; `Theme.fontFamily` and `Theme.fontFamilyMono` are now writable and supported by `Theme.load()`
- **Fix** `Checkbox` and `Radio` label text now vertically centered with the indicator — zeroed control padding and replaced the Item wrapper with a plain Text sized to the indicator height
- **Fix** `Input` text cursor now vertically centered within the field box regardless of whether a label or helper/error text is present
- **Feat** `Toaster` gains an optional copy-to-clipboard button — pass `true` as the fourth argument to `show()` to enable it per toast
- **Fix** `Alert`, `AlertStack`, and `Toaster` are now fully square — removes the visual conflict between rounded corners and the left accent stripe
- **Fix** `AlertStack` delegate background and accent stripe are now square, consistent with `Alert` and `Toaster`
- **Docs** Reference section now shows a properties table (name, type, default, description) for 14 core components; remaining components can be filled in incrementally
- **New** `ListRow` component — list row with title, subtitle, animated hover highlight, and a trailing default-property slot for Badges, Buttons, or any item; exposes a `hovered` alias so parent delegates can conditionally show actions
- **Fix** `Theme.fontFamily` default corrected from `"Inter"` to `"Inter Variable"` to match the actual family name in the bundled variable font
- **Fix** `RulerBar`, `KeyframeEditor`, and `GradientText` now quote multi-word font family names in Canvas2D font strings — unquoted names like `Inter Variable` were being mangled to `InterVariable` by Qt's CSS font parser
- **Feat** `CodeEditor` gains find/replace — `Ctrl+F` opens a floating find bar; `Ctrl+H` opens find+replace; Enter/Shift+Enter navigates matches; Replace and Replace All buttons; match counter shows current position; Escape closes the bar
- **Feat** `CodeEditor` gains `highlightCurrentLine` prop (default `false`) — opt-in cursor-line highlight with a subtle primary-colour tint
- **Feat** `CodeEditor` gains `insertSpacesForTab` prop (default `true`) — set to `false` to insert a literal tab character instead of spaces
- **Feat** `CodeEditor` gains `lineHeight` prop (default `1.0`) — proportional line height multiplier for adjustable line spacing
- **Feat** `CodeEditor` now uses squared corners (radius 0) to match dense workspace UIs, consistent with `SchemaBrowser`
- **Feat** `CodeEditor` gains gutter decorations — set `lineDecorations` to an array of `{ line, icon, color }` objects to render status icons beside any line number (e.g. SQL execution results, linter errors, breakpoints)
- **Feat** `KeyboardShortcutsPanel` gains `closeOnEsc` prop (default `true`) — set to `false` to prevent Escape from closing the panel when the parent handles Escape globally
- **Docs** Component categories corrected: `Rating`, `EditableTable`, `CopyButton`, `FloatingActionButton` moved to Inputs; `StatusBar` moved to Layout; `FileManager`, `FloatingIsland`, `FloatingToolbar` moved to Utility
- **Docs** `Badge`, `Accordion`, and `ListRow` reference entries overhauled — corrected inaccurate descriptions and broken examples; added missing props (`backgroundOpacity` for Badge; full props table for Accordion); added `hovered`-driven example for ListRow
- **Feat** `SchemaBrowser` upgraded to a 3-level tree (schema → table → column) — `schemas` prop accepts `[{name, tables: [{name, type, columns}]}]`; schema nodes expand/collapse with animated carets and auto-expand on load
- **Feat** `SchemaBrowser` search bar gains an × clear button — appears when the field is non-empty, clears the filter on click
- **Feat** `SchemaBrowser` gains `databaseName` prop — shown in the header (e.g. `myapp_production (3)`); falls back to "Schemas" when empty
- **Break** `SchemaBrowser`: removed the legacy `schema` flat-list prop; use `schemas` with at least one schema object
