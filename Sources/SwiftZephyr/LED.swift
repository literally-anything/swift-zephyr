/**
 * LED.swift
 * SwiftZephyr
 *
 * Created by Hunter Baker on 9/04/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

/// Represents an LED device in the Zephyr RTOS.
/// Works with both single-color and multi-color LEDs.
/// - Note: This structure is only available if the `CONFIG_LED` configuration option is enabled in Zephyr.
@safe
#if CONFIG_LED
@available(*, unavailable, message: "LED support is not enabled in Zephyr (CONFIG_LED must be enabled)")
#endif
public struct LED: @unchecked Sendable, SendableMetatype {
    // /// The LED device information structure.
    // @usableFromInline
    // internal let spec: led_dt_spec

    // /// Initializes an LED structure for the LED at the given index on the given device.
    // /// - Parameters:
    // ///   - device: The device containing the LED.
    // ///   - index: The index of the LED on the device.
    // /// - Throws: `InitError.deviceNotReady` if the LED device is not ready.
    // public init(device: consuming Device, index: UInt32) throws(InitError) {
    //     self.spec = led_dt_spec(dev: device, index: index)
    //     let ready = withUnsafePointer(to: spec) { led_is_ready_dt($0) }
    //     guard ready else {
    //         throw .deviceNotReady
    //     }
    // }

    // /// An error that can occur during LED initialization.
    // public enum InitError: Error {
    //     /// The LED device is not ready.
    //     case deviceNotReady
    // }

    // /// Sets whether the LED is enabled (on) or disabled (off).
    // /// - Parameter enabled: `true` to enable (turn on) the LED, `false` to disable (turn off) the LED.
    // /// - Throws: `ZephyrError` if there is an error setting the LED state.
    // public func setEnabled(_ enabled: Bool) throws(ZephyrError) {
    //     let ret = withUnsafePointer(to: spec) {
    //         if enabled {
    //             return led_on_dt($0)
    //         } else {
    //             return led_off_dt($0)
    //         }
    //     }
    //     guard ret == 0 else {
    //         throw ZephyrError(code: ret)
    //     }
    // }

    // /// Enables (turns on) the LED.
    // /// - Throws: `ZephyrError` if there is an error enabling the LED.
    // public func enable() throws(ZephyrError) {
    //     try setEnabled(true)
    // }

    // /// Disables (turns off) the LED.
    // /// - Throws: `ZephyrError` if there is an error disabling the LED.
    // public func disable() throws(ZephyrError) {
    //     try setEnabled(false)
    // }

    // /// Sets the brightness of the LED. 0 is off, 100 is maximum brightness.
    // /// - Parameter brightness: The brightness level (0-100).
    // /// - Throws: `ZephyrError` if there is an error setting the brightness.
    // public func setBrightness(_ brightness: UInt8) throws(ZephyrError) {
    //     let ret = withUnsafePointer(to: spec) {
    //         led_set_brightness_dt($0, brightness)
    //     }
    //     guard ret == 0 else {
    //         throw ZephyrError(code: ret)
    //     }
    // }

    // /// Sets the color of a multi-color LED using an array of color channel values.
    // /// - Parameter channels: An `InlineArray` containing the color channel values (e.g., RGB). Should be the same number returned by `getInfo`.
    // /// - Throws: `ZephyrError` if there is an error setting the color.
    // @inlinable
    // public func setColor<let numColors: Int>(_ channels: borrowing InlineArray<numColors, UInt8>) throws(ZephyrError) {
    //     let ret = channels.span.withUnsafeBufferPointer { buffer in
    //         led_set_color(spec.dev, spec.index, UInt8(numColors), buffer.baseAddress)
    //     }
    //     guard ret == 0 else {
    //         throw ZephyrError(code: ret)
    //     }
    // }

    // /// Sets the LED to blink with the specified on and off delays.
    // /// - Parameters:
    // ///   - delayOn: The delay in milliseconds for which the LED stays on.
    // ///   - delayOff: The delay in milliseconds for which the LED stays off.
    // /// - Throws: `ZephyrError` if there is an error setting the blink parameters.
    // public func setBlink(delayOn: UInt32, delayOff: UInt32) throws(ZephyrError) {
    //     let ret = led_blink(spec.dev, spec.index, delayOn, delayOff)
    //     guard ret == 0 else {
    //         throw ZephyrError(code: ret)
    //     }
    // }
}

// extension LED {
//     /// Get information about the LED at the given index on the given device.
//     /// - Parameters:
//     ///   - device: The device containing the LED.
//     ///   - index: The index of the LED on the device.
//     /// - Returns: A tuple containing the LED index and the number of color channels.
//     /// - Throws: `ZephyrError` if there is an error retrieving the LED information
//     public static func getInfo(for device: Device, index: UInt32) throws(ZephyrError) -> (index: UInt32, numColors: UInt8) {
//         var info: UnsafePointer<led_info>? = nil
//         let ret = led_get_info(device, index, &info)
//         guard ret == 0, let info else {
//             throw ZephyrError(code: ret)
//         }

//         // ToDo: Provide color mappings

//         return (info.pointee.index, info.pointee.num_colors)
//     }
// }
