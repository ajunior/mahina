qt_add_executable(MahinaExample main.cpp)

qt_add_qml_module(MahinaExample
    URI MahinaExample
    VERSION 1.0
    QML_FILES main.qml
    SOURCES DemoTableModel.h DemoTableModel.cpp
)

set_target_properties(MahinaExample PROPERTIES
    # Resolves to <build>/example/bin as before when Mahina is top-level, but
    # stays inside our own build tree when it is not.
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin"
)

target_link_libraries(MahinaExample PRIVATE Qt6::Quick Mahina Mahinaplugin Mahinaplugin_init)
