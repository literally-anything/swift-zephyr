# SwiftZephyrShims

This module imports the C headers for Zephyr.

Some APIs are renamed or modified on import using apinotes:
- Used or exported functions that return POSIX errors as `int` are bridged to Swift as a `ZephyrError`.
- The following Zephyr types are imported as swift types:
    - device: Device
    - device_handle_t: DeviceHandle
    - timespec: Timespec
    - k_timeout_t: Timeout
    - k_timepoint_t: Timepoint
