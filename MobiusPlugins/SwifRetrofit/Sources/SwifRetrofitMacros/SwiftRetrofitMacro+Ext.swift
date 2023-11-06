//
//  File.swift
//  
//
//  Created by Anna Zharkova on 06.11.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension SwiftRetrofitMacro : ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if !declaration.is(ProtocolDeclSyntax.self) {
            return []
        }
        let ext: DeclSyntax =
              """
              extension \(type.trimmed){
              }
              """
        
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
    
}
