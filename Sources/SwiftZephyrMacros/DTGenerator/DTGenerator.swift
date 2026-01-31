/**
 * DTGenerator.swift
 * DTGenerator
 * 
 * Created by Hunter Baker on 1/30/2026
 * Copyright (C) 2026-2026, by Hunter Baker hunter@literallyanything.net
 */

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftBasicFormat
import Foundation

struct GeneratorError: Error, CustomStringConvertible {
    let description: String
}

@main
public struct DTGenerator {
    public static func main() throws {
        guard CommandLine.arguments.count == 5 else {
            let message = "usage: SwiftZephyrDTGenerator <output-file> <shims-module-name> <dt-type> <device-type>"
            print(message)
            throw GeneratorError(description: message)
        }
        let outputFile = URL(filePath: CommandLine.arguments[1])
        let shimsModuleName = TokenSyntax.identifier(CommandLine.arguments[2])
        let dtTypeName = TokenSyntax.identifier(CommandLine.arguments[3])
        let deviceType = TokenSyntax.identifier(CommandLine.arguments[4])

        let fileContents = try CodeBlockItemListSyntax {
            ImportDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.internal))
                },
                path: ImportPathComponentListSyntax {
                    ImportPathComponentSyntax(name: shimsModuleName)
                }
            )

            try ExtensionDeclSyntax(
                extendedType: IdentifierTypeSyntax(name: dtTypeName),
            ) {
                // Build an accessor for each device ref
                for deviceRefName in try DeviceTree.shared.deviceRefs {
                    VariableDeclSyntax(
                        modifiers: DeclModifierListSyntax {
                            DeclModifierSyntax(name: .keyword(.public))
                            DeclModifierSyntax(name: .keyword(.static))
                        },
                        .var,
                        name: "\(deviceRefName)",
                        type: TypeAnnotationSyntax(type: "\(deviceType)" as TypeSyntax),
                        accessorBlock: AccessorBlockSyntax(
                            accessors: AccessorBlockSyntax.Accessors(
                                CodeBlockItemListSyntax {
                                    ReturnStmtSyntax(expression: "\(shimsModuleName).\(deviceRefName)" as ExprSyntax)
                                }
                            )
                        )
                    )
                }
            }
        }

        // Write out the file
        print("Writing output to \(outputFile)")
        let fileSyntax = SourceFileSyntax(statements: fileContents)
        var fileText = String()
        fileSyntax.formatted().write(to: &fileText)
        try fileText.write(to: outputFile, atomically: true, encoding: .utf8)
    }
}
