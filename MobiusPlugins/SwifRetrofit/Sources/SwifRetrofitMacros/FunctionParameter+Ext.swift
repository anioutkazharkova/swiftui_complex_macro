//
//  File.swift
//
//
//  Created by Anna Zharkova on 06.11.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension FunctionParameterSyntax {
    func getQueryText()->String? {
        guard let apiAttribute = self.createAttribute() else {
            return nil
        }
        return apiAttribute.apiBuilderStatement()
    }
    
    func tryGetQueryName() -> String? {
        guard let attributeSyntax = self.attributes.first?.as(AttributeSyntax.self) else {
            return nil
        }
        
        if attributeSyntax.attributeName.description != "Query" {
            return nil
        }
        
        guard let argument = attributeSyntax.arguments?
            .as(LabeledExprListSyntax.self)?
            .first?.as(LabeledExprSyntax.self) else {
            return nil
        }
        
        if argument.label?.text != "name" {
            return nil
        }
        
        guard let stringLiteralExprSyntax = argument.expression.as(StringLiteralExprSyntax.self) else {
            return nil
        }
        
        let nameValue = stringLiteralExprSyntax.segments.reduce(into: "") { partialResult, e in
            if let syntax = e.as(StringSegmentSyntax.self) {
                partialResult += syntax.content.text
            }
        }
        
        return nameValue.isEmpty ? nil : nameValue
    }
}


