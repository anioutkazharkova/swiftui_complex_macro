//
//  NetworkClient.swift
//  
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation


public typealias Path<T> = T
public typealias Header<T> = T
public typealias QueryParam<T> = (String, T)
public typealias Field<T> = T
public typealias Body<T> = T

@propertyWrapper
public struct QueryPart<Value:Any> {
    private var value: Value?  = nil
    
    private var name: String
    
    public init(name: String = "") {
        self.name = name
    }

    public var wrappedValue: Value? {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
}


public enum NetworkError: Error {
    case parameterError(_ message: String = "")
    case apiError(_ message: String = "")
}

public protocol INetworkConfiguration {
    func getHeaders() -> [String: String]
    
    func getBaseUrl() -> String
}

public class NetworkClient {
    // TODO Could have used macros to generate the builder.
    public class Builder {
        public var baseURL: URL
        public var session: URLSession
        public var defaultHeaders: [String: String] = [:]
        
        public init(config: INetworkConfiguration) {
            self.baseURL = URL(string: config.getBaseUrl())!
            self.defaultHeaders = config.getHeaders()
            self.session = URLSession(configuration: .default)
        }
        
        public init(baseUrl: URL, headers: [String:String] = [:]) {
            self.baseURL = baseUrl
            self.defaultHeaders = headers
            self.session = URLSession(configuration: .default)
        }
        
        public init(baseURL: URL, session: URLSession = .shared) {
            self.baseURL = baseURL
            self.session = session
        }
        
        public func defaultHeaders(headers: [String:String]) -> NetworkClient.Builder {
            headers.forEach { (k, v) in
                self.defaultHeaders[k] = v
            }
            return self
        }
        
        public func build() -> NetworkClient {
            return NetworkClient(
                baseURL: baseURL,
                session: session,
                headers: defaultHeaders
            )
        }
    }
    
    public let baseURL: URL
    public let session: URLSession
    public let defaultHeaders: [String: String]
    
    public lazy var jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
        
    private init(
        baseURL: URL,
        session: URLSession,
        headers: [String:String]
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = headers
    }
    
    public func createService<T: NetworkServiceProtocol>(of type: T.Type) -> T {
        return type.createInstance(client: self) as! T
    }
    
    public func request<T:Codable>(urlComponents: URLComponents)async throws->T {
        guard let finalURL = urlComponents.url else {
            throw NetworkError.parameterError("failed to create url")
        }
        
        let type = T.self
        
        var request = URLRequest(url: finalURL)
        setHeaders(request: &request, httpMethod: "GET", headers: defaultHeaders)
    
        let (data, _) = try await session.data(for: request)
        print(String.init(data: data, encoding: .utf8))
        return try jsonDecoder.decode(type, from: data)
    }
    
    public func request<T:Codable>(path: String, queryItems: [String:String]=[:])async throws->T {
      
        guard var urlComponents = URLComponents(string: self.baseURL.absoluteString) else {
            throw NetworkError.parameterError("failed to create URLComponents")
        }
        
        urlComponents.path += path
        urlComponents.queryItems = queryItems.map{ (k,v) in
            URLQueryItem(name: k, value: v)
        }
        
        guard let finalURL = urlComponents.url else {
            throw NetworkError.parameterError("failed to create url")
        }
        
        let type = T.self
        
        var request = URLRequest(url: finalURL)
        setHeaders(request: &request, httpMethod: "GET", headers: defaultHeaders)
    
        let (data, _) = try await session.data(for: request)
        return try jsonDecoder.decode(type, from: data)
    }
    
    private func setHeaders(request: inout URLRequest, httpMethod: String, headers: [String: String]) {
        headers.forEach { (k, v) in
            request.setValue(v, forHTTPHeaderField: k)
        }
        request.httpMethod = httpMethod
    }
}

public protocol NetworkServiceProtocol {
    associatedtype ClassType = Self
    static func createInstance(client: NetworkClient) -> ClassType
}
