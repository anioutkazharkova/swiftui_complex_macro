// The Swift Programming Language
// https://docs.swift.org/swift-book



//@attached(member, names: named(body))
@attached(extension, names: arbitrary)
public macro SwiftView() = #externalMacro(module: "SwiftViewMacros", type: "SwiftViewMacro")

@attached(peer)
public macro MappedImage(_ value: String = "") = #externalMacro(module: "SwiftViewMacros", type: "MappedField")

@attached(peer)
public macro MappedText(style : TextStyle) = #externalMacro(module: "SwiftViewMacros", type: "MappedField")

public enum TextStyle: String {
    case title
    case detail
    case callout
}

@attached(member, names: arbitrary)
@attached(peer, names: suffixed(ItemsScreen))
public macro ListScreen() = #externalMacro(module: "SwiftViewMacros",
                                                  type: "ListMacro")

@attached(member, names: arbitrary)
@attached(peer, names: suffixed(ItemRow))
@attached(extension, names: arbitrary)
public macro ListItem() = #externalMacro(module: "SwiftViewMacros",
                                                          type: "ListItemMacro")

@attached(peer, names: arbitrary)
public macro ListItemData() = #externalMacro(module: "SwiftViewMacros",
                                                          type: "ListItemDataMacro")
