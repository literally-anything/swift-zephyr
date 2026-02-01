/*
 * DigitalOut.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under MIT
 */

internal import SwiftZephyrShims

/// Represents a digital output pin in the Zephyr RTOS.
public struct DigitalOut: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr GPIO port device.
    public let device: Device
    /// The GPIO pin number.
    public let pin: gpio_pin_t

    /// Initializes a `DigitalOut` with the given device and pin number.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    ///   - intialState: The initial state of the pin. If `nil`, the pin state is set to logical `0`.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - driveMode: The drive mode of the pin. Defaults to `.pushPull`.
    /// - Throws: A `ZephyrError` if the operation fails.
    public init(
        device: Device, pin: gpio_pin_t,
        intialState: LogicLevel?,
        invert: Bool = false,
        driveMode: DriveMode = .pushPull
    ) throws(ZephyrError) {
        self.device = device
        self.pin = pin

        var flags: GPIOFlags = .output

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

        let ret = gpio_pin_configure(device, pin, flags.rawValue)
        guard ret == 0 else {
            throw ZephyrError(code: ret)
        }
    }

    /// Initializes a `DigitalOut` with the given GPIO pin information.
    /// - Parameters:
    ///   - dtSpec: The GPIO pin information.
    ///   - intialState: The initial state of the pin. If `nil`, the pin state is set to logical `0`.
    ///   - invert: Whether to invert the pin logic. Defaults to `false (active HIGH).
    ///   - driveMode: The drive mode of the pin. Defaults to `.pushPull`.
    /// - Throws: A `GPIOInitError` if the operation fails.
    public init(
        dtSpec: gpio_dt_spec,
        intialState: LogicLevel?,
        invert: Bool = false,
        driveMode: DriveMode = .pushPull
    ) throws(InitError) {
        guard withUnsafePointer(to: dtSpec, { gpio_is_ready_dt($0) }) else {
            throw .deviceNotReady
        }
        do {
            try self.init(
                device: dtSpec.port, pin: dtSpec.pin,
                intialState: intialState,
                invert: invert,
                driveMode: driveMode
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

    /// Errors that can occur when initializing a `DigitalOut`.
    public enum InitError: Error {
        /// The GPIO device is not ready.
        case deviceNotReady
        ///. A Zephyr error occurred.
        case zephyrError(ZephyrError)
    }

    /// The logic level of the pin.
    /// - Note: This is not affected by the `invert` parameter in the initializer .
    public enum LogicLevel {
        case low
        case high
    }

    /// The drive mode of the pin.
    public enum DriveMode {
        /// The pin is configured as a push-pull output.
        /// This means the pin can drive both high and low.
        case pushPull
        /// The pin is configured as an open-drain output.
        /// This means the pin will only drive low, and will float when set high.
        case openDrain
        /// The pin is configured as an open-source output.
        /// This means the pin will only drive high, and will float when set low.
        case openSource
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

    internal var level: LogicLevel {
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
}

extension DigitalOut {
    /// Creates a `DigitalOut` for a pin that is already configured as an output.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    /// - Returns: A `DigitalOut` instance if the pin is configured as an output, otherwise `nil`.
    public static func alreadyConfigured(
        device: Device, pin: gpio_pin_t
    ) -> DigitalOut? {
        var flags: gpio_flags_t = 0
        let ret = gpio_pin_get_config(device, pin, &flags)

        guard ret == 0, GPIOFlags(rawValue: flags).contains(.output) else {
            return nil
        }
        return DigitalOut(uncheckedDevice: device, pin: pin)
    }
}

extension DigitalOut: CustomStringConvertible {
    public var description: String {
        "DigitalOut(device: \(String(cString: device.pointee.name)), pin: \(pin), state: \(state), level: \(level == .high ? "HIGH" : "LOW"))"
    }
}

extension DigitalOut {
    /// Disconnects the given GPIO pin.
    /// Configures the pin to not be an input or output.
    /// - Parameters:
    ///   - device: The GPIO device.
    ///   - pin: The GPIO pin number.
    /// - Throws: A `ZephyrError` if the operation fails.
    public static func disconnect(device: Device, pin: gpio_pin_t) throws(ZephyrError) {
        let ret = gpio_pin_configure(device, pin, 0)
        guard ret == 0 else {
            throw ZephyrError(code: ret)
        }
    }

    /// Disconnects the given GPIO pin.
    /// Configures the pin to not be an input or output.
    /// - Parameter dtSpec: The GPIO pin information.
    /// - Throws: A `ZephyrError` if the operation fails.
    public static func disconnect(_ dtSpec: gpio_dt_spec) throws(ZephyrError) {
        try Self.disconnect(device: dtSpec.port, pin: dtSpec.pin)
    }
}
