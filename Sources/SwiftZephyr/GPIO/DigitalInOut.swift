/*
 * DigitalInOut.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

internal import SwiftZephyrShims

/// Represents a digital input/output pin in the Zephyr RTOS.
public struct DigitalInOut: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr GPIO port device.
    public let device: Device
    /// The GPIO pin number.
    public let pin: gpio_pin_t

    /// Initializes a `DigitalInOut` with the given device and pin number.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    ///   - intialState: The initial state of the pin. If `nil`, the pin state is set to logical `0`.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - driveMode: The drive mode of the pin. Defaults to `.pushPull`.
    ///   - pullUp: Whether to enable the internal pull-up resistor. Defaults to `false`.
    ///   - pullDown: Whether to enable the internal pull-down resistor. Defaults to `false`.
    /// - Throws: A `ZephyrError` if the operation fails.
    public init(
        device: Device, pin: gpio_pin_t,
        intialState: DigitalOut.LogicLevel?,
        invert: Bool = false,
        driveMode: DigitalOut.DriveMode = .pushPull,
        pullUp: Bool = false,
        pullDown: Bool = false
    ) throws(ZephyrError) {
        self.device = device
        self.pin = pin

        var flags: GPIOFlags = [.input, .output]

        if invert {
            flags.insert(.activeLow)
        }

        switch intialState {
        case .some(.low):
            flags.insert(.outputInitLow)
        case .some(.high):
            flags.insert(.outputInitHigh)
        case .none:
            flags.insert([.outputInitLogical, .outputInitLow])
        }

        switch driveMode {
        case .pushPull:
            flags.insert(.pushPull)
        case .openDrain:
            flags.insert([.singleEnded, .openDrain])
        case .openSource:
            flags.insert([.singleEnded, .openSource])
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

    /// Initializes a `DigitalInOut` with the given GPIO pin information.
    /// - Parameters:
    ///   - dtSpec: The GPIO pin information.
    ///   - intialState: The initial state of the pin. If `nil`, the pin state is set to logical `0`.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - driveMode: The drive mode of the pin. Defaults to `.pushPull`.
    ///   - pullUp: Whether to enable the internal pull-up resistor. Defaults to `false`.
    ///   - pullDown: Whether to enable the internal pull-down resistor. Defaults to `false`.
    /// - Throws: A `GPIOInitError` if the operation fails.
    public init(
        dtSpec: gpio_dt_spec,
        intialState: DigitalOut.LogicLevel?,
        invert: Bool = false,
        driveMode: DigitalOut.DriveMode = .pushPull,
        pullUp: Bool = false,
        pullDown: Bool = false
    ) throws(DigitalOut.InitError) {
        guard withUnsafePointer(to: dtSpec, { gpio_is_ready_dt($0) }) else {
            throw .deviceNotReady
        }
        do {
            try self.init(
                device: dtSpec.port, pin: dtSpec.pin,
                intialState: intialState,
                invert: invert,
                driveMode: driveMode,
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
    /// - Note: This initializer is unsafe because it does not check if the pin is valid or even an output pin.
    internal init(uncheckedDevice: Device, pin: gpio_pin_t) {
        self.device = uncheckedDevice
        self.pin = pin
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
        set {
            let ret = gpio_pin_set(device, pin, newValue ? 1 : 0)
            assert(ret == 0, "Failed to set pin state: \(ret)")
       }
    }

    internal var level: DigitalOut.LogicLevel {
        get {
            let ret = gpio_pin_get_raw(device, pin)
            assert(ret >= 0, "Failed to get pin level: \(ret)")
            return ret == 1 ? .high : .low
        }
    }

    /// Sets the pin to a specific state.
    /// - Parameter state: `true` to set the pin to logical high, `false` to set it to logical low.
    /// - Throws: A `ZephyrError` if the operation fails.
    public func setState(_ state: Bool) throws(ZephyrError) {
        let ret = gpio_pin_set(device, pin, state ? 1 : 0)
        guard ret == 0 else {
            throw ZephyrError(code: ret)
        }
    }

    /// Sets the pin to logical high.
    /// - Throws: A `ZephyrError` if the operation fails.
    public func enable() throws(ZephyrError) {
        try setState(true)
    }
    /// Sets the pin to logical low.
    /// - Throws: A `ZephyrError` if the operation fails.
    public func disable() throws(ZephyrError) {
        try setState(false)
    }
    /// Toggles the pin state.
    /// - Throws: A `ZephyrError` if the operation fails.
    public func toggle() throws(ZephyrError) {
        let ret = gpio_pin_toggle(device, pin)
        guard ret == 0 else {
            throw ZephyrError(code: ret)
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

// ToDo: Implement interrupt handling for DigitalInOut

extension DigitalInOut {
    /// Access the pin as a `DigitalIn`.
    public var input: DigitalIn {
        DigitalIn(uncheckedDevice: device, pin: pin)
    }

    /// Access the pin as a `DigitalOut`.
    public var output: DigitalOut {
        DigitalOut(uncheckedDevice: device, pin: pin)
    }
}

extension DigitalInOut {
    /// Creates a `DigitalInOut` for a pin that is already configured as an input+output.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    /// - Returns: A `DigitalInOut` instance if the pin is configured as both input and output, otherwise `nil`.
    public static func alreadyConfigured(
        device: Device, pin: gpio_pin_t
    ) -> DigitalInOut? {
        var flags: gpio_flags_t = 0
        let ret = gpio_pin_get_config(device, pin, &flags)

        guard ret == 0, GPIOFlags(rawValue: flags).contains([.input, .output]) else {
            return nil
        }
        return DigitalInOut(uncheckedDevice: device, pin: pin)
    }
}

extension DigitalInOut: CustomStringConvertible {
    public var description: String {
        "DigitalInOut(device: \(String(cString: device.pointee.name)), pin: \(pin), state: \(state), level: \(level == .high ? "HIGH" : "LOW"))"
    }
}
