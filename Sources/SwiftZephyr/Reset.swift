/**
 * App.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/05/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

/// Flags for the reason that the system was reset.
public struct ResetReasonFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// External pin.
    public static let pin: ResetReasonFlags = .init(rawValue: 1 << 0)
    /// Software reset.
    public static let software: ResetReasonFlags = .init(rawValue: 1 << 1)
    /// Brownout (drop in voltage)
    public static let brownout: ResetReasonFlags = .init(rawValue: 1 << 2)
    /// Power-on reset (POR)
    public static let por: ResetReasonFlags = .init(rawValue: 1 << 3)
    /// Watchdog timer expiration.
    public static let watchdog: ResetReasonFlags = .init(rawValue: 1 << 4)
    /// Debug event.
    public static let debug: ResetReasonFlags = .init(rawValue: 1 << 5)
    /// Security violation.
    public static let security: ResetReasonFlags = .init(rawValue: 1 << 6)
    /// Waking up from low power mode.
    public static let lowPower: ResetReasonFlags = .init(rawValue: 1 << 7)
    /// CPU lock-up detected.
    public static let cpuLockup: ResetReasonFlags = .init(rawValue: 1 << 8)
    /// Parity error.
    public static let parity: ResetReasonFlags = .init(rawValue: 1 << 9)
    /// PLL error.
    public static let pll: ResetReasonFlags = .init(rawValue: 1 << 10)
    /// Clock error.
    public static let clock: ResetReasonFlags = .init(rawValue: 1 << 11)
    /// Hardware reset.
    public static let hardware: ResetReasonFlags = .init(rawValue: 1 << 12)
    /// User reset.
    public static let user: ResetReasonFlags = .init(rawValue: 1 << 13)
    /// Temperature reset.
    public static let temperature: ResetReasonFlags = .init(rawValue: 1 << 14)
    /// Bootloader reset (entry / exit)
    public static let bootloader: ResetReasonFlags = .init(rawValue: 1 << 15)
    /// Flash ECC reset.
    public static let flash: ResetReasonFlags = .init(rawValue: 1 << 16)
}

/// Access to reset reason information.
public enum ResetReason: SendableMetatype {
    /// The last reset reason flags.
    /// This is updated on each reset.
    public static let lastReason = getResetReason()

    /// Get the current reset reason flags.
    /// Accessed through `self.lastReason`.
    internal static func getResetReason() -> ResetReasonFlags {
        var reasonFlags: UInt32 = 0
        let ret = hwinfo_get_reset_cause(&reasonFlags)
        if ret != 0 {
            print("Failed to get reset reason: \(ret)")
        }

        return ResetReasonFlags(rawValue: reasonFlags)
    }
}

/// Reboot the system.
/// - Parameter cold: If true, perform a cold reboot (full power cycle). Default is false (warm reboot).
/// - Note: This function does not return.
public func rebootSystem(cold: Bool = false) -> Never {
    sys_reboot(cold ? 1 : 0)
}
