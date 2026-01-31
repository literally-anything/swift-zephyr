/**
 * Error.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/05/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

@_exported public import struct SwiftZephyrShims.ZephyrError

extension ZephyrError {
    internal var isError: Bool {
        rawValue != 0
    }
}
