/**
 * GPIOFlags.swift
 * GPIO
 * 
 * Created by Hunter Baker on 9/07/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

internal struct GPIOFlags: OptionSet {
    var rawValue: gpio_flags_t

    static var activeHigh: GPIOFlags = []  // GPIO_ACTIVE_HIGH (default)
    static var activeLow: GPIOFlags = .init(rawValue: (1 << 0))  // GPIO_ACTIVE_LOW

    static var pushPull: GPIOFlags = []  // GPIO_PUSH_PULL (default)
    static var singleEnded: GPIOFlags = .init(rawValue: (1 << 1))  // GPIO_SINGLE_ENDED
    static var openSource: GPIOFlags = []  // GPIO_OPEN_SOURCE (default)
    static var openDrain: GPIOFlags = .init(rawValue: (1 << 2))  // GPIO_OPEN_DRAIN

    static var pullUp: GPIOFlags = .init(rawValue: (1 << 4))  // GPIO_PULL_UP
    static var pullDown: GPIOFlags = .init(rawValue: (1 << 5))  // GPIO_PULL_DOWN

    static var input: GPIOFlags = .init(rawValue: (1 << 16))  // GPIO_INPUT
    static var output: GPIOFlags = .init(rawValue: (1 << 17))  // GPIO_OUTPUT

    static var outputInitLow: GPIOFlags = .init(rawValue: (1 << 18))  // GPIO_OUTPUT_INIT_LOW
    static var outputInitHigh: GPIOFlags = .init(rawValue: (1 << 19))  // GPIO_OUTPUT_INIT_HIGH
    static var outputInitLogical: GPIOFlags = .init(rawValue: (1 << 20))  // GPIO_OUTPUT_INIT_LOGICAL
}
