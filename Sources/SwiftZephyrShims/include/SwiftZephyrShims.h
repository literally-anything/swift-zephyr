/*
 * SwiftZephyrShims.h
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
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

/// The direction of a GPIO pin
enum __attribute__((enum_extensibility(open))) GPIODirection : gpio_flags_t {
    /// Sets a pin as an output
    GPIODirection_Output = GPIO_OUTPUT,
    /// Sets a pin as an input
    GPIODirection_Input = GPIO_INPUT,
    /// Sets a pin as both an output and an input
    GPIODirection_Both = GPIO_OUTPUT | GPIO_INPUT,
    GPIODirection_Disconnected = GPIO_DISCONNECTED
};

/// The active level of a GPIO pin
enum __attribute__((enum_extensibility(open))) GPIOActiveLevel : gpio_flags_t {
    /// Logical level HIGH is physical level LOW
    GPIOActiveLevel_ActiveLow = GPIO_ACTIVE_LOW,
    /// Logical level HIGH is physical level HIGH
    GPIOActiveLevel_ActiveHigh = GPIO_ACTIVE_HIGH
};

/// The pin drive mode for a GPIO pin
enum __attribute__((enum_extensibility(open))) GPIOPinDriveMode : gpio_flags_t {
    /// 'Open Drain' mode also known as 'Open Collector' is an output configuration which
    /// behaves like a switch that is either connected to ground or disconnected.
    GPIOPinDriveMode_OpenDrain = GPIO_SINGLE_ENDED | GPIO_LINE_OPEN_DRAIN,
    /// 'Open Source' is a term used by software engineers to describe output mode opposite to 'Open Drain'.
    /// It behaves like a switch that is either connected to power supply or disconnected.
    /// There exist no corresponding hardware schematic and the term is generally unknown to hardware engineers.
    GPIOPinDriveMode_OpenSource = GPIO_SINGLE_ENDED | GPIO_LINE_OPEN_SOURCE,
    /// Drive the pin in both directions.
    GPIOPinDriveMode_PushPull = GPIO_PUSH_PULL
};

/// The bias for a GPIO pin
enum __attribute__((enum_extensibility(open))) GPIOPinBias : gpio_flags_t {
    /// Enable the pin's pull-up resistor
    GPIOPinBias_PullUp = GPIO_PULL_UP,
    /// Enable the pin's pull-down resistor
    GPIOPinBias_PullDown = GPIO_PULL_DOWN,
    /// Don't enable any pin bias
    GPIOPinBias_None = 0
};

enum __attribute__((enum_extensibility(open),flag_enum)) GPIOInterruptFlags : gpio_flags_t {
    GPIOInterruptFlags_Disable = GPIO_INT_DISABLE,
    GPIOInterruptFlags_Edge = GPIO_INT_EDGE,
    GPIOInterruptFlags_Low = GPIO_INT_ENABLE | GPIO_INT_LOW_0,
    GPIOInterruptFlags_High = GPIO_INT_ENABLE | GPIO_INT_HIGH_1,
    GPIOInterruptFlags_LogicalLevels = GPIO_INT_LEVELS_LOGICAL,
    GPIOInterruptFlags_Wakeup = GPIO_INT_WAKEUP
};
