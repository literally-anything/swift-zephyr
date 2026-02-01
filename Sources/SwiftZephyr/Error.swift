/*
 * Error.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

@_exported public import struct SwiftZephyrShims.ZephyrError

extension ZephyrError {
    internal var isError: Bool {
        rawValue != 0
    }
}
