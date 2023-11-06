//
//  SwiftRetrofitError.swift
//  
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwiftDiagnostics

public enum SwiftRetrofitError: Error, DiagnosticMessage {
    case argumentNotFound(_ arguments: [String])
    case notAProtocol
    
    public var message: String {
        switch self {
        case .argumentNotFound(let arguments):
            return "Argument of \(arguments.joined(separator: ",")) not found"
        case .notAProtocol:
            return "The attached declaration is not a protocol"
        }
    }
    
    public var diagnosticID: SwiftDiagnostics.MessageID {
        switch self {
        case .argumentNotFound(_):
            return .init(domain: "Photonfire", id: "argumentNotFound")
        case .notAProtocol:
            return .init(domain: "Photonfire", id: "notAProtocol")
        }
    }
    
    public var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}
