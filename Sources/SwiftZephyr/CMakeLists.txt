# Generate the device tree wrapper
set(SWIFTZEPHYR_DT_WRAPPER_PATH "${CMAKE_CURRENT_BINARY_DIR}/DeviceTreeWrapper.swift")
swiftzephyr_dt_generate(
    OUTPUT ${SWIFTZEPHYR_DT_WRAPPER_PATH}
    SHIMS_MODULE_NAME "SwiftZephyrShims"
    DT_TYPE_NAME "DeviceTree"
    DEVICE_TYPE_NAME "Device"
)

# Setup the library target
# file(GLOB_RECURSE SWIFTZEPHYR_SOURCES CONFIGURE_DEPENDS "*.swift")
file(GLOB SWIFTZEPHYR_SOURCES CONFIGURE_DEPENDS "*.swift")
add_library(SwiftZephyr STATIC ${SWIFTZEPHYR_SOURCES} ${SWIFTZEPHYR_DT_WRAPPER_PATH})
set_target_properties(SwiftZephyr PROPERTIES Swift_MODULE_NAME Zephyr)

target_link_libraries(SwiftZephyr PUBLIC SwiftZephyrShims)
 
# Setup the macros and their flags
add_dependencies(SwiftZephyr SwiftZephyrMacros)
target_compile_options(SwiftZephyr PUBLIC ${SWIFTZEPHYR_MACRO_OPTIONS})

target_compile_options(SwiftZephyr PRIVATE
    # For Mutex implementation
    "$<$<COMPILE_LANGUAGE:Swift>:-enable-builtin-module>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-experimental-feature RawLayout>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-experimental-feature StaticExclusiveOnly>"

    # Enable nonescapable lifetime annotations
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-experimental-feature Lifetimes>"

    # Enable strict memory safety
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-strict-memory-safety>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror StrictMemorySafety>"

    # Force embedded errors and enable a few other diagnostics
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror EmbeddedRestrictions>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror TemporaryPointers>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror ClangDeclarationImport>"
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Werror ForeignReferenceType>"
)

# Pass along some config parameters to swift so that we can use conditional compilation with them

if(CONFIG_LED)
    target_compile_options(SwiftZephyr PUBLIC -DCONFIG_LED)
endif()

# if(CONFIG_SCHED_CPU_MASK)
#     target_compile_options(SwiftZephyr PUBLIC -DCONFIG_SCHED_CPU_MASK)
# endif()

# if(CONFIG_SERIAL)
#     target_compile_options(SwiftZephyr PUBLIC -DCONFIG_SERIAL)
# endif()
# if(CONFIG_UART_USE_RUNTIME_CONFIGURE)
#     target_compile_options(SwiftZephyr PUBLIC -DCONFIG_UART_USE_RUNTIME_CONFIGURE)
# endif()
# if(CONFIG_UART_ASYNC_API)
#     target_compile_options(SwiftZephyr PUBLIC -DCONFIG_UART_ASYNC_API)
# endif()

if(CONFIG_DEVICE_DEINIT_SUPPORT)
    target_compile_options(SwiftZephyr PUBLIC -DCONFIG_DEVICE_DEINIT_SUPPORT)
endif()
if(CONFIG_DEVICE_DEPS)
    target_compile_options(SwiftZephyr PUBLIC -DCONFIG_DEVICE_DEPS)
endif()

if(CONFIG_HWINFO)
    target_compile_options(SwiftZephyr PUBLIC -DCONFIG_HWINFO)
endif()
