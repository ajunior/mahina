cmake_minimum_required(VERSION 3.21)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_library(MahinaExtras STATIC)

qt_add_qml_module(MahinaExtras
    URI MahinaExtras
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/MahinaExtras"
    SOURCES
        src/syntaxhighlighter.h
        src/syntaxhighlighter.cpp
)

target_include_directories(MahinaExtras PUBLIC src)
target_link_libraries(MahinaExtras PUBLIC Qt6::Quick)
