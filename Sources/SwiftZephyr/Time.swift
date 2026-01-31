/**
 * Time.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/06/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

public import SwiftZephyrShims

@_exported public import struct SwiftZephyrShims.Timespec
@_exported public import struct SwiftZephyrShims.Timeout
@_exported public import struct SwiftZephyrShims.Timepoint

// -------- Timespec --------

// Conformances
extension Timespec: Swift.Equatable, Swift.Hashable {
    public static func == (lhs: Timespec, rhs: Timespec) -> Bool {
        unsafe withUnsafePointer(to: lhs) { lhs in
            unsafe withUnsafePointer(to: rhs) { rhs in
                unsafe timespec_equal(lhs, rhs)
            }
        }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tv_sec)
        hasher.combine(tv_nsec)
    }
}

// Helpers
extension Timespec {
    /// Creates a `Timespec` structure from a Zephyr `Timeout`.
    /// - Parameter timeout: A Zephyr `Timeout`.
    public init(_ timeout: borrowing Timeout) {
        var ts = Timespec()
        unsafe timespec_from_timeout(timeout, &ts)
        self = ts
    }

    /// Get the current time using `SYS_CLOCK_MONOTONIC`.
    public static var now: Timespec {
        var time = Timespec()
        let ret = unsafe sys_clock_gettime(SYS_CLOCK_MONOTONIC, &time)
        assert(ret == 0, "Timespec monotonic clock ID is wrong")
        return time
    }
    /// Get the current time using `SYS_CLOCK_REALTIME`.
    public static var nowRealtime: Timespec {
        var time = Timespec()
        let ret = unsafe sys_clock_gettime(SYS_CLOCK_REALTIME, &time)
        assert(ret == 0, "Timespec realtime clock ID is wrong")
        return time
    }
}
extension Timespec {
    public static func +=(lhs: inout Timespec, rhs: Timespec) {
        let success: Bool = unsafe withUnsafePointer(to: rhs) { rhs in
            unsafe timespec_add(&lhs, rhs)
        }
        guard success else {
            fatalError("Integer overflow while adding timespec")
        }
    }
    public static func -=(lhs: inout Timespec, rhs: Timespec) {
        let success: Bool = unsafe withUnsafePointer(to: rhs) { rhs in
            unsafe timespec_sub(&lhs, rhs)
        }
        assert(success, "Integer overflow while subtracting timespec")
    }
    public static prefix func -(lhs: inout Timespec) {
        let success: Bool = unsafe timespec_negate(&lhs)
        assert(success, "Integer overflow while negating timespec")
    }
    /// Normalize a timespec by adjusting the tv_sec and tv_nsec fields so that the tv_nsec field is in the range [0, NSEC_PER_SEC-1].
    /// This is achieved by converting nanoseconds to seconds and accumulating seconds in either the positive direction when tv_nsec > NSEC_PER_SEC, or in the negative direction when tv_nsec < 0.
    public mutating func normalize() {
        let success: Bool = unsafe timespec_normalize(&self)
        assert(success, "Integer overflow while normalizing timespec")
    }

    public static func +(lhs: Timespec, rhs: Timespec) -> Timespec {
        var sum = lhs
        sum += rhs
        return sum
    }
    public static func -(lhs: Timespec, rhs: Timespec) -> Timespec {
        var sum = lhs
        sum -= rhs
        return sum
    }
    /// Normalize a timespec by adjusting the tv_sec and tv_nsec fields so that the tv_nsec field is in the range [0, NSEC_PER_SEC-1].
    /// This is achieved by converting nanoseconds to seconds and accumulating seconds in either the positive direction when tv_nsec > NSEC_PER_SEC, or in the negative direction when tv_nsec < 0.
    public var normalized: Timespec {
        var time: Timespec = self
        time.normalize()
        return time
    }
}
extension Timespec {
    /// Get the duration from one time to another as a `Timeout`.
    /// - Parameter other: The end `Timespec`.
    /// - Returns: A `Timeout`.
    public func timeout(to other: Timespec) -> Timeout {
        Timeout(other - self)
    }
}

// -------- Timeout --------

// Conformances
extension Timeout: Swift.ExpressibleByIntegerLiteral {
    /// Initialize using an integer literal representing milliseconds.
    /// - Parameter value: The value in milliseconds.
    public init(integerLiteral milliseconds: Int32) {
        self = Timeout.milliseconds(milliseconds)
    }
}

// Helpers
extension Timeout {
    /// Represents an infinite timeout.
    public static var infinite: Timeout {
        Timeout(ticks: -1)
    }

    /// Represents a zero timeout.
    public static var zero: Timeout {
        Timeout(ticks: 0)
    }
    /// Represents a zero timeout.
    public static var immediate: Timeout {
        .zero
    }

    /// Initialize a `Timeout` from a `Timespec` structure.
    /// - Parameter timespec: A `Timespec` structure.
    public init(_ timespec: borrowing Timespec) {
        self = unsafe withUnsafePointer(to: timespec) { timespec in
            unsafe timespec_to_timeout(timespec, nil)
        }
    }
}
