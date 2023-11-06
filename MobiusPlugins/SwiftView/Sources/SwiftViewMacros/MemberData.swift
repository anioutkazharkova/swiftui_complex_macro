//
//  MemberData.swift
//
//
//  Created by Anna Zharkova on 21.08.2023.
//

import Foundation

struct MemberData {
    var name: String
    var typeName: String
    var optional: Bool = false
    
    var attributeData: AttributeData
}

extension MemberData {
    func toImage(_ nodeName: String = "")->String {
        
        return """
        let image = \(nodeName)\(self.name) ??  \"\"
        if !image.isEmpty {
             AsyncImage(url: URL(string: image)){ image in
                 image
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     
             } placeholder: {
                 Color.gray
             }
             .frame(width: 100, height: 100)
        } else {
                         Color.gray.frame(width: 100, height: 100)
        }
        """
    }
    
    func toText(_ nodeName: String = "")->String {
        var body = "Text(\(nodeName)\(self.name))"
        if  let attrs = (self.attributeData.params as? TextAttributes)  {
            body += ".font(.\(attrs.textStyle.styleName)).lineLimit(3)"
        }
        return body
    }
    func toView(_ nodeName: String = "")->String {
        let node = nodeName.isEmpty ? "" : "\(nodeName)."
        switch (self.attributeData.type) {
        case .image:
            return toImage(node)
        case .text:
            return toText(node)
        default:
            return ""
        }
        
    }
}

enum AttributeType : String{
    case image
    case text
    case unknown
}

struct AttributeData {
    var name: String
    var type: AttributeType
    var params: FieldAttributes? = nil
}

protocol FieldAttributes {}

struct TextAttributes: FieldAttributes {
    var textStyle: TextStyle
    var name: String = ""
}

public enum TextStyle: String {
    case title
    case detail
    case callout
    case unknown
    
    var styleName: String {
        switch self {
        case .title:
            return "title3" + ".weight(.bold)"
        case .detail:
            return "subheadline"
        case .callout:
            return "callout"
        default:
            return "callout"
        }
    }
}

extension String {
    func style()->TextStyle? {
        let name =  self.replacingOccurrences(of: ".", with: "")
        return TextStyle(rawValue: name)
    }
}
