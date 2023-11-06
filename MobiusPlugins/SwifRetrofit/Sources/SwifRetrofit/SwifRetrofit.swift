// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension)
@attached(peer, names: prefixed(SwiftRetrofit))
public macro SwiftRetrofit() = #externalMacro(module: "SwifRetrofitMacros",
                                                  type: "SwiftRetrofitMacro")

@attached(peer, names: arbitrary)
public macro Get(path: String) = #externalMacro(module: "SwifRetrofitMacros",
                                                          type: "GetMacro")

@attached(member)
public macro Query(name: String) = #externalMacro(module: "SwifRetrofitMacros",
                                                            type: "QueryMacro")

