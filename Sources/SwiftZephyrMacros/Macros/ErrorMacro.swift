/*
 * ErrorMacro.swift
 * SwiftZephyr
 * -----
 * Copyright (c) 2025 - 2026 Hunter Baker hunter@literallyanything.net
 * Licensed under the MIT License
 */

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

struct ErrorMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var returns: Bool = false
        var isUnsafe: Bool = false

        // Parse the arguments
        if case .argumentList(let arguments) = node.arguments {
            for argument in arguments {
                let label = argument.label?.text.trimmingCharacters(in: .whitespacesAndNewlines)
                switch label {
                    case "returns":
                        guard let value = argument.expression.as(BooleanLiteralExprSyntax.self) else {
                            throw MacroDiagnostic(
                                message: "`@_ZephyrError` Argument 'returns' should be a boolan literal",
                                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "ErrorMacro.arguments"),
                                severity: .error
                            )
                        }
                        returns = value.literal.tokenKind == .keyword(.true)
                    case "unsafe":
                        guard let value = argument.expression.as(BooleanLiteralExprSyntax.self) else {
                            throw MacroDiagnostic(
                                message: "`@_ZephyrError` Argument 'unsafe' should be a boolan literal",
                                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "ErrorMacro.arguments"),
                                severity: .error
                            )
                        }
                        isUnsafe = value.literal.tokenKind == .keyword(.true)
                    default:
                        throw MacroDiagnostic(
                            message: "`@_ZephyrError` Unknown argument: '\(label ?? "_")'",
                            diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "ErrorMacro.arguments"),
                            severity: .error
                        )
                }
            }
        }

        // Parse the provided function signature
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroDiagnostic(
                message: "`@_ZephyrError` Can only be placed on functions",
                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "ErrorMacro.declaration"),
                severity: .error
            )
        }
        guard declaration.signature.effectSpecifiers?.throwsClause == nil else {
            throw MacroDiagnostic(
                message: "`@_ZephyrError` Function already throws",
                diagnosticID: MessageID(domain: "SwiftZephyrMacros", id: "ErrorMacro.declaration"),
                severity: .error
            )
        }

        // Copy and modify the function
        var fixedDeclaration = declaration.detached

        fixedDeclaration.attributes = fixedDeclaration.attributes.filter { attr in
            if case .attribute(let attr) = attr {
                // Get rid of @_ZephyrError to stop recursion, and remove @_alwaysEmitIntoClient because of broken imports
                let name = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text
                return name == nil || (name != "_ZephyrError" && name != "_alwaysEmitIntoClient" && name != "_disfavoredOverload")
            }
            return true
        }

        // Set throws to a typed ZephyrError
        let throwsClause = ThrowsClauseSyntax(
            throwsSpecifier: .keyword(.throws),
            leftParen: .leftParenToken(),
            type: "ZephyrError" as TypeSyntax,
            rightParen: .rightParenToken()
        )
        if fixedDeclaration.signature.effectSpecifiers != nil {
            fixedDeclaration.signature.effectSpecifiers!.throwsClause = throwsClause
        } else {
            fixedDeclaration.signature.effectSpecifiers = FunctionEffectSpecifiersSyntax(throwsClause: throwsClause)
        }

        if returns {
            fixedDeclaration.signature.returnClause = ReturnClauseSyntax(
                type: "ZephyrError" as TypeSyntax
            )
        } else {
            fixedDeclaration.signature.returnClause = nil
        }

        fixedDeclaration.body = CodeBlockSyntax {
            let functionCall = FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: declaration.name),
                leftParen: .leftParenToken(),
                rightParen: .rightParenToken()
            ) {
                for parameter in fixedDeclaration.signature.parameterClause.parameters {
                    LabeledExprSyntax(
                        label: parameter.firstName.text,
                        expression: DeclReferenceExprSyntax(baseName: parameter.secondName ?? parameter.firstName)
                    )
                }
            }

            // Call function and store return value in `ret`
            let retVar: TokenSyntax = .identifier("ret")
            VariableDeclSyntax(
                bindingSpecifier: .keyword(.let)
            ) {
                // Convert ret to ZephyrError
                let zephyrErrorValueExprBase = FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: .identifier("ZephyrError")),
                    leftParen: .leftParenToken(),
                    rightParen: .rightParenToken()
                ) {
                    LabeledExprSyntax(
                        label: "rawValue",
                        expression: functionCall
                    )
                }

                // Wrap in an unsafe statement if unsafe
                let zephyrErrorValueExpr: ExprSyntax = if isUnsafe {
                    ExprSyntax(UnsafeExprSyntax(expression: zephyrErrorValueExprBase))
                } else {
                    ExprSyntax(zephyrErrorValueExprBase)
                }

                // If async, add await
                let initExpr: ExprSyntax = if declaration.signature.effectSpecifiers?.asyncSpecifier != nil {
                    ExprSyntax(AwaitExprSyntax(expression: zephyrErrorValueExpr))
                } else {
                    ExprSyntax(zephyrErrorValueExpr)
                }

                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: retVar),
                    typeAnnotation: TypeAnnotationSyntax(type: "ZephyrError" as TypeSyntax),
                    initializer: InitializerClauseSyntax(value: initExpr)
                )
            }

            // If it is an error, throw it
            GuardStmtSyntax(
                conditions: ConditionElementListSyntax {
                    "\(retVar).rawValue >= 0" as ExprSyntax
                }
            ) {
                ThrowStmtSyntax(expression: DeclReferenceExprSyntax(baseName: retVar))
            }

            if returns {
                ReturnStmtSyntax(expression: DeclReferenceExprSyntax(baseName: retVar))
            }
        }

        return [
            DeclSyntax(fixedDeclaration)
        ]
    }
}
