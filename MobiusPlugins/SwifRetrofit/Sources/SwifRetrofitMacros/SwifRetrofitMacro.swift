import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros



public struct SwiftRetrofitMacro: PeerMacro {
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        
        let name = protocolSyntax.name.text
        let functions = protocolSyntax.memberBlock.members.map { member in
            createGetFunction(syntax: member, context: context)
        }
        
        let classDecl = try ClassDeclSyntax("public class \(raw: "SwiftRetrofit\(name)"): \(raw: name),NetworkServiceProtocol") {
            try FunctionDeclSyntax("public static func createInstance(client: NetworkClient) -> any \(raw: "\(name)")") {
                CodeBlockItemSyntax(item: .decl("return \(raw: "SwiftRetrofit\(name)")(client: client)"))
            }
            
            DeclSyntax("private let client: NetworkClient")
            
            try InitializerDeclSyntax("private init(client: NetworkClient)") {
                CodeBlockItemListSyntax([
                    .init(item: .decl("self.client = client"))
                ])
            }
            
            for function in functions  {
                MemberBlockItemSyntax(decl: function)
            }
            createUrlComponents()
        }
        
        return [DeclSyntax(classDecl)]
    }
    
    private static func createUrlComponents()->DeclSyntax {
        return """
        func createUrl(path: String, queryItems: [URLQueryItem])->URLComponents? {
                guard var urlComponents = URLComponents(string: client.baseURL.absoluteString) else {
                   return nil 
                }
                  urlComponents.path += path
        if !queryItems.isEmpty {
                  urlComponents.queryItems =  queryItems
        }
                  
        return urlComponents
        }
        """
    }
    
    private static func createHeaders() -> DeclSyntax {
        return """
        func setHeaders(request: inout URLRequest, httpMethod: String, headers: [String: String]) {
            headers.forEach { (k, v) in
                request.setValue(v, forHTTPHeaderField: k)
            }
            request.httpMethod = httpMethod
        }
        """
    }
    
    private static func createGetFunction(syntax: MemberBlockItemListSyntax.Element,
                                          context: some MacroExpansionContext) -> DeclSyntax {
        return generateFunctionDecl(syntax: syntax, context: context, attributeName: "Get") { funcDecl, getAttr in
            guard let appendPathExpr = getAttr.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
                return ""
            }
            
            let returnType = funcDecl.signature.returnClause?.type.description ?? ""
            
            var queryItems: [String] = []
            let parameters = funcDecl.signature.parameterClause.parameters.map { $0.as(FunctionParameterSyntax.self) }
            
            parameters.forEach { parameter in
                if let parameter {
                    let parameterNameLiteral = parameter.firstName.text
                    
                    if let statement = parameter.getQueryText(), !statement.isEmpty {
                        queryItems.append(statement)
                    }
                }
            }
            let path = "\(appendPathExpr)"
            
            return """
            public func \(funcDecl.name)\(raw: funcDecl.signature.description) {
                guard let url = createUrl(path: \(raw: path), queryItems: [ \(raw: queryItems.filter{!$0.isEmpty}.joined(separator: ",\n"))]) else {
                                throw NetworkError.parameterError("failed to create URLComponents")
               }
                return try await client.request(urlComponents: url)
            }
            """
        }
    }
    
    private static func generateFunctionDecl(syntax: MemberBlockItemListSyntax.Element,
                                             context: some MacroExpansionContext,
                                             attributeName: String,
                                             block: (FunctionDeclSyntax, AttributeSyntax) -> DeclSyntax) -> DeclSyntax {
        if let itemSyntax = syntax.as(MemberBlockItemSyntax.self),
           let funcDecl = itemSyntax.decl.as(FunctionDeclSyntax.self) {
            let matchedAttributeSyntax = funcDecl.attributes.first { e in
                e.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName
            }?.as(AttributeSyntax.self)
            
            guard let matchedAttributeSyntax else {
                context.addDiagnostics(from: SwiftRetrofitError.argumentNotFound(["getFuncDecl", "matchedAttributeSyntax"]),
                                       node: funcDecl._syntaxNode)
                return ""
            }
            
            return block(funcDecl, matchedAttributeSyntax)
        } else {
            return ""
        }
    }
}



