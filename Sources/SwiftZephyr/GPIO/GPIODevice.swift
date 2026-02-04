/*
 * GPIODevice.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

public import SwiftZephyrShims

@_exported import struct SwiftZephyrShims.GPIOSpec
@_exported import typealias SwiftZephyrShims.GPIOFlagRaw
@_exported import enum SwiftZephyrShims.GPIODirection
@_exported import enum SwiftZephyrShims.GPIOActiveLevel
@_exported import enum SwiftZephyrShims.GPIOPinDriveMode
@_exported import enum SwiftZephyrShims.GPIOPinBias
@_exported import struct SwiftZephyrShims.GPIOInterruptFlags

extension GPIOSpec {
    /// Check if a pin is configured for input
    public var isInput: Bool {
        get throws(ZephyrError) {
            let error = __isInput()
            if error.isError {
                throw error
            }
            return error.rawValue == 1
        }
    }
    /// Check if a pin is configured for output
    public var isOutput: Bool {
        get throws(ZephyrError) {
            let error = __isOutput()
            if error.isError {
                throw error
            }
            return error.rawValue == 1
        }
    }
}

extension GPIOSpec: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "GPIOSpec(port: \(port.debugDescription), pin: \(pin))"
    }
}
