/*
 * Error.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

@_exported public import struct SwiftZephyrShims.ZephyrError

extension ZephyrError {
    public var isError: Bool {
        rawValue < 0
    }
}

/// Wraps a function with a Zephyr return code in a throwing function.
/// 
/// This is intended to be attached to C functions on import.
@attached(peer, names: overloaded)
public macro _ZephyrError(
    returns: Bool = false,
    unsafe: Bool = false
) = #externalMacro(module: "SwiftZephyrMacros", type: "ErrorMacro")
