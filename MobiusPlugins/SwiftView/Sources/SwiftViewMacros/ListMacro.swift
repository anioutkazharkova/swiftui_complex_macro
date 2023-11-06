//
//  ListMacro.swift
//  
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ListMacro: PeerMacro, MemberMacro{
    
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // This macro must be attached to a protocol declaration
        guard let structDeclSyntax = declaration.as(StructDeclSyntax.self) else {
            //context.addDiagnostics(from: SwiftRetrofitError.notAProtocol, node: node)
            return []
        }
        
        // The protocol name
        let name = structDeclSyntax.name.text
        
        // Generates get/post/delete functions based on the attritube of the function
        let itemsProperty = structDeclSyntax.memberBlock.members.compactMap { member in
            if (member.decl.as(VariableDeclSyntax.self)?.attributes.first { e in
                e.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ListItemData"
            }?.as(AttributeSyntax.self) != nil)
            {
                (member.decl.as(VariableDeclSyntax.self))
            } else {
                nil
            }
            
        }
        let itemsName = itemsProperty.first?.bindings.first?.pattern ?? ""
        
        let itemsType = itemsProperty.first?.bindings.first?.typeAnnotation?.type
            .as(ArrayTypeSyntax.self)?.element
            .as(IdentifierTypeSyntax.self)?.name.text ?? ""
        
        
        let classDecl = try StructDeclSyntax("public struct \(raw: "\(name)ItemsScreen"): View") {
            DeclSyntax("private var \(raw: itemsName):[\(raw: itemsType)]")
            try InitializerDeclSyntax("public init(\(raw: itemsName): [\(raw: itemsType)])") {
                CodeBlockItemListSyntax([
                    .init(item: .decl("self.\(raw: itemsName) = \(raw: itemsName)"))
                    
                ])
            }
            try VariableDeclSyntax("""
public var body: some View {
 List(\(raw: itemsName),id: \\.id) { item in
 item.toView()
}
}
""")
        }
        
        
        return [DeclSyntax(classDecl)]
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}
