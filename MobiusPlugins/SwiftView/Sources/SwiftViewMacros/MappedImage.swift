//
//  MappedImage.swift
//  
//
//  Created by Anna Zharkova on 20.08.2023.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MappedField: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
    
    static var name: String = "MappedImage"
    
    var node: SwiftSyntax.AttributeSyntax
    
    init?(from node: SwiftSyntax.AttributeSyntax) {
        guard
            node.attributeName.as(IdentifierTypeSyntax.self)!
                .description == Self.name
        else { return nil }
        self.node = node
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        
        guard member.is(VariableDeclSyntax.self) else {
            return []
        }
        
        return [
            AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("MappedImage"))
            )
        ]
    }
}

