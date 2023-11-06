//
//  ListItemExt.swift
//
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension ListItemMacro : ExtensionMacro, PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if !declaration.is(StructDeclSyntax.self) {
            return []
        }
        let ext: DeclSyntax =
              """
              extension \(type.trimmed) {
              
                func toView()-> \(type.trimmed)ItemRow {
                return \(type.trimmed)ItemRow(item: self)
                }
              }
              """
        
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDeclSyntax = declaration.as(StructDeclSyntax.self) else {
            //context.addDiagnostics(from: SwiftRetrofitError.notAProtocol, node: node)
            return []
        }
        
        // The protocol name
        let name = structDeclSyntax.name.text
        let members = structDeclSyntax.memberBlock.members
        
        let variableDeclarations = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        var mappedData = [MemberData]()
        mappedData.append(contentsOf:   variableDeclarations.map {
            $0.mapElement()
        })
        let body = preparyBody(mappedData: mappedData)
        
        let classDecl = try StructDeclSyntax("public struct \(raw: "\(name)ItemRow"): View") {
            DeclSyntax("private var item: \(raw: name)")
            try InitializerDeclSyntax("public init(item: \(raw: name))") {
                CodeBlockItemListSyntax([
                    .init(item: .decl("self.item = item"))
                    
                ])
            }
            try VariableDeclSyntax(
"""
public var body: some View {
 VStack {
\(raw: body)
}
}
""")
        }
        
        return [DeclSyntax(classDecl)]
    }
    
    private static func preparyBody(mappedData: [MemberData])->String {
        var body = """
        VStack {
        
        """
        let textGroup = mappedData.filter{$0.attributeData.type == .text}
        let icon = mappedData.filter{$0.attributeData.type == .image}
        body += "HStack(spacing: 10) {\n"
        if !icon.isEmpty {
            body += icon.first?.toView("item") ?? ""
        }
        if !textGroup.isEmpty {
            body += "\nVStack {\n"
            textGroup.forEach { text in
                body += text.toView("item")
            }
            body += "}"
        }
        body += "}"
        
        
        body += """
                }.frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        """
        return body
    }
}

extension VariableDeclSyntax {
    func mapElement()->MemberData {
        let declaration = self
        let name = declaration.bindings.first?.pattern ?? ""
        let type = declaration.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)!.name.text ?? ""
        let attributeData = declaration.attributeData()
        
        return MemberData(name: "\(name)", typeName: type, attributeData: attributeData)
    }
}
