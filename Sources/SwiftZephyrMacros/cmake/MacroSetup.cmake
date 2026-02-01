#
# MacroSetup.cmake
# SwiftZephyr
# -----
# Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
# Licensed under the MIT License
#

# Pass along the generated devicetree header path.
if (DEFINED DEVICETREE_GENERATED_H AND NOT "${DEVICETREE_GENERATED_H}" STREQUAL "")
    message(STATUS "Configuring SwiftZephyrMacros to use ${DEVICETREE_GENERATED_H}")
else()
    message(FATAL_ERROR "DEVICETREE_GENERATED_H was not set. This means Zephyr has not been setup before including SwiftZephyr.")
endif()

# Load the macro module as an external project
string(STRIP ${DEVICETREE_GENERATED_H} DEVICETREE_GENERATED_H_STRIPPED)
include(ExternalProject)
ExternalProject_Add(SwiftZephyrMacrosImpl
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/SwiftZephyrMacros"
    INSTALL_COMMAND ""
    LOG_CONFIGURE 1
    CMAKE_ARGS "-DDEVICETREE_GENERATED_H:STRING='${DEVICETREE_GENERATED_H_STRIPPED}'" "-DCMAKE_BUILD_TYPE:STRING=Debug"
    DEPENDS devicetree_target
)

# Get product paths
ExternalProject_Get_Property(SwiftZephyrMacrosImpl BINARY_DIR)
if(CMAKE_HOST_WIN32)
    set(SWIFTZEPHYR_MACROS_PATH "${BINARY_DIR}/SwiftZephyrMacros.exe")
    set(SWIFTZEPHYR_DTGENERATOR_PATH "${BINARY_DIR}/SwiftZephyrDTGenerator.exe")
else()
    set(SWIFTZEPHYR_MACROS_PATH "${BINARY_DIR}/SwiftZephyrMacros")
    set(SWIFTZEPHYR_DTGENERATOR_PATH "${BINARY_DIR}/SwiftZephyrDTGenerator")
endif()
unset(BINARY_DIR)

# Build a target to propagate the Swift plugin flags easly
add_library(SwiftZephyrMacros INTERFACE)
add_dependencies(SwiftZephyrMacros INTERFACE SwiftZephyrMacrosImpl)
target_compile_options(SwiftZephyrMacros INTERFACE
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL: -load-plugin-executable ${SWIFTZEPHYR_MACROS_PATH}#SwiftZephyrMacros>"
)

# Make a macro to generate the device tree wrapper
macro(swiftzephyr_dt_generate KEYWORDS OUTPUT KEYWORDS SHIMS_MODULE_NAME KEYWORDS DT_TYPE_NAME KEYWORDS DEVICE_TYPE_NAME)
    add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${SWIFTZEPHYR_DTGENERATOR_PATH} ${OUTPUT} ${SHIMS_MODULE_NAME} ${DT_TYPE_NAME} ${DEVICE_TYPE_NAME}
        DEPENDS SwiftZephyrMacros
        COMMENT "SwiftZephyr: Generating devicetree wrapper file: ${OUTPUT}"
    )
endmacro()
