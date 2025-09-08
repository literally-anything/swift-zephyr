/**
 * Error.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/05/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

public struct ZephyrError: Error {
    public var code: Int32

    public init(code: Int32) {
        self.code = code
    }

    // ToDo: Make this more user-friendly.
}
