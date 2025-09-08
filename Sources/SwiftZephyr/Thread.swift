/**
 * Thread.swift
 * SwiftZephyr
 * 
 * Created by Hunter Baker on 9/05/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

internal import SwiftZephyrShims

public struct Thread: @unchecked Sendable, SendableMetatype {
//     /// The underlying Zephyr thread pointer.
//     public let thread: UnsafeMutablePointer<k_thread>

//     /// Creates a `Thread` from a Zephyr thread pointer.
//     /// - Parameter thread: A pointer to a Zephyr thread.
//     public init(thread: UnsafeMutablePointer<k_thread>) {
//         self.thread = thread
//     }

//     /// The thread's priority.
//     public var priority: CInt {
//         get {
//             k_thread_priority_get(thread)
//         }
//         set {
//             k_thread_priority_set(thread, newValue)
//         }
//     }

//     /// Waits for the thread to terminate.
//     /// - Parameter timeout: The maximum time to wait for the thread to terminate. Defaults to `.infinite`.
//     /// - Throws: A `ZephyrError` if the operation fails or times out.
//     public func join(timeout: Timeout = .infinite) throws(ZephyrError) {
//         let ret = k_thread_join(thread, timeout.timeout)
//         if ret != 0 {
//             throw ZephyrError(code: ret)
//         }
//     }

//     /// Aborts the thread.
//     public func abort() {
//         k_thread_abort(thread)
//     }
}

// #if CONFIG_SCHED_CPU_MASK

//     extension Thread {
//         /// Sets the CPUs that this thread is allowed to run on.
//         /// - Parameter mask: An array of CPU indices.
//         @inlinable
//         public func setAllowedCPUs<let count: Int>(mask: InlineArray<count, CInt>) throws(ZephyrError) {
//             var ret = k_thread_cpu_mask_clear(thread)
//             if ret != 0 {
//                 throw ZephyrError(code: ret)
//             }

//             for i in 0..<count {
//                 ret = k_thread_cpu_mask_enable(thread, CInt(mask[i]))
//                 if ret != 0 {
//                     throw ZephyrError(code: ret)
//                 }
//             }
//         }

//         /// Adds a CPU to the set of CPUs that this thread is allowed to run on.
//         /// - Parameter index: The index of the CPU to allow.
//         public func allowCPU(index: CInt) throws(ZephyrError) {
//             let ret = k_thread_cpu_mask_enable(thread, index)
//             if ret != 0 {
//                 throw ZephyrError(code: ret)
//             }
//         }

//         /// Removes a CPU from the set of CPUs that this thread is allowed to run on.
//         /// - Parameter index: The index of the CPU to disallow.
//         public func disallowCPU(index: CInt) throws(ZephyrError) {
//             let ret = k_thread_cpu_mask_disable(thread, index)
//             if ret != 0 {
//                 throw ZephyrError(code: ret)
//             }
//         }

//         /// Clears all allowed CPUs for this thread.
//         /// This prevents the thread from running on any CPU.
//         public func clearAllowedCPUs() throws(ZephyrError) {
//             let ret = k_thread_cpu_mask_clear(thread)
//             if ret != 0 {
//                 throw ZephyrError(code: ret)
//             }
//         }

//         /// Resets the allowed CPUs for this thread to all available CPUs.
//         /// This allows the thread to run on any CPU.
//         public func resetAllowedCPUs() throws(ZephyrError) {
//             let ret = k_thread_cpu_mask_enable_all(thread)
//             if ret != 0 {
//                 throw ZephyrError(code: ret)
//             }
//         }
//     }

// #endif

extension Thread {
    // /// The currently running thread.
    // public static var current: Thread {
    //     Self(thread: k_current_get())
    // }

    /// Yield the processor to another thread of the same priority.
    public static func yield() {
        k_yield()
    }

    /// Sleep the current thread for the specified timeout duration.
    /// - Parameter timeout: The duration to sleep.
    /// - Note: This is rounded up to the nearest millisecond.
    /// - Returns: `true` if the sleep completed without interruption, `false` if the thread was woken early.
    @discardableResult
    public static func sleep(for timeout: Timeout) -> Bool {
        let ret = k_sleep(timeout.timeout)
        return ret == 0
    }
}

// /// Internal class for thread management.
// internal final class ThreadInternal: Sendable, SendableMetatype {
//     let operation: Optional<@Sendable () -> Void>
//     var thread: k_thread
// }
