add_library(SwiftZephyrShims INTERFACE)
target_include_directories(SwiftZephyrShims INTERFACE
    "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>"
    include
)

target_compile_options(SwiftZephyrShims INTERFACE
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fapinotes-modules>"
)

add_dependencies(SwiftZephyrShims syscall_list_h_target)
