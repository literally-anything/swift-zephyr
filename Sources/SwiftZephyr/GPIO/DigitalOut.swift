/*
 * DigitalOut.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

internal import SwiftZephyrShims

/// Represents a digital output GPIO pin in the Zephyr RTOS.
public struct DigitalOut: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr GPIO device info.
    public let device: GPIOSpec

    /// Initialize a `DigitalOut` from an already confgured GPIO device spec.
    /// - Parameter device: The GPIO device that is already configured as an input.
    /// - Returns: `nil` if the device is not ready.
    public init?(
        alreadyConfigured device: GPIOSpec
    ) {
        guard device.isReady else { return nil }
        assert((try? device.isOutput) != false, "\(device.debugDescription) is not configured as an input.")
        self.device = device
    }
    /// Initialize a `DigitalOut` from an unconfgured device spec or by reconfiguring one.
    /// - Parameters:
    ///     - device: The GPIO device to be reconfigured.
    ///     - extraFlags: Extra GPIO flags to pass when configuring.
    /// - Returns: `nil` if the device is not ready.
    /// - Throws: `ZephyrError` if configuring fails.
    public init?(
        device: GPIOSpec,
        activeLevel: GPIOActiveLevel = .activeHigh,
        driveMode: GPIOPinDriveMode = .pushPull,
        extraFlags: GPIOFlagRaw = 0
    ) throws(ZephyrError) {
        guard device.isReady else { return nil }
        self.device = device

        var flags = extraFlags
        flags |= activeLevel.rawValue
        flags |= driveMode.rawValue
        flags |= GPIODirection.output.rawValue

        let error = device.__configure(extraFlags: flags)
        guard !error.isError else {
            throw error
        }
    }
}

extension DigitalOut {
    /// The current GPIO flags for this pin.
    /// - Throws: If there was an error fetching the configuration.
    public var configuration: GPIOFlagRaw {
        get throws(ZephyrError) {
            var flags: GPIOFlagRaw = 0
            let error = unsafe device.__getConfig(flags: &flags)
            guard !error.isError else {
                throw error
            }
            return flags
        }
    }

    /// Reconfigure the pin. This only changes settings that are passed unless `reset` is `true`.
    /// - Parameters:
    ///     - activeLevel: The logical active level of the pin.
    ///     - driveMode: The drive mode of the pin.
    ///     - extraFlags: Any extra flags to be added.
    ///     - reset: When `true`, discard all prevous configuration.
    /// - Throws: If there was any error in fetching or setting the configuration.
    public func configure(
        activeLevel: GPIOActiveLevel? = nil,
        driveMode: GPIOPinDriveMode? = nil,
        extraFlags: GPIOFlagRaw = 0,
        reset: Bool = false
    ) throws(ZephyrError) {
        var flags: GPIOFlagRaw
        if reset {
            flags = 0
        } else {
            flags = try configuration
        }

        if let activeLevel {
            flags |= activeLevel.rawValue
        }
        if let driveMode {
            flags |= driveMode.rawValue
        }
        flags |= extraFlags

        let error = device.__configure(extraFlags: flags)
        guard !error.isError else {
            throw error
        }
    }
}

extension DigitalOut {
    /// The current logical sate of the pin.
    public var state: Bool {
        get throws(ZephyrError) {
            let error = device.__getLogical()
            guard !error.isError else {
                throw error
            }
            return error.rawValue == 1
        }
    }
    /// Sets the logical state of the pin.
    /// - Parameter state: `true` for HIGH, `false` for LOW.
    /// - Throws: If there was an error setting the state.
    public func set(state: Bool) throws(ZephyrError) {
        let error = device.__setLogical(value: state ? 0 : 1)
        guard !error.isError else {
            throw error
        }
    }

    /// The current physical state of the pin.
    public var physicalState: Bool {
        @available(*, unavailable)
        get throws(ZephyrError) {
            let error = GPIOSpec.__getPhysical(port: device.port, pin: device.pin)
            guard !error.isError else {
                throw error
            }
            return error.rawValue == 1
        }
    }
    /// Sets the physical state of the pin.
    /// - Parameter state: `true` for HIGH, `false` for LOW.
    /// - Throws: If there was an error setting the state.
    public func set(physicalState state: Bool) throws(ZephyrError) {
        let error = GPIOSpec.__setPhysical(port: device.port, pin: device.pin, value: state ? 0 : 1)
        guard !error.isError else {
            throw error
        }
    }

    /// Toggle the state of the pin.
    /// - Throws: If there was an error toggling the pin.
    public func toggle() throws(ZephyrError) {
        let error = device.__toggle()
        guard !error.isError else {
            throw error
        }
    }
}

extension DigitalOut: CustomStringConvertible {
    public var description: String {
        "DigitalOut(port: \(unsafe String(cString: device.port.name)), pin: \(device.pin))"
    }
}

extension DigitalOut {
    /// Disconnects the given GPIO pin.
    /// Configures the pin to not be an input or output.
    /// - Throws: A `ZephyrError` if the operation fails.
    public func disconnect() throws(ZephyrError) {
        try configure(
            extraFlags: GPIODirection.disconnected.rawValue,
            reset: true
        )
    }
}
