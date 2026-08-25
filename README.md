# Mahina

A comprehensive QML component library for Qt 6 desktop applications — fully themed, AOT-compiled, and keyboard-friendly.

![Mahina preview](screenshot.png)

## Features

- **262 components** covering layout, navigation, data display, forms, charts, overlays, editors and more
- **Single design token source** — every component reads from the `Theme` singleton; swap colours, radii and typography in one place
- **AOT-safe** — all QML passes `qmlsc` strict-mode compilation; no runtime type errors
- **Desktop-first** — interactions are designed for keyboard and mouse; no mobile-only patterns
- **Zero external dependencies** — plain Qt 6, no web engine, no JavaScript runtime
- **Bundled fonts** — [Inter](https://rsms.me/inter/) (UI), [JetBrains Mono](https://www.jetbrains.com/lp/mono/) (mono), and [Phosphor Icons](https://phosphoricons.com) (900+ glyphs, six weights) shipped as embedded Qt resources

## Requirements

| Dependency | Minimum version |
|---|---|
| Qt | 6.5 |
| CMake | 3.21 |
| C++ | 17 |

## Integration

### Via FetchContent (recommended)

No installation required — CMake downloads and builds Mahina automatically:

```cmake
include(FetchContent)
FetchContent_Declare(Mahina
    GIT_REPOSITORY https://github.com/ajunior/mahina.git
    GIT_TAG        v0.44.8
)
FetchContent_MakeAvailable(Mahina)

target_link_libraries(MyApp PRIVATE
    Qt6::Quick Mahina Mahinaplugin Mahinaplugin_init)
```

### As a subdirectory (source build)

```cmake
add_subdirectory(mahina)

target_link_libraries(MyApp PRIVATE
    Qt6::Quick
    Mahina
    Mahinaplugin
    Mahinaplugin_init
)
```

### As an installed package

```bash
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x/gcc_64 \
               -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
cmake --install build
```

Then in your project:

```cmake
find_package(Mahina REQUIRED)

# Option A — Qt-native projects using qt_add_executable:
#   qt_import_qml_plugins handles the static plugin init automatically.
target_link_libraries(MyApp PRIVATE Mahina::Mahina Mahina::Mahinaplugin)
qt_import_qml_plugins(MyApp)

# Option B — plain CMake executables:
#   Link Mahina::All, which also adds the Q_IMPORT_PLUGIN shim to your sources.
target_link_libraries(MyApp PRIVATE Mahina::All)
```

In both cases, add the QML import path at runtime:

```cpp
engine.addImportPath(QStringLiteral("qrc:/qt/qml"));
```

Then import the module in any QML file:

```qml
import Mahina

Button {
    text: "Hello, Mahina!"
    variant: Button.Variant.Filled
    onClicked: console.log("clicked")
}
```

## Bundled assets

Mahina ships three font families as embedded Qt resources — no system installation required.

Register them in `main.cpp` before loading the QML engine:

```cpp
#include <QFontDatabase>

// UI and mono fonts
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/InterVariable.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/JetBrainsMonoVariable.ttf");

// Phosphor Icons (all six weights)
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Regular.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Thin.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Light.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Bold.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Fill.ttf");
QFontDatabase::addApplicationFont(":/qt/qml/Mahina/assets/fonts/Phosphor-Duotone.ttf");
```

| Asset | Token | Description |
|---|---|---|
| Inter (variable, v4.0) | `Theme.fontFamily` | UI font used by all components |
| JetBrains Mono (variable, v2.3) | `Theme.fontFamilyMono` | Monospace font for code and terminal components |
| Phosphor Icons (six weights) | `Icons.*` | 900+ icon glyphs via the `Icon` component |

Both font tokens are writable and supported by `Theme.load()`, so you can swap them for any font your app registers.

## Building the example app

```bash
git clone <repo-url> mahina
cd mahina
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x/gcc_64
cmake --build build -j$(nproc)
./build/example/bin/MahinaExample
```

## Theme

All visual properties are exposed through the `Theme` singleton — import it anywhere:

```qml
import Mahina

Rectangle {
    color:  Theme.surface
    radius: Theme.radiusMd

    Text {
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.textBase
    }
}
```

Toggle dark mode at runtime:

```qml
Theme.dark = !Theme.dark
```

**Available tokens**

| Group | Tokens |
|---|---|
| Colours | `primary` `info` `success` `warning` `error` `panel` `surface` `surfaceVariant` `border` `textPrimary` `textSecondary` `textDisabled` |
| Typography | `fontFamily` `fontFamilyMono` `textXs` `textSm` `textBase` `textLg` `textXl` |
| Spacing | `sp1` … `sp16` |
| Radii | `radiusSm` `radiusMd` `radiusLg` `radiusFull` |

## Components

Mahina ships 262 components across nine categories.
Full documentation with descriptions, usage notes, best-fit scenarios, and a properties reference table is available in [`docs/index.html`](docs/index.html).

| Category | Count | Examples |
|---|---|---|
| Layout | 22 | `Accordion` `SplitPane` `Sidebar` `SidebarSection` `SidebarEntry` |
| Navigation | 20 | `CommandPalette` `Ribbon` `MenuBar` `Tabs` `Breadcrumb` |
| Display | 41 | `DataGrid` `VirtualTable` `ModelTable` `ListRow` `Card` `Tree` `JsonViewer` |
| Inputs | 56 | `DatePicker` `ColorPicker` `TransferList` `TagInput` `MultiSelect` |
| Charts | 29 | `AreaChart` `GanttChart` `NodeEditor` `KeyframeEditor` `LiveChart` |
| Feedback | 32 | `Toaster` `Dialog` `ProgressBar` `Skeleton` `Tooltip` |
| Editors | 27 | `CodeEditor` `DiffEditor` `HexViewer` `SpreadsheetGrid` `Terminal` |
| Utility | 24 | `Kanban` `Tour` `ImageComparison` `EventCalendar` `QRCode` |
| Communication | 7 | `Chat` `CommentThread` `PresenceList` `ReactionBar` `VideoCallTile` |

## ModelTable and the model contract

Most components take plain JavaScript arrays. `ModelTable` is the exception: it
binds a `QAbstractItemModel` directly so large result sets stay in C++ and are
never copied into JS. In exchange, the model must expose two roles by name:

| Role | Type | Meaning |
|---|---|---|
| `display` | `QString` | Cell text. Never return a null `QVariant` — pass an empty string instead. |
| `isNull` | `bool` | `true` when the cell holds no value. |

Both are bound as **required** delegate properties. A model missing either will
fail to instantiate the delegate — the table renders empty and Qt logs
`Error incubating delegate` to the console.

The `isNull` role is what allows a NULL to render distinctly (italic, dimmed,
`NULL`) from a present-but-empty string. Collapsing the two is a real hazard for
database front-ends, so the role is mandatory rather than optional.

```cpp
QHash<int, QByteArray> MyModel::roleNames() const
{
    return {
        { Qt::DisplayRole, QByteArrayLiteral("display") },
        { IsNullRole,      QByteArrayLiteral("isNull")  },
    };
}
```

Optionally, implement `headerData()` for column titles and a `Q_INVOKABLE
sort(int column, Qt::SortOrder)` to enable click-to-sort headers; `ModelTable`
calls `sort()` only if the model provides it.

> **Note:** QML's `TableModel` cannot drive `ModelTable` — `TableModelColumn`
> only maps Qt's built-in item roles and has no way to supply `isNull`. Use a
> C++ model; see [`example/DemoTableModel.h`](example/DemoTableModel.h) for a
> minimal conforming implementation.

## MahinaExtras

`MahinaExtras` is an optional companion library that adds native C++ capabilities to Mahina without breaking the pure-QML build. It is **not built by default** — enable it with `-DMAHINA_EXTRAS=ON`.

### Syntax highlighting

`SyntaxHighlighter` is a QML element backed by `QSyntaxHighlighter`. It attaches to any `CodeEditor` via its `textDocument` property and highlights code in real time.

```qml
import Mahina
import MahinaExtras

CodeEditor {
    id: editor
    language: "sql"

    SyntaxHighlighter {
        document: editor.textDocument
        language: editor.language
        darkMode: Theme.dark
    }
}
```

Supported values for the `language` property:

| Value(s) | Language |
|---|---|
| `"sql"` | SQL |
| `"qml"` `"js"` `"javascript"` `"ts"` `"typescript"` | QML / JavaScript / TypeScript |
| `"python"` `"py"` | Python |
| `"json"` | JSON |
| `"bash"` `"sh"` `"shell"` | Bash / Shell |
| `"cpp"` `"c++"` `"c"` `"h"` `"hpp"` | C / C++ |
| `"java"` | Java |
| `"rust"` `"rs"` | Rust |
| `"go"` `"golang"` | Go |
| `"html"` `"htm"` | HTML |
| `"css"` `"scss"` `"less"` | CSS |
| `"yaml"` `"yml"` | YAML |
| `"xml"` `"svg"` `"xaml"` | XML |

An empty or unrecognised value is accepted — the editor renders plain monochrome text.

The color scheme follows GitHub's dark/light palette and switches automatically when `darkMode` changes.

### Linking MahinaExtras

```cmake
target_link_libraries(MyApp PRIVATE
    Qt6::Quick
    Mahina Mahinaplugin Mahinaplugin_init
    MahinaExtras MahinaExtrasplugin MahinaExtrasplugin_init
)
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)

### Bundled fonts

The embedded font files in `assets/fonts/` are third-party works, redistributed under their own terms (full texts in `assets/fonts/licenses/`):

| Font | License | Source |
|---|---|---|
| Inter | SIL Open Font License 1.1 | [rsms/inter](https://github.com/rsms/inter) |
| JetBrains Mono | SIL Open Font License 1.1 | [JetBrains/JetBrainsMono](https://github.com/JetBrains/JetBrainsMono) |
| Phosphor Icons | MIT | [phosphor-icons](https://github.com/phosphor-icons/web) |
