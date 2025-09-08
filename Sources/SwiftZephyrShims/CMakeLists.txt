add_library(SwiftZephyrShims INTERFACE)
target_include_directories(SwiftZephyrShims INTERFACE
    "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>"
    include
)

add_dependencies(SwiftZephyrShims syscall_list_h_target)
