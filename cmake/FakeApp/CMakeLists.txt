#
# CMakeLists.txt
# SwiftZephyr
# -----
# Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
# Licensed under the MIT License
#

cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(SwiftDrive LANGUAGES C Swift)

include(../SwiftSetup.cmake)
add_compile_options(
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror DynamicExclusivity>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror ClangDeclarationImport>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror StrictMemorySafety>"
)

add_subdirectory(../.. SwiftZephyr)
target_link_libraries(app PUBLIC SwiftZephyr)
