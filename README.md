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

## Strict Memory Safety
This library is set up with Swift's strict memory safety mode.
Use this to enable it in your application:
```cmake
# Enable strict memory safety in all Swift targets
add_compile_options(
    "$<$<COMPILE_LANGUAGE:Swift>:-strict-memory-safety>"
)
```
