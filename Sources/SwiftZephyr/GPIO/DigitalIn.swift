/*
 * DigitalIn.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

internal import SwiftZephyrShims

/// Represents a digital input pin in the Zephyr RTOS.
public struct DigitalIn: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr GPIO port device.
    public let device: Device
    /// The GPIO pin number.
    public let pin: gpio_pin_t

    /// Initializes a `DigitalIn` with the given device and pin number.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - pullUp: Whether to enable the internal pull-up resistor. Defaults to `false`.
    ///   - pullDown: Whether to enable the internal pull-down resistor. Defaults to `false`.
    /// - Throws: A `ZephyrError` if the operation fails.
    public init(
        device: Device, pin: gpio_pin_t,
        invert: Bool = false,
        pullUp: Bool = false,
        pullDown: Bool = false
    ) throws(ZephyrError) {
        self.device = device
        self.pin = pin

        var flags: GPIOFlags = .input

        if invert {
            flags.insert(.activeLow)
        }

        if pullUp {
            flags.insert(.pullUp)
        }
        if pullDown {
            flags.insert(.pullDown)
        }

        let ret = gpio_pin_configure(device, pin, flags.rawValue)
        guard ret == 0 else {
            throw ZephyrError(code: ret)
        }
    }

    /// Initializes a `DigitalIn` with the given GPIO pin information.
    /// - Parameters:
    ///   - dtSpec: The GPIO pin information.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - pullUp: Whether to enable the internal pull-up resistor. Defaults to `false`.
    ///   - pullDown: Whether to enable the internal pull-down resistor. Defaults to `false`.
    /// - Throws: A `GPIOInitError` if the operation fails.
    public init(
        dtSpec: gpio_dt_spec,
        invert: Bool = false,
        pullUp: Bool = false,
        pullDown: Bool = false
    ) throws(InitError) {
        guard withUnsafePointer(to: dtSpec, { gpio_is_ready_dt($0) }) else {
            throw .deviceNotReady
        }
        do {
            try self.init(
                device: dtSpec.port, pin: dtSpec.pin,
                invert: invert,
                pullUp: pullUp,
                pullDown: pullDown
            )
        } catch let error {
            throw .zephyrError(error)
        }
    }

    /// Internal initializer that does not check if the device is ready or configure the pin.
    /// - Parameters:
    ///   - uncheckedDevice: The GPIO device.
    ///   - pin: The GPIO pin number.
    /// - Note: This initializer is unsafe because it does not check if the pin is valid or even an input pin.
    internal init(uncheckedDevice: Device, pin: gpio_pin_t) {
        self.device = uncheckedDevice
        self.pin = pin
    }

    /// Errors that can occur when initializing a `DigitalIn`.
    public enum InitError: Error {
        /// The GPIO device is not ready.
        case deviceNotReady
        ///. A Zephyr error occurred.
        case zephyrError(ZephyrError)
    }

    /// Sets the pin to the given state.
    /// - Note: This ignores errors from Zephyr in release builds. In debug builds, it will assert if an error occurs.
    ///         To handle errors, use `setState(_:)`, `enable()`, `disable()`, and `toggle()` instead.
    public var state: Bool {
        get {
            let ret = gpio_pin_get(device, pin)
            assert(ret >= 0, "Failed to get pin state: \(ret)")
            return ret == 1
        }
    }

    internal var level: DigitalOut.LogicLevel {
        get {
            let ret = gpio_pin_get_raw(device, pin)
            assert(ret >= 0, "Failed to get pin level: \(ret)")
            return ret == 1 ? .high : .low
        }
    }

    /// Whether the internal pull-up resistor is enabled.
    /// - Note: This ignores errors from Zephyr in release builds. In debug builds, it will assert if an error occurs.
    public var pullUpEnabled: Bool {
        get {
            var flags: GPIOFlags = []
            let ret = gpio_pin_get_config(device, pin, &flags.rawValue)
            assert(ret == 0, "Failed to get pin config: \(ret)")
            return flags.contains(.pullUp)
        }
        set {
            var flags: GPIOFlags = []
            var ret = gpio_pin_get_config(device, pin, &flags.rawValue)
            assert(ret == 0, "Failed to get pin config: \(ret)")
            if newValue {
                flags.insert(.pullUp)
            } else {
                flags.remove(.pullUp)
            }
            ret = gpio_pin_configure(device, pin, flags.rawValue)
            assert(ret == 0, "Failed to set pin config: \(ret)")
        }
    }
    /// Whether the internal pull-down resistor is enabled.
    /// - Note: This ignores errors from Zephyr in release builds. In debug builds, it will assert if an error occurs.
    public var pullDownEnabled: Bool {
        get {
            var flags: GPIOFlags = []
            let ret = gpio_pin_get_config(device, pin, &flags.rawValue)
            assert(ret == 0, "Failed to get pin config: \(ret)")
            return flags.contains(.pullDown)
        }
        set {
            var flags: GPIOFlags = []
            var ret = gpio_pin_get_config(device, pin, &flags.rawValue)
            assert(ret == 0, "Failed to get pin config: \(ret)")
            if newValue {
                flags.insert(.pullDown)
            } else {
                flags.remove(.pullDown)
            }
            ret = gpio_pin_configure(device, pin, flags.rawValue)
            assert(ret == 0, "Failed to set pin config: \(ret)")
        }
    }
}

// ToDo: Implement interrupt handling for DigitalIn

extension DigitalIn {
    /// Creates a `DigitalIn` for a pin that is already configured as an input.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    /// - Returns: A `DigitalIn` instance if the pin is configured as an input, otherwise `nil`.
    public static func alreadyConfigured(
        device: Device, pin: gpio_pin_t
    ) -> DigitalIn? {
        var flags: gpio_flags_t = 0
        let ret = gpio_pin_get_config(device, pin, &flags)

        guard ret == 0, GPIOFlags(rawValue: flags).contains(.input) else {
            return nil
        }
        return DigitalIn(uncheckedDevice: device, pin: pin)
    }
}

extension DigitalIn: CustomStringConvertible {
    public var description: String {
        "DigitalIn(device: \(String(cString: device.pointee.name)), pin: \(pin), state: \(state), level: \(level == .high ? "HIGH" : "LOW"))"
    }
}
