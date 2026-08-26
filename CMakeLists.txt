cmake_minimum_required(VERSION 3.21)
project(Mahina VERSION 0.45.4 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

# Mahina is normally consumed by another project (FetchContent / add_subdirectory).
# A consumer wants the library and nothing else: building the demo app costs them
# time, and Mahina's install rules would leak into their `cmake --install`.
# Both therefore default to ON only when Mahina is the top-level project.
option(MAHINA_EXAMPLE "Build the MahinaExample demo app" ${PROJECT_IS_TOP_LEVEL})
option(MAHINA_INSTALL "Generate Mahina's install rules"  ${PROJECT_IS_TOP_LEVEL})

qt_add_library(Mahina STATIC)

set(MAHINA_QML_SOURCES
    Theme.qml
    Icons.qml
    Button.qml
    Icon.qml
    Input.qml
    Card.qml
    Badge.qml
    Divider.qml
    NavBar.qml
    TabBar.qml
    Notification.qml
    Sidebar.qml
    SidebarSection.qml
    SidebarEntry.qml
    Dialog.qml
    Dropdown.qml
    Checkbox.qml
    Toggle.qml
    Textarea.qml
    Tooltip.qml
    ProgressBar.qml
    Spinner.qml
    Avatar.qml
    Chip.qml
    Slider.qml
    Radio.qml
    RadioGroup.qml
    Accordion.qml
    Popover.qml
    Skeleton.qml
    SearchInput.qml
    NumberInput.qml
    Kbd.qml
    EmptyState.qml
    Breadcrumb.qml
    Pagination.qml
    Stepper.qml
    Menu.qml
    Table.qml
    ModelTable.qml
    Stat.qml
    DataList.qml
    ListRow.qml
    AlertDialog.qml
    ScrollArea.qml
    Rating.qml
    RangeSlider.qml
    Timeline.qml
    Drawer.qml
    Toaster.qml
    Tree.qml
    CommandPalette.qml
    DatePicker.qml
    ColorPicker.qml
    Alert.qml
    Callout.qml
    CircularProgress.qml
    ContextMenu.qml
    BottomSheet.qml
    SegmentedControl.qml
    HoverCard.qml
    TagInput.qml
    OTPInput.qml
    SplitPane.qml
    TimePicker.qml
    FileUpload.qml
    Carousel.qml
    VirtualList.qml
    Tour.qml
    Banner.qml
    Tabs.qml
    Sheet.qml
    PasswordInput.qml
    ComboBox.qml
    MultiSelect.qml
    AutoComplete.qml
    Gauge.qml
    Sparkline.qml
    CodeBlock.qml
    Sortable.qml
    FloatingActionButton.qml
    CopyButton.qml
    StatusBar.qml
    Marquee.qml
    InfiniteScroll.qml
    PropertyGrid.qml
    Chat.qml
    IrcPalette.qml
    IrcTextView.qml
    IrcNickList.qml
    IrcInput.qml
    MediaPlayer.qml
    LogViewer.qml
    ExpandableLog.qml
    HeatMap.qml
    Resizable.qml
    MasonryGrid.qml
    JsonViewer.qml
    DiffViewer.qml
    EditableTable.qml
    QRCode.qml
    ShortcutHint.qml
    ContextualHelp.qml
    AvatarGroup.qml
    Typewriter.qml
    Confetti.qml
    RadarChart.qml
    Candlestick.qml
    BubbleChart.qml
    FunnelChart.qml
    MaskInput.qml
    CurrencyInput.qml
    PhoneInput.qml
    MarkdownEditor.qml
    MarkdownView.qml
    KPICard.qml
    DashboardGrid.qml
    PageLayout.qml
    CommandBar.qml
    ImageGallery.qml
    VideoPlayer.qml
    ActivityFeed.qml
    PricingCard.qml
    AreaChart.qml
    BarChart.qml
    TreeMap.qml
    WaterfallChart.qml
    Histogram.qml
    GanttChart.qml
    SignaturePad.qml
    RichTextEditor.qml
    SliderWithInput.qml
    AddressInput.qml
    MultiRangeSlider.qml
    ColorSwatch.qml
    LoadingOverlay.qml
    ProgressDialog.qml
    CountdownTimer.qml
    NotificationCenter.qml
    BlurOverlay.qml
    StepWizard.qml
    MegaMenu.qml
    StickySection.qml
    AppSwitcher.qml
    TestimonialCard.qml
    FeatureGrid.qml
    KeyboardShortcutsPanel.qml
    OnboardingChecklist.qml
    AnimatedCounter.qml
    PulseIndicator.qml
    Ripple.qml
    SkeletonPage.qml
    SplashScreen.qml
    NetworkGraph.qml
    CalendarHeatmap.qml
    BoxPlot.qml
    SankeyDiagram.qml
    PolarChart.qml
    CreditCardInput.qml
    TimeDurationInput.qml
    DateRangePicker.qml
    MentionInput.qml
    ColorGradientPicker.qml
    Kanban.qml
    EventCalendar.qml
    CropTool.qml
    ZoomPan.qml
    EmojiPicker.qml
    DebugPanel.qml
    Terminal.qml
    DataGrid.qml
    Dock.qml
    FloatingToolbar.qml
    ScatterPlot.qml
    ComboChart.qml
    BulletChart.qml
    TreeGraph.qml
    WordCloud.qml
    FormField.qml
    FilterBar.qml
    JsonEditor.qml
    SearchResultItem.qml
    RatingInput.qml
    WindowFrame.qml
    GridStack.qml
    NavigationRail.qml
    CommandMenu.qml
    SwipeToDelete.qml
    LoadingBar.qml
    SystemStatus.qml
    AlertStack.qml
    FeedbackWidget.qml
    ProfileCard.qml
    CommentThread.qml
    ReactionBar.qml
    GradientText.qml
    TypingIndicator.qml
    ParticleField.qml
    LiveChart.qml
    MetricCard.qml
    CorrelationMatrix.qml
    DataTimeline.qml
    GaugeCluster.qml
    ThreadedMessage.qml
    PresenceList.qml
    NotificationBell.qml
    VideoCallTile.qml
    StatusMessage.qml
    InlineEdit.qml
    ColorTokenPicker.qml
    FileTree.qml
    MultiStepForm.qml
    FormulaInput.qml
    SidePanel.qml
    FloatingIsland.qml
    StickyHeader.qml
    TabDock.qml
    OverflowMenu.qml
    AudioWaveform.qml
    ImageComparison.qml
    ConnectionStatus.qml
    SyncStatus.qml
    PermissionGate.qml
    MenuBar.qml
    ToolBar.qml
    TitleBar.qml
    BreadcrumbEditor.qml
    DragDropList.qml
    NumberStepper.qml
    FilePicker.qml
    KeybindingInput.qml
    ConfirmDialog.qml
    SelectionRect.qml
    PreferencesLayout.qml
    CandlestickChart.qml
    HeatMapCalendar.qml
    MiniMap.qml
    ObjectInspector.qml
    LogConsole.qml
    NotesPad.qml
    TimezoneSelector.qml
    RulerBar.qml
    TableOfContents.qml
    FontPicker.qml
    TransferList.qml
    LayerPanel.qml
    PluginManager.qml
    ShortcutManager.qml
    ColorSchemeEditor.qml
    InspectorPanel.qml
    FileManager.qml
    CronEditor.qml
    ThemePreview.qml
    CodeEditor.qml
    HexViewer.qml
    RegexTester.qml
    DiffEditor.qml
    Ribbon.qml
    VirtualTable.qml
    SpreadsheetGrid.qml
    SchemaBrowser.qml
    KeyframeEditor.qml
    NodeEditor.qml
    PrintPreview.qml
)

foreach(_qml IN LISTS MAHINA_QML_SOURCES)
    set_source_files_properties(
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/${_qml}"
        PROPERTIES QT_RESOURCE_ALIAS "${_qml}"
    )
endforeach()

set_source_files_properties(
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Theme.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Icons.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/IrcPalette.qml"
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# Qt6QmlMacros reads the OUTPUT_DIRECTORY argument *before* it looks at
# QT_QML_OUTPUT_DIRECTORY, so passing one unconditionally silently overrides a
# consumer who set the latter. That variable is the documented way to gather
# every QML module in a build under one import path, and it is what lets a
# consumer's qmllint and qmlcachegen resolve Mahina's types at all -- without it
# they cannot, and every binding touching a Mahina type drops out of
# ahead-of-time compilation. So defer to it whenever it is set.
#
# When it is not, place the module under our own build directory. Qt's default
# for a library is a bare CMAKE_CURRENT_BINARY_DIR, which assumes the source
# directory is itself named after the URI; ours is the repository root, and an
# output directory not ending in the target path makes Qt warn that tooling may
# misbehave.
if(QT_QML_OUTPUT_DIRECTORY)
    set(_mahina_output_dir "")
else()
    set(_mahina_output_dir OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Mahina")
endif()

qt_add_qml_module(Mahina
    URI Mahina
    VERSION 1.0
    # CURRENT, not CMAKE_BINARY_DIR: as a subproject the latter is the consumer's
    # top-level build dir, and Mahina has no business writing there.
    ${_mahina_output_dir}
    QML_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Theme.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Icons.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Button.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Icon.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Input.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Card.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Badge.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Divider.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NavBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TabBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Notification.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Sidebar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SidebarSection.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SidebarEntry.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Dialog.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Dropdown.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Checkbox.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Toggle.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Textarea.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Tooltip.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ProgressBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Spinner.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Avatar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Chip.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Slider.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Radio.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RadioGroup.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Accordion.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Popover.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Skeleton.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SearchInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NumberInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Kbd.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/EmptyState.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Breadcrumb.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Pagination.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Stepper.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Menu.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Table.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ModelTable.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Stat.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DataList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ListRow.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AlertDialog.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ScrollArea.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Rating.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RangeSlider.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Timeline.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Drawer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Toaster.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Tree.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CommandPalette.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DatePicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ColorPicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Alert.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Callout.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CircularProgress.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ContextMenu.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BottomSheet.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SegmentedControl.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/HoverCard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TagInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/OTPInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SplitPane.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TimePicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FileUpload.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Carousel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/VirtualList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Tour.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Banner.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Tabs.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Sheet.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PasswordInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ComboBox.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MultiSelect.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AutoComplete.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Gauge.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Sparkline.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CodeBlock.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Sortable.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FloatingActionButton.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CopyButton.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/StatusBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Marquee.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/InfiniteScroll.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PropertyGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Chat.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/IrcPalette.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/IrcTextView.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/IrcNickList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/IrcInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MediaPlayer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LogViewer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ExpandableLog.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/HeatMap.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Resizable.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MasonryGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/JsonViewer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DiffViewer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/EditableTable.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/QRCode.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ShortcutHint.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ContextualHelp.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AvatarGroup.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Typewriter.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Confetti.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RadarChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Candlestick.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BubbleChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FunnelChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MaskInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CurrencyInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PhoneInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MarkdownEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MarkdownView.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/KPICard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DashboardGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PageLayout.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CommandBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ImageGallery.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/VideoPlayer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ActivityFeed.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PricingCard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AreaChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BarChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TreeMap.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/WaterfallChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Histogram.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/GanttChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SignaturePad.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RichTextEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SliderWithInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AddressInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MultiRangeSlider.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ColorSwatch.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LoadingOverlay.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ProgressDialog.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CountdownTimer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NotificationCenter.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BlurOverlay.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/StepWizard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MegaMenu.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/StickySection.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AppSwitcher.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TestimonialCard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FeatureGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/KeyboardShortcutsPanel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/OnboardingChecklist.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AnimatedCounter.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PulseIndicator.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Ripple.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SkeletonPage.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SplashScreen.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NetworkGraph.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CalendarHeatmap.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BoxPlot.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SankeyDiagram.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PolarChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CreditCardInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TimeDurationInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DateRangePicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MentionInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ColorGradientPicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Kanban.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/EventCalendar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CropTool.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ZoomPan.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/EmojiPicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DebugPanel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Terminal.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DataGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Dock.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FloatingToolbar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ScatterPlot.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ComboChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BulletChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TreeGraph.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/WordCloud.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FormField.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FilterBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/JsonEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SearchResultItem.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RatingInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/WindowFrame.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/GridStack.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NavigationRail.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CommandMenu.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SwipeToDelete.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LoadingBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SystemStatus.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AlertStack.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FeedbackWidget.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ProfileCard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CommentThread.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ReactionBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/GradientText.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TypingIndicator.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ParticleField.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LiveChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MetricCard.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CorrelationMatrix.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DataTimeline.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/GaugeCluster.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ThreadedMessage.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PresenceList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NotificationBell.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/VideoCallTile.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/StatusMessage.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/InlineEdit.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ColorTokenPicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FileTree.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MultiStepForm.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FormulaInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SidePanel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FloatingIsland.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/StickyHeader.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TabDock.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/OverflowMenu.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/AudioWaveform.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ImageComparison.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ConnectionStatus.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SyncStatus.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PermissionGate.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MenuBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ToolBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TitleBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/BreadcrumbEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DragDropList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NumberStepper.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FilePicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/KeybindingInput.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ConfirmDialog.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SelectionRect.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PreferencesLayout.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CandlestickChart.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/HeatMapCalendar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/MiniMap.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ObjectInspector.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LogConsole.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NotesPad.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TimezoneSelector.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RulerBar.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TableOfContents.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FontPicker.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/TransferList.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/LayerPanel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PluginManager.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ShortcutManager.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ColorSchemeEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/InspectorPanel.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/FileManager.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CronEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/ThemePreview.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/CodeEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/HexViewer.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/RegexTester.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/DiffEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/Ribbon.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/VirtualTable.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SpreadsheetGrid.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/SchemaBrowser.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/KeyframeEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/NodeEditor.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/qml/Mahina/PrintPreview.qml"
    RESOURCES
        assets/fonts/InterVariable.ttf
        assets/fonts/JetBrainsMonoVariable.ttf
        assets/fonts/Phosphor-Regular.ttf
        assets/fonts/Phosphor-Thin.ttf
        assets/fonts/Phosphor-Light.ttf
        assets/fonts/Phosphor-Bold.ttf
        assets/fonts/Phosphor-Fill.ttf
        assets/fonts/Phosphor-Duotone.ttf
)

target_link_libraries(Mahina PUBLIC Qt6::Quick)

# ── Install rules ────────────────────────────────────────────────────────────
if(MAHINA_INSTALL)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(MAHINA_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/Mahina"
    CACHE STRING "Install path for Mahina CMake files")

# 1. Library + plugin binaries (no EXPORT — Qt internal resource targets make
#    automatic export unreliable; MahinaConfig.cmake uses find_library instead)
install(TARGETS Mahina Mahinaplugin
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# Mahinaplugin_init is a two-line Q_IMPORT_PLUGIN shim — install its source so
# consumers can compile it into their own executable (required for static builds).
# Projects using qt_add_executable + qt_import_qml_plugins get this automatically.
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/Mahinaplugin_init.cpp"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/Mahina"
)

# 2. QML module support files (qmldir, .qmltypes) for IDEs and qmllint
# Ask the target where its module actually landed -- with QT_QML_OUTPUT_DIRECTORY
# in play it is not under our build directory, and a hardcoded path would install
# nothing while still reporting success.
get_target_property(_mahina_qml_dir Mahina QT_QML_MODULE_OUTPUT_DIRECTORY)

install(
    DIRECTORY   "${_mahina_qml_dir}/"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/Mahina"
    FILES_MATCHING
        PATTERN "qmldir"
        PATTERN "*.qmltypes"
)

# 3. CMake package config
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/MahinaConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MahinaConfig.cmake"
    INSTALL_DESTINATION "${MAHINA_INSTALL_CMAKEDIR}"
    # Every variable the .in file wraps in @PACKAGE_...@ has to be listed here.
    # An omitted one expands to nothing, and the set_and_check() around it turns
    # that into a FATAL_ERROR in the consumer's find_package(Mahina).
    PATH_VARS CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_DATADIR
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MahinaConfigVersion.cmake"
    VERSION     ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MahinaConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MahinaConfigVersion.cmake"
    DESTINATION "${MAHINA_INSTALL_CMAKEDIR}"
)

endif() # MAHINA_INSTALL

if(MAHINA_EXAMPLE)
    add_subdirectory(example)
endif()

# ── MahinaExtras (optional C++ extensions) ───────────────────────────────────
# Provides SyntaxHighlighter and other native-backed QML types.
# Enable with -DMAHINA_EXTRAS=ON to build the C++ companion library.
option(MAHINA_EXTRAS "Build MahinaExtras (C++ companion library)" OFF)
if(MAHINA_EXTRAS)
    add_subdirectory(extras)
endif()
