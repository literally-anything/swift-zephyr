#
# CMakeLists.txt
# SwiftZephyr
# -----
# Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
# Licensed under the MIT License
#

cmake_minimum_required(VERSION 3.29)
project(SwiftZephyr LANGUAGES C Swift)

# This Swift check is a workaround of an issue in Zephyr's cmake stuff where if Swift is enabled after loading modules,
# the modules won't find Swift, but if it is enabled first, the main app build fails because it looks like a Swift target.

get_property(ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
if ("Swift" IN_LIST ENABLED_LANGUAGES)
    include_guard(GLOBAL)
    project(SwiftZephyr LANGUAGES C Swift)

    add_subdirectory(Sources)
endif()

add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-package-name SwiftZephyr>")
