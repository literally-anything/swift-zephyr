/*
 * SwiftZephyrMacros.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import SwiftDiagnostics

struct MacroDiagnostic: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}

@main
struct MacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DeviceMacro.self
    ]
}
