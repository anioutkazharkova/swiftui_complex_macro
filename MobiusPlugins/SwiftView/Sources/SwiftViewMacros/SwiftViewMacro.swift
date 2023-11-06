import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros



enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@StructInit can only be applied to a structure"
        }
    }
}

public struct SwiftViewMacro : ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if !declaration.is(StructDeclSyntax.self) {
            return []
        }
        let body  = createBody(declaration: declaration) ?? ""
        let ext: DeclSyntax =
              """
              extension \(type.trimmed): View {
              \(raw: body)
              }
              """
        
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
    
    private static func createBody(declaration: SwiftSyntax.DeclGroupSyntax)-> String? {
        guard let structDel = declaration.as(StructDeclSyntax.self) else {
            return nil
        }
        
        let members = structDel.memberBlock.members
        
        let variableDeclarations = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        var mappedData = [MemberData]()
        variableDeclarations.forEach { declaration in
            let name = declaration.bindings.first?.pattern ?? ""
            let type = declaration.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)!.name.text ?? ""
            let attributeData = declaration.attributeData()
            
            
            mappedData.append(MemberData(name: "\(name)", typeName: type, attributeData: attributeData))
        }
        
        
        var body = """
          public var body: some View {
        VStack {
        
        """
        let textGroup = mappedData.filter{$0.attributeData.type == .text}
        let icon = mappedData.filter{$0.attributeData.type == .image}
        body += "HStack(alignment: .top, spacing: 10) {\n"
        if !icon.isEmpty {
            body += icon.first?.toView() ?? ""
        }
        if !textGroup.isEmpty {
            body += "\nVStack(alignment: .leading) {\n"
            textGroup.forEach { text in
                body += text.toView()
            }
            body += "}"
        }
        body += "}"
        /*mappedData.forEach { member in
         body += member.toView()
         }*/
        
        body += """
                }.frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        """
        
        return body
    }
}

extension SwiftViewMacro : MemberMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        // make sure that macro is being applied on a struct
        guard let structDel = declaration.as(StructDeclSyntax.self) else {
            throw StructInitError.onlyApplicableToStruct
        }
        
        let members = structDel.memberBlock.members
        
        let variableDeclarations = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        var mappedData = [MemberData]()
        variableDeclarations.forEach { declaration in
            let name = declaration.bindings.first?.pattern ?? ""
            let type = declaration.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)!.name.text ?? ""
            let attributeData = declaration.attributeData()
            
            
            mappedData.append(MemberData(name: "\(name)", typeName: type, attributeData: attributeData))
        }
        
        
        var body = """
          public var body: some View {
        VStack {
        
        """
        let textGroup = mappedData.filter{$0.attributeData.type == .text}
        let icon = mappedData.filter{$0.attributeData.type == .image}
        body += "HStack(alignment: .top, spacing: 10) {\n"
        if !icon.isEmpty {
            body += icon.first?.toView() ?? ""
        }
        if !textGroup.isEmpty {
            body += "\nVStack(alignment: .leading) {\n"
            textGroup.forEach { text in
                body += text.toView()
            }
            body += "}"
        }
        body += "}"
        /*mappedData.forEach { member in
         body += member.toView()
         }*/
        
        body += """
                }.frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        """
        
        return [DeclSyntax(stringLiteral: body)]
    }
    
}

extension VariableDeclSyntax {
    func attributeData()-> AttributeData {
        var attributeData: AttributeData? = nil
        var type: AttributeType = .unknown
        var name: String = ""
        var params: FieldAttributes? = nil
        self.attributes.forEach {
            item in
            if let attribute = item.as(AttributeSyntax.self) {
                name =  attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text ?? ""
                if name == "MappedImage" {
                    type = AttributeType.image
                }
                if name == "MappedText" {
                    type = AttributeType.text
                    if let style = attribute.arguments?.argExpSyntax() {
                        params = TextAttributes(textStyle: "\(style.trimmed.description)".style() ?? TextStyle.callout, name: "\(style.trimmed.description)")
                    }else {
                        params = TextAttributes(textStyle: .unknown)
                    }
                }
            }
            attributeData = AttributeData(name: name, type: type, params: params)
        }
        return attributeData ?? AttributeData(name: "", type: .unknown)
    }
}

extension AttributeSyntax.Arguments {
    func exprSyntax(matching key: String) -> ExprSyntax? {
        self._syntaxNode.children(viewMode: .sourceAccurate)
            .first { child in
                child.firstToken(viewMode: .sourceAccurate)?.text == key
            }?
            .as(LabeledExprSyntax.self)?
            .expression.as(MemberAccessExprSyntax.self)?.base
    }
}

extension AttributeSyntax.Arguments {
    func argExpSyntax() -> ExprSyntax? {
        return self.as(LabeledExprListSyntax.self)!.first!.expression
    }
}

extension SwiftViewMacro : MemberAttributeMacro {
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
                attributeName: IdentifierTypeSyntax(name: .identifier("State"))
                
            )
        ]
    }
}
