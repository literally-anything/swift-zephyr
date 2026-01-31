/**
 * Device.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 1/29/2026
 * Copyright (C) 2026-2026, by Hunter Baker hunter@literallyanything.net
 */

public import SwiftZephyrShims

@_exported public import class SwiftZephyrShims.Device
@_exported public import struct SwiftZephyrShims.DeviceHandle

extension Device: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
        unsafe String(cString: name)
    }
    public var debugDescription: String {
        "Device(name: \(unsafe String(cString: name)))"
    }
}

extension Device {
    /// Initialize a `Device`.
    /// 
    /// A device whose initialization was deferred (by marking it as zephyr,deferred-init on devicetree) needs to be initialized manually via this call.
    /// De-initialized devices can also be initialized again via this call.
    /// 
    /// - Throws: EALREADY Device is already initialized.
    public func initialize() throws(ZephyrError) {
        let error = self.__initialize()
        if error.isError {
            throw error
        }
    }
    /// De-initialize a `Device`.
    /// 
    /// When a device is de-initialized, it will release any resources it has acquired (e.g. pins, memory, clocks, DMA channels, etc.) and its status will be left as in its reset state.
    /// 
    /// - Note: this will be available if CONFIG_DEVICE_DEINIT_SUPPORT is enabled.
    /// - Warning: It is the responsibility of the caller to ensure that the device is ready to be de-initialized.
    /// - Throws: EPERM If device has not been initialized. ENOTSUP If device does not support de-initialization, or if the feature is not enabled (see CONFIG_DEVICE_DEINIT_SUPPORT).
    #if !CONFIG_DEVICE_DEINIT_SUPPORT
    @available(*, unavailable, message: "device deinit is not enabled in Zephyr (CONFIG_DEVICE_DEINIT_SUPPORT must be enabled)")
    #endif
    public func deinitialize() throws(ZephyrError) {
        let error = __deinitialize()
        if error.isError {
            throw error
        }
    }
}

#if CONFIG_DEVICE_DEPS
    extension Device {
        /// Get the device handles for injected dependencies of this device.
        /// 
        /// The array contains a handle for each device that @p dev manually injected as a dependency, via providing extra arguments to Z_DEVICE_DEFINE.
        /// This does not include transitive dependencies; you must recursively determine those.
        public var injectedDevices: Span<DeviceHandle> {
            @_lifetime(borrow self)
            get {
                var count: Int = 0
                let buffer = unsafe __get_injected_handles(count: &count)
                let span = unsafe UnsafeBufferPointer(start: buffer, count: count).span
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }
        /// Get the device handles for devicetree dependencies of this device.
        /// 
        /// The array contains a handle for each device that @p dev requires directly, as determined from the devicetree.
        /// This does not include transitive dependencies; you must recursively determine those.
        public var requiredDevices: Span<DeviceHandle> {
            @_lifetime(borrow self)
            get {
                var count: Int = 0
                let buffer = unsafe __get_required_handles(count: &count)
                let span = unsafe UnsafeBufferPointer(start: buffer, count: count).span
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }
        /// Get the set of handles that this device supports.
        /// 
        /// The array contains a handle for each device that @p dev "supports" -- that is, devices that require @p dev directly -- as determined from the devicetree.
        /// This does not include transitive dependencies; you must recursively determine those.
        public var supportedDevices: Span<DeviceHandle> {
            @_lifetime(borrow self)
            get {
                var count: Int = 0
                let buffer = unsafe __get_supported_handles(count: &count)
                let span = unsafe UnsafeBufferPointer(start: buffer, count: count).span
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }
    }
#else
    extension Device {
        @available(*, unavailable, message: "device dependencies are not enabled in Zephyr (CONFIG_DEVICE_DEPS must be enabled)")
        public var injectedDevices: Span<DeviceHandle> { @_lifetime(immortal) get {} }
        @available(*, unavailable, message: "device dependencies are not enabled in Zephyr (CONFIG_DEVICE_DEPS must be enabled)")
        public var requiredDevices: Span<DeviceHandle> { @_lifetime(immortal) get {} }
        @available(*, unavailable, message: "device dependencies are not enabled in Zephyr (CONFIG_DEVICE_DEPS must be enabled)")
        public var supportedDevices: Span<DeviceHandle> { @_lifetime(immortal) get {} }
    }
#endif

/// The Zephyr device tree.
/// This is used to lookup devices by ordinal number.
public enum DeviceTree: SendableMetatype {
    // The DTGenerator will fill this in later.
    // See Sources/SwiftZephyrMacros/cmake/MacroSetup.cmake:37
}

@freestanding(expression)
public macro dtDevice(_: any StringProtocol) -> Device = #externalMacro(module: "SwiftZephyrMacros", type: "DeviceMacro")
@freestanding(expression)
public macro dtDevice(path: any StringProtocol) -> Device = #externalMacro(module: "SwiftZephyrMacros", type: "DeviceMacro")
@freestanding(expression)
public macro dtDevice(label: any StringProtocol) -> Device = #externalMacro(module: "SwiftZephyrMacros", type: "DeviceMacro")
@freestanding(expression)
public macro dtDevice(alias: any StringProtocol) -> Device = #externalMacro(module: "SwiftZephyrMacros", type: "DeviceMacro")
