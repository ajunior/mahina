qt_add_executable(MahinaExample main.cpp)

# The README tells consumers to declare Mahina as a QML module dependency, and
# the demo app is a consumer like any other: without this, qmllint cannot resolve
# a single Mahina type here (every component reads as "was not found") and
# qmlcachegen drops every binding that touches one. TARGET rather than a bare URI
# so Qt can find the module in this build tree; that form needs QTP0005.
qt_policy(SET QTP0005 NEW)

qt_add_qml_module(MahinaExample
    URI MahinaExample
    VERSION 1.0
    DEPENDENCIES TARGET Mahina
    QML_FILES main.qml
    SOURCES DemoTableModel.h DemoTableModel.cpp
)

set_target_properties(MahinaExample PROPERTIES
    # Resolves to <build>/example/bin as before when Mahina is top-level, but
    # stays inside our own build tree when it is not.
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin"
)

target_link_libraries(MahinaExample PRIVATE Qt6::Quick Mahina Mahinaplugin Mahinaplugin_init)
