/**
 * DeviceMacro.swift
 * Macros
 * 
 * Created by Hunter Baker on 1/30/2026
 * Copyright (C) 2026-2026, by Hunter Baker hunter@literallyanything.net
 */

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

struct DeviceMacro: ExpressionMacro {
    static func expansion(
        of macroNode: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Ensure one argument
        let allowedLabels: [String?] = [nil, "path", "label", "alias"]
        guard macroNode.arguments.count == 1, allowedLabels.contains(macroNode.arguments.first!.label?.text) else {
            let error = MacroDiagnostic(
                message: "`#dtDevice` takes one argument. The label must be one of `path`, `label`, `alias` or no label for auto.",
                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceMacro.arguments"),
                severity: .error
            )
            context.diagnose(
                Diagnostic(node: macroNode.arguments, message: error)
            )
            throw error
        }

        // Ensure that the argument is a string literal
        let argument = macroNode.arguments.first!
        let error = MacroDiagnostic(
            message: "`#dtDevice(\(argument.label?.text ?? "_"):)` must be passed a string literal.",
            diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceMacro.argumentType"),
            severity: .error
        )
        guard let argumentValue = argument.expression.as(StringLiteralExprSyntax.self), argumentValue.segments.count == 1 else {
            context.diagnose(Diagnostic(node: argument.expression, message: error))
            throw error
        }
        guard case .stringSegment(let argumentStr) = argumentValue.segments.first! else {
            context.diagnose(Diagnostic(node: argument.expression, message: error))
            throw error
        }

        // Get the node from the device tree
        let node: DeviceTree.Node? = switch argument.label?.text {
            case "path":
                try DeviceTree.shared.lookup(path: argumentStr.content.text)
            case "label":
                try DeviceTree.shared.lookup(label: argumentStr.content.text)
            case "alias":
                try DeviceTree.shared.lookup(alias: argumentStr.content.text)
            default:
                (try? DeviceTree.shared.lookup(path: argumentStr.content.text)) ??
                (try? DeviceTree.shared.lookup(label: argumentStr.content.text)) ??
                (try? DeviceTree.shared.lookup(alias: argumentStr.content.text))
        }
        guard let node else {
            let error = MacroDiagnostic(
                message: "Device could not be found.",
                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "DeviceMacro.arguments"),
                severity: .error
            )
            context.diagnose(Diagnostic(node: macroNode, message: error))
            throw error
        }

        let deviceRef = try node.deviceRef
        return "Zephyr.DeviceTree.\(deviceRef)" as ExprSyntax
    }
}
