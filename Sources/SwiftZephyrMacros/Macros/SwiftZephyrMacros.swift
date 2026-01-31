/**
 * SwiftZephyrMacros.swift
 * Macros
 * 
 * Created by Hunter Baker on 1/29/2026
 * Copyright (C) 2026-2026, by Hunter Baker hunter@literallyanything.net
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
