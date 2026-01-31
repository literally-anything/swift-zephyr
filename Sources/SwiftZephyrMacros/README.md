# SwiftZephyrMacros

This module sets up the compile-time plugins for SwiftZephyr.

There are two components: Macros and DTGenerator.
Both parts are built for the host platform instead of the target and are used at build time, so this module is built as a CMake ExternalProject.
The CMake file [`cmake/MacroSetup.cmake`](cmake/MacroSetup.cmake) setus up the external project and add some helpers for other targets to use to depend on these plugins.

To parse the device tree, the plugins use the `devicetree_generated.h` file that Zephyr generates. The file path is passed to the external project from `DEVICETREE_GENERATED_H` and read into a variable in a templated swift file: [`cmake/MacroConfig.swift.in`](cmake/MacroConfig.swift.in).

The `Package.swift` file is only for editor autocomplete, the build still uses CMake.

## Macros
Swift macro target that build as an executable target compiler plugin. Provides `DeviceMacro`.

## DTGenerator
A Swift source generator that generates accessors for the devices in the Zephyr device tree.
This is used to populate `DeviceTree` so that the `#dtDevice` macro works.
