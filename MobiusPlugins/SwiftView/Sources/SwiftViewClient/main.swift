import SwiftView
import SwiftUI


@ListScreen
struct NewsList {
    @ListItemData
    var items: [Test]
}


//@SwiftView
@ListItem
public struct Test {
    let id = UUID().uuidString
    @MappedImage
    public var name: String = ""
    
    @MappedText(style: .title)
    public var title: String = "Title"
    
    @MappedText(style: .detail)
    public var detail: String = "Detail"
    
    @MappedText(style: .callout)
    public var date: String = "Date"
}
