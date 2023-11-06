//
//  File.swift
//  
//
//  Created by Anna Zharkova on 15.10.2023.
//
import Foundation
import SwiftSyntax

extension String {
    var withoutQuotes: String {
        filter { $0 != "\"" }
    }
}

extension FunctionParameterSyntax {
    func createAttribute()->APIAttribute? {
        let type = self.type.as(IdentifierTypeSyntax.self)?.name.text ?? ""
        let name = self.firstName.text 
        switch type {
       
        case "Body":
            return  .body
        case "QueryParam":
            return .query(key: name)
        case "Header":
            return.header(key: name)
        case "Path":
           return .path(key: name)
     
        default:
            return nil
        }
    }
}

extension AttributeSyntax {
    func createAttribure()->APIAttribute? {
        var firstArgument: String?
        var secondArgument: String?
        var labeledArguments: [String: String] = [:]
        if case let .argumentList(list) = self.arguments {
            for argument in list {
                if let label = argument.label {
                    labeledArguments[label.description] = argument.expression.description
                }
            }

            firstArgument = list.first?.expression.description
            secondArgument = list.dropFirst().first?.expression.description
        }

        let name = self.attributeName.trimmedDescription
        switch name {
       
        case "Body":
            return  .body
        case "QueryParam":
            return .query(key: firstArgument?.withoutQuotes)
        case "Header":
            return.header(key: firstArgument?.withoutQuotes)
        case "Path":
           return .path(key: firstArgument?.withoutQuotes)
     
        default:
            return nil
        }
    }
}


enum APIAttribute {
    /// Parameter attributes
    case body
    case query(key: String?)
    case header(key: String?)
    case path(key: String?)
    
    func apiBuilderStatement(input: String? = nil) -> String? {
        switch self {
        case .body:
            guard let input else {
                return "Input Required!"
            }

            return """
            req.setBody(\(input))
            """
        case let .query(key):
            return 
            ".init(name: \(key ?? "").0, value: String(describing:\(key ?? "").1))"
        
        case let .header(key):
            guard let input else {
                return "Input Required!"
            }

            let hasCustomKey = key == nil
            let convertParameter = hasCustomKey ? "" : ", convertToHeaderCase: true"
            return """
            req.addHeader("\(key ?? input)", value: \(input)\(convertParameter))
            """
        case let .path(key):
            guard let input else {
                return "Input Required!"
            }

            return """
            req.addParameter("\(key ?? input)", value: \(input))
            """
        }
    }
}

