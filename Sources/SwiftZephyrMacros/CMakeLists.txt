#
# CMakeLists.txt
# SwiftZephyr
# -----
# Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
# Licensed under the MIT License
#

cmake_minimum_required(VERSION 3.29)
project(SwiftZephyrMacros LANGUAGES Swift)

set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# Setup macro configuration
set(DEVICETREE_GENERATED_H "/Users/hbaker/zephyr/projects/SwiftDrive/build/primary/zephyr/include/generated/zephyr/devicetree_generated.h")
if (DEFINED DEVICETREE_GENERATED_H AND NOT "${DEVICETREE_GENERATED_H}" STREQUAL "")
    message(STATUS "Configuring SwiftZephyrMacros to use ${DEVICETREE_GENERATED_H}")
else()
    message(FATAL_ERROR "DEVICETREE_GENERATED_H was not set. This means Zephyr has not been setup before including SwiftZephyr.")
endif()
file(READ ${DEVICETREE_GENERATED_H} DEVICETREE_GENERATED_H_CONTENTS)
configure_file(
    "cmake/MacroConfig.swift.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MacroConfig.swift"
)

# Add SwiftSyntax as a dependency
include(FetchContent)
FetchContent_Declare(SwiftSyntax
    GIT_REPOSITORY https://github.com/swiftlang/swift-syntax
    GIT_TAG 602.0.0
)
FetchContent_MakeAvailable(SwiftSyntax)

# Add macro target
file(GLOB SWIFTZEPHYR_MACROS_SOURCES CONFIGURE_DEPENDS "Macros/*.swift")
add_executable(SwiftZephyrMacros
    "${CMAKE_CURRENT_BINARY_DIR}/MacroConfig.swift"
    ${SWIFTZEPHYR_MACROS_SOURCES}
)
target_compile_options(SwiftZephyrMacros PRIVATE -parse-as-library)
target_link_libraries(SwiftZephyrMacros
    SwiftSyntax
    SwiftSyntaxMacros
    SwiftCompilerPlugin
)

# Add build tool executable target
file(GLOB SWIFTZEPHYR_DTGENERATOR_SOURCES CONFIGURE_DEPENDS "DTGenerator/*.swift")
add_executable(SwiftZephyrDTGenerator
    "${CMAKE_CURRENT_BINARY_DIR}/MacroConfig.swift"
    ${SWIFTZEPHYR_DTGENERATOR_SOURCES}
)
target_link_libraries(SwiftZephyrDTGenerator
    SwiftSyntax
    SwiftSyntaxBuilder
    SwiftDiagnostics
)
