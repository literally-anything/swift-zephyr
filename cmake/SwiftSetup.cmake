#
# SwiftSetup.cmake
# SwiftZephyr
#
# Copyright (C) 2025-2026, by Hunter Baker hunter@literallyanything.net
# Licensed under MIT
#

# This is a helper script to setup Swift settings for embedded Swift in Zephyr

# Set the LLVM target triple
# - Note: This list is completely incomplete, so if you need something that is not listed yer, open a PR and add it.
if(NOT DEFINED CMAKE_Swift_COMPILER_TARGET)
    if(DEFINED CONFIG_ARCH AND "${CONFIG_ARCH}" STREQUAL "arm")
        if(DEFINED CONFIG_CPU_CORTEX_M7)
            set(LLVM_TARGET_ARCH armv6m)
        endif()
    endif()

    # Ensure that we found the arch
    if(NOT DEFINED LLVM_TARGET_ARCH)
        message(FATAL_ERROR "Swift target triple is not set, and can't be autodetected. CMAKE_Swift_COMPILER_TARGET")
    endif()

    set(CMAKE_Swift_COMPILER_TARGET "${LLVM_TARGET_ARCH}-none-none-eabi")
    message(STATUS "Set Swift target triple to '${CMAKE_Swift_COMPILER_TARGET}'")
endif()

# Set some general settings for Swift
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
add_compile_options(
    # Enable Embedded Swift
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-experimental-feature Embedded>"
    # Enable function sections to enable dead code stripping on elf
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -function-sections>"
    # Use compacted C enums matching GCC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fshort-enums>"
    # Disable PIC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fno-pic>"
    # Disable PIE
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fno-pie>"
    # Add Libc include paths
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include>"
    # Disable the stack protector
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -disable-stack-protector>"
    # Save the Swift index for LSP
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-index-store-path ${CMAKE_BINARY_DIR}/swift-index>"
)

# By default, enable the strict memory safety mode in Swift
if(NOT DEFINED DISABLE_STRICT_MEMORY_SAFETY)
    add_compile_options(
        "$<$<COMPILE_LANGUAGE:Swift>:-strict-memory-safety>"
    )
endif()

# Import TOOLCHAIN_C_FLAGS from Zephyr as -Xcc flags
foreach(flag ${TOOLCHAIN_C_FLAGS})
    # Skip flags that are not known to swiftc
    string(FIND "${flag}" "-imacro" is_imacro)
    string(FIND "${flag}" "-mfp16-format" is_mfp16)
    if(NOT is_imacro EQUAL -1 OR NOT is_mfp16 EQUAL -1)
        continue()
    endif()

    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc ${flag}>")
endforeach()

# Add definitions from Zephyr to -Xcc flags
get_target_property(ZEPHYR_DEFINES zephyr_interface INTERFACE_COMPILE_DEFINITIONS)
if(ZEPHYR_DEFINES)
    foreach(flag ${ZEPHYR_DEFINES})
        # Ignore expressions like "$<SOMETHING>"
        string(FIND "${flag}" "$<" start_of_expression)
        if(NOT start_of_expression EQUAL -1)
            continue()
        endif()

        add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -D${flag}>")
    endforeach()
endif()

# Add stubs file to the main app target
target_sources(app PRIVATE "${CMAKE_CURRENT_LIST_DIR}/Stubs.c")

# Remove unused sections
zephyr_linker_sources(SECTIONS "${CMAKE_CURRENT_LIST_DIR}/sections.ld")
