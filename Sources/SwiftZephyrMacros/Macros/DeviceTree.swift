/*
 * DeviceTree.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

import Foundation
import RegexBuilder
import SwiftDiagnostics
import SwiftSyntax

#if SWIFTPM_BUILD
// Placeholder value so that the build succeeds
let generatedHeader: String = ""
#endif

struct DeviceTreeDiagnostic: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}

extension Substring {
    var unquoted: Substring {
        get throws {
            guard hasPrefix("\""), hasSuffix("\"") else {
                throw DeviceTreeDiagnostic(
                    message: "Device tree value should be quoted, but was not",
                    diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.unquoted"),
                    severity: .error
                )
            }
            return self[
                index(after: startIndex)
                ..<
                index(before: endIndex)
            ]
        }
    }
}

/// Parses and represents the device tree from 
final class DeviceTree: Sendable {
    /// The shared instance of `DeviceTree`.
    static let shared: DeviceTree = DeviceTree()

    private let mappings: [Substring: Substring]

    private init() {
        let headerLines: [String] = generatedHeader.split(whereSeparator: \.isNewline).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Find all devicetree macros that have no arguments
        let defineRegex = Regex {
            "#define"
            OneOrMore(.whitespace)

            // Capture name: 1
            Capture {
                "DT_"
                OneOrMore(.word)
            }

            OneOrMore(.whitespace)

            // Capture value: 2
            Capture {
                OneOrMore(.anyNonNewline)
            }
        }
        let defineLines = headerLines.compactMap{ $0.wholeMatch(of: defineRegex) }

        // Save mappings
        var mappings: [Substring: Substring] = [:]
        for line in defineLines {
            let (key, value) = (line.output.1, line.output.2)
            mappings[key] = value
        }
        self.mappings = mappings
    }

    /// All the device reference names that are defined and okay in the device tree.
    var deviceRefs: Set<TokenSyntax> {
        get throws {
            var refs: Set<TokenSyntax> = []
            for node in try nodes {
                guard node.isOkay else {
                    continue
                }
                refs.insert(try node.deviceRef)
            }
            return refs
        }
    }

    /// Represents a single node in the device tree
    struct Node {
        private let tree: DeviceTree
        let path: String

        /// Make a node. This also checks if the node exists and will return `nil` if not.
        fileprivate init?(tree: DeviceTree, path: String) {
            self.tree = tree
            self.path = path

            guard isValid else {
                return nil
            }
        }

        /// Verifies that the node refers to a real node in the device tree
        private var isValid: Bool {
            if let macroName = try? getMacroFor(path: path) {
                return tree.mappings.keys.contains("\(macroName)_EXISTS")
            }
            return false
        }

        /// The base name for all of the C macros in the device tree mappings.
        /// - Note: This will crash in the case that the node has an invalid path.
        var macroName: String {
            try! getMacroFor(path: path)
        }

        /// Grab the parent node by using the `_PARENT` suffix. `nil` if no parent.
        var parent: Node? {
            if let macroName = try? getMacroFor(path: path) {
                let parentMacro = tree.mappings["\(macroName)_PARENT"]
                if let parentMacro {
                    let parentPath = getPathFor(macro: parentMacro)
                    return Node(tree: tree, path: parentPath)
                }
            }
            return nil
        }

        /// Append a relative path to the device path.
        /// All paths are interpreted as relative. `.` and `..` are supported.
        func appending(path addedPath: String) -> Node? {
            var pathComponents = path.split(separator: "/")
            let addedComponents = addedPath.split(separator: "/")
            for component in addedComponents {
                if component == "." {
                    continue
                } else if component == ".." {
                    _ = pathComponents.popLast()
                } else {
                    pathComponents.append(component)
                }
            }
            let newPath = pathComponents.reduce(into: "/", { $0.append("/\($1)") })
            return Node(tree: tree, path: newPath)
        }

        /// Get a specific attribute of a device.
        func getAttribute(key: String) -> Substring? {
            tree.mappings["\(macroName[...])_\(key)"]
        }

        /// The device's ordinal: DT_N_S_(device path)_ORD
        var ordinal: Substring {
            get throws {
                let ordValue = getAttribute(key: "ORD")
                guard let ordValue else {
                    throw DeviceTreeDiagnostic(
                        message: "Device tree node has no ordinal: \(path)",
                        diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.missingOrdinal"),
                        severity: .error
                    )
                }
                return ordValue
            }
        }

        /// The name of the Zephyr immortal device reference.
        var deviceRef: TokenSyntax {
            get throws {
                let ord = try ordinal
                return getDeviceRefIdentifier(ordinal: ord)
            }
        }

        /// The status of the node (okay or disabled).
        var isOkay: Bool {
            tree.mappings.keys.contains("\(macroName)_STATUS_okay")
        }
    }

    /// All nodes in the device tree.
    /// This is probably far too slow to be used macros.
    var nodes: [Node] {
        get throws {
            // Get each device's path
            let deviceOrdKeys = mappings.keys.filter { $0.hasSuffix("_ORD") }
            let deviceNames = deviceOrdKeys.map { $0.dropLast("_ORD".count) }
            let devicePathKeys = deviceNames.map { "\($0)_PATH" }
            let devicePaths = try devicePathKeys.compactMap { pathKey in
                let path = try mappings[pathKey[...]]?.unquoted
                guard let path else {
                    throw DeviceTreeDiagnostic(
                        message: "Device tree node has no path: \(pathKey)",
                        diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.invalidNode"),
                        severity: .error
                    )
                }
                return path
            }
            

            // Turn that into a list of nodes
            let nodes: [Node] = try devicePaths.map { path in
                let node = Node(tree: self, path: String(path))
                guard let node else {
                    throw DeviceTreeDiagnostic(
                        message: "Invalid device tree node for path: \(path)",
                        diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.invalidNode"),
                        severity: .error
                    )
                }
                return node
            }
            return nodes
        }
    }

    /// Get the node at a path.
    /// Throws if the path is malformed.
    /// Returns `nil` if the node does not exist.
    func lookup(path: String) throws -> Node? {
        _ = try getMacroFor(path: path)
        return Node(tree: self, path: path)
    }
    /// Get the node with a node label.
    /// Throws if the label is malformed.
    /// Returns `nil` if the node does not exist.
    func lookup(label: String) throws -> Node? {
        let labelMacro = try getMacroFor(label: label)
        guard let nodeMacro = mappings[labelMacro[...]] else {
            return nil
        }

        let nodePath = getPathFor(macro: nodeMacro)
        return Node(tree: self, path: nodePath)
    }
    /// Get the node with an alias.
    /// Throws if the alias is malformed.
    /// Returns `nil` if the node does not exist.
    func lookup(alias: String) throws -> Node? {
        let aliasMacro = try getMacroFor(alias: alias)
        guard let nodeMacro = mappings[aliasMacro[...]] else {
            return nil
        }

        let nodePath = getPathFor(macro: nodeMacro)
        return Node(tree: self, path: nodePath)
    }
}

private let nodeNamePrefix = "DT_N"
private let nodeLabelPrefix = "\(nodeNamePrefix)_NODELABEL"
private let nodeAliasPrefix = "\(nodeNamePrefix)_ALIAS"

func getDeviceRefIdentifier(ordinal: Substring) -> TokenSyntax {
    TokenSyntax.identifier("__device_dts_ord_\(ordinal)")
}

private func cleanPathComponent(_ component: any StringProtocol) -> String {
    component
        .replacingOccurrences(of: ",", with: "_")
        .replacingOccurrences(of: "-", with: "_")
        .replacingOccurrences(of: "@", with: "_")
        .lowercased()
}

private func getMacroFor(path: String) throws -> String {
    guard path.starts(with: "/") else {
        throw DeviceTreeDiagnostic(
            message: "Device tree paths must start with a slash",
            diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.slashStart"),
            severity: .error
        )
    }
    let pathComponents = path.split(separator: "/")

    var macroName = nodeNamePrefix
    for component in pathComponents {
        let cleanedComponent = cleanPathComponent(component)
        macroName.append("_S_\(cleanedComponent)")
    }
    return macroName
}

private func getMacroFor(label: String) throws -> String {
    guard !label.starts(with: "/") else {
        throw DeviceTreeDiagnostic(
            message: "Device tree labels must not start with a slash",
            diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.slashStart"),
            severity: .error
        )
    }

    var macroName = nodeLabelPrefix

    let cleanedName = cleanPathComponent(label)
    macroName.append("_\(cleanedName)")

    return macroName
}

private func getMacroFor(alias: String) throws -> String {
    guard !alias.starts(with: "/") else {
        throw DeviceTreeDiagnostic(
            message: "Device tree aliases must not start with a slash",
            diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceTree.slashStart"),
            severity: .error
        )
    }

    var macroName = nodeAliasPrefix

    let cleanedName = cleanPathComponent(alias)
    macroName.append("_\(cleanedName)")

    return macroName
}

private func getPathFor(macro: any StringProtocol) -> String {
    let trimmedMacro = macro.trimmingPrefix(nodeNamePrefix)
    return trimmedMacro.replacingOccurrences(of: "_S_", with: "/")
}
