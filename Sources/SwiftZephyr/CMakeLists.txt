file(GLOB_RECURSE SWIFTZEPHYR_SOURCES CONFIGURE_DEPENDS "*.swift")
add_library(SwiftZephyr STATIC ${SWIFTZEPHYR_SOURCES})

target_link_libraries(SwiftZephyr PUBLIC SwiftZephyrShims)

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)
set_target_properties(SwiftZephyr PROPERTIES
    Swift_MODULE_NAME Zephyr
    INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY}
)
target_compile_options(SwiftZephyr PRIVATE -Osize)

if(CONFIG_LED)
    target_compile_options(SwiftZephyr PRIVATE -DCONFIG_LED)
endif()
if(CONFIG_SCHED_CPU_MASK)
    target_compile_options(SwiftZephyr PRIVATE -DCONFIG_SCHED_CPU_MASK)
endif()
