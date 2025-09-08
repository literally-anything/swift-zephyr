/**
 * Time.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/06/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

/// Represents a point in time using Zephyr's timespec structure.
public struct Time: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr timespec structure.
    public let timespec: SwiftZephyrShims.timespec
}

extension Time: Equatable, Hashable {
    public static func == (lhs: Time, rhs: Time) -> Bool {
        lhs.timespec.tv_sec == rhs.timespec.tv_sec &&
        lhs.timespec.tv_nsec == rhs.timespec.tv_nsec
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(timespec.tv_sec)
        hasher.combine(timespec.tv_nsec)
    }
}

/// Represents a timeout value for Zephyr kernel operations.
public struct Timeout: @unchecked Sendable, SendableMetatype {
    /// The underlying Zephyr time value.
    public let timeout: k_timeout_t

    /// Creates a `Timeout` from a Zephyr timeout value.
    /// - Parameter timeout: A Zephyr timeout value.
    public init(timeout: k_timeout_t) {
        self.timeout = timeout
    }

    /// Creates a `Timeout` representing the specified number of seconds.
    /// - Parameter seconds: The number of seconds.
    /// - Returns: A `Timeout` instance.
    public static func seconds(_ seconds: Int32) -> Timeout {
        Timeout(timeout: _sToKTimeout(seconds))
    }
    /// Creates a `Timeout` representing the specified number of milliseconds.
    /// - Parameter milliseconds: The number of milliseconds.
    /// - Returns: A `Timeout` instance.
    public static func milliseconds(_ milliseconds: Int32) -> Timeout {
        Timeout(timeout: _msToKTimeout(milliseconds))
    }
    /// Creates a `Timeout` representing the specified number of microseconds.
    /// - Parameter microseconds: The number of microseconds.
    /// - Returns: A `Timeout` instance.
    public static func microseconds(_ microseconds: Int32) -> Timeout {
        Timeout(timeout: _usToKTimeout(microseconds))
    }
    /// Creates a `Timeout` representing the specified number of nanoseconds.
    /// - Parameter nanoseconds: The number of nanoseconds.
    /// - Returns: A `Timeout` instance.
    public static func nanoseconds(_ nanoseconds: Int32) -> Timeout {
        Timeout(timeout: _nsToKTimeout(nanoseconds))
    }
}

extension Timeout {
    /// Represents an infinite timeout.
    public static var infinite: Timeout {
        Timeout(timeout: k_timeout_t(ticks: -1))
    }

    /// Represents a zero timeout.
    public static var zero: Timeout {
        Timeout(timeout: k_timeout_t(ticks: 0))
    }

    /// Represents a zero timeout.
    public static var immediate: Timeout {
        .zero
    }
}

extension Timeout: ExpressibleByIntegerLiteral {
    /// Initialize using an integer literal representing milliseconds.
    /// - Parameter value: The value in milliseconds.
    public init(integerLiteral milliseconds: Int32) {
        self.timeout = _msToKTimeout(milliseconds)
    }
}

extension Timeout: Equatable, Hashable {
    public static func == (lhs: Timeout, rhs: Timeout) -> Bool {
        lhs.timeout.ticks == rhs.timeout.ticks
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(timeout.ticks)
    }
}

extension Timeout {
    /// Initialize a `Timeout` from a `Time` instance.
    /// - Parameter time: A `Time` instance.
    public init(_ time: borrowing Time) {
        self.timeout = withUnsafePointer(to: time.timespec) { timespecPtr in
            timespec_to_timeout(timespecPtr)
        }
    }
}

extension Time {
    /// Creates a `Time` instance from a Zephyr `Timeout`.
    /// - Parameter timeout: A Zephyr `Timeout`.
    public init(_ timeout: borrowing Timeout) {
        var ts = SwiftZephyrShims.timespec()
        timespec_from_timeout(timeout.timeout, &ts)
        self.timespec = ts
    }
}
