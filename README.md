# SwiftZephyr

SwiftZephyr wraps Zephyr RTOS C APIs to make them cleaner to use in Swift.

The APIs that are supported so far are:
- Devices and device tree lookup
- Time APIs (Timespec and Timeout)
- Error codes (ZephyrError)
- Reboot and last reset reason
- More WIP

## Usage

This library uses CMake to build, and it will not build alone. To build, it should be included in an existing Zephyr application build.
```cmake
# Add the SwiftZephyr library as a subdirectory
add_subdirectory(extra/SwiftZephyr)

# Add dependency
target_link_libraries(MySwiftApp PRIVATE SwiftZephyr)
```
> [!NOTE]
> For now, while this package is set up to work as a Zephyr module,
> this fails to build because `findPackage(Zephyr)` must be run before enabling Swift,
> breaking CMake somehow.

## Swift CMake Helper
This package also provides a CMake [helper](cmake/SwiftSetup.cmake) that sets up Swift Embedded for Zephyr automatically.
It sets all the required compiler flags, sets the compiler target, passes along C flags and defines from Zephyr, provies an implementation for `posix_memalign` for Swift, and enables strict memory safety.
To use this helper, add the following to your `CMakeLists.txt` after both setting up your project and finding Zephyr:
```cmake
include(extra/SwiftZephyr/cmake/SwiftSetup.cmake)

# Make my Swift app target
...
target_link_libraries(MyAppTarget PRIVATE SwiftZephyr)
target_link_libraries(app PRIVATE MyAppTarget)
```
