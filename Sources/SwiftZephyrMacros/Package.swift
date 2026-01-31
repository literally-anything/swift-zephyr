/**
 * Package.swift
 * SwiftZephyrMacros
 * 
 * Created by Hunter Baker on 1/29/2026
 * Copyright (C) 2026-2026, by Hunter Baker hunter@literallyanything.net
 */
// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

// This is just for editor completions because CMake was causing some problems
let package = Package(
    name: "SwiftZephyrMacros",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .macro(
            name: "SwiftZephyrMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Macros",
            swiftSettings: [.define("SWIFTPM_BUILD")]
        ),
        .executableTarget(
            name: "DTGenerator",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ],
            path: "DTGenerator",
            swiftSettings: [.define("SWIFTPM_BUILD")]
        )
    ]
)
