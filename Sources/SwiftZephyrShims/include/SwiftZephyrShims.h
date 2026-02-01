/*
 * SwiftZephyrShims.h
 * SwiftZephyr
 *
 * Copyright (C) 2025-2026, by Hunter Baker hunter@literallyanything.net
 * Licensed under MIT
 */

#pragma once

/// A POSIX error code from Zephyr.
typedef int zephyr_error_t;

#include <autoconf.h>

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/devicetree.h>
#include <zephyr/sys/reboot.h>
#include <zephyr/sys/timeutil.h>

#include <zephyr/drivers/hwinfo.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/dt-bindings/gpio/gpio.h>
#include <zephyr/drivers/led.h>
#include <zephyr/drivers/uart.h>

/// Creates a `Timeout` representing the specified number of seconds.
/// - Parameter seconds: The number of seconds.
/// - Returns: An initialized `Timeout` structure.
inline k_timeout_t _sToKTimeout(int32_t seconds) {
    return K_SECONDS(seconds);
}
/// Creates a `Timeout` representing the specified number of milliseconds.
/// - Parameter milliseconds: The number of milliseconds.
/// - Returns: An initialized `Timeout` structure.
inline k_timeout_t _msToKTimeout(int32_t milliseconds) {
    return K_MSEC(milliseconds);
}
/// Creates a `Timeout` representing the specified number of microseconds.
/// - Parameter microseconds: The number of microseconds.
/// - Returns: An initialized `Timeout` structure.
inline k_timeout_t _usToKTimeout(int32_t microseconds) {
    return K_USEC(microseconds);
}
/// Creates a `Timeout` representing the specified number of nanoseconds.
/// - Parameter nanoseconds: The number of nanoseconds.
/// - Returns: An initialized `Timeout` structure.
inline k_timeout_t _nsToKTimeout(int32_t nanoseconds) {
    return K_NSEC(nanoseconds);
}
