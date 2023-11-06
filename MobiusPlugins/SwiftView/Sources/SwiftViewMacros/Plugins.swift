//
//  Plugins.swift
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
struct SwiftViewPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SwiftViewMacro.self,
        MappedField.self,
        ListMacro.self,
        ListItemDataMacro.self,
        ListItemMacro.self
    ]
}
