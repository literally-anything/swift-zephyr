/*
 * Reset.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

internal import SwiftZephyrShims

/// Flags for the reason that the system was reset.
#if !CONFIG_HWINFO
@available(*, unavailable, message: "ResetReasonFlags is unavailable because CONFIG_HWINFO must be enabled in Zephyr")
#endif
public struct ResetReasonFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// External pin.
    public static var pin: ResetReasonFlags { .init(rawValue: 1 << 0) }
    /// Software reset.
    public static var software: ResetReasonFlags { .init(rawValue: 1 << 1) }
    /// Brownout (drop in voltage)
    public static var brownout: ResetReasonFlags { .init(rawValue: 1 << 2) }
    /// Power-on reset (POR)
    public static var por: ResetReasonFlags { .init(rawValue: 1 << 3) }
    /// Watchdog timer expiration.
    public static var watchdog: ResetReasonFlags { .init(rawValue: 1 << 4) }
    /// Debug event.
    public static var debug: ResetReasonFlags { .init(rawValue: 1 << 5) }
    /// Security violation.
    public static var security: ResetReasonFlags { .init(rawValue: 1 << 6) }
    /// Waking up from low power mode.
    public static var lowPower: ResetReasonFlags { .init(rawValue: 1 << 7) }
    /// CPU lock-up detected.
    public static var cpuLockup: ResetReasonFlags { .init(rawValue: 1 << 8) }
    /// Parity error.
    public static var parity: ResetReasonFlags { .init(rawValue: 1 << 9) }
    /// PLL error.
    public static var pll: ResetReasonFlags { .init(rawValue: 1 << 10) }
    /// Clock error.
    public static var clock: ResetReasonFlags { .init(rawValue: 1 << 11) }
    /// Hardware reset.
    public static var hardware: ResetReasonFlags { .init(rawValue: 1 << 12) }
    /// User reset.
    public static var user: ResetReasonFlags { .init(rawValue: 1 << 13) }
    /// Temperature reset.
    public static var temperature: ResetReasonFlags { .init(rawValue: 1 << 14) }
    /// Bootloader reset (entry / exit)
    public static var bootloader: ResetReasonFlags { .init(rawValue: 1 << 15) }
    /// Flash ECC reset.
    public static var flash: ResetReasonFlags { .init(rawValue: 1 << 16) }
}

/// Access to reset reason information.
#if !CONFIG_HWINFO
@available(*, unavailable, message: "ResetReason is unavailable because CONFIG_HWINFO must be enabled in Zephyr")
#endif
public enum ResetReason: SendableMetatype {
    /// The last reset reason flags.
    /// This is updated on each reset.
    public static let lastReason = getResetReason()

    /// Get the current reset reason flags.
    /// Accessed through `self.lastReason`.
    internal static func getResetReason() -> ResetReasonFlags {
        var reasonFlags: UInt32 = 0
        let ret = unsafe hwinfo_get_reset_cause(&reasonFlags)
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
