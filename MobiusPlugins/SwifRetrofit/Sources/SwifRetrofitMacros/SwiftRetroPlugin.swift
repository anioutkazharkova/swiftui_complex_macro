//
//  SwiftRetroPlugin.swift
//  
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct SwifRetrofitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SwiftRetrofitMacro.self,
        GetMacro.self,
        QueryMacro.self
    ]
}
