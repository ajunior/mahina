cmake_minimum_required(VERSION 3.21)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_library(MahinaExtras STATIC)

# Same reasoning as in ../CMakeLists.txt: defer to the consumer's
# QT_QML_OUTPUT_DIRECTORY, and only fall back to a target-path-suffixed
# directory of our own when they have not set one.
if(QT_QML_OUTPUT_DIRECTORY)
    set(_mahina_extras_output_dir "")
else()
    set(_mahina_extras_output_dir
        OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/MahinaExtras")
endif()

qt_add_qml_module(MahinaExtras
    URI MahinaExtras
    VERSION 1.0
    ${_mahina_extras_output_dir}
    SOURCES
        src/syntaxhighlighter.h
        src/syntaxhighlighter.cpp
)

target_include_directories(MahinaExtras PUBLIC src)
target_link_libraries(MahinaExtras PUBLIC Qt6::Quick)
