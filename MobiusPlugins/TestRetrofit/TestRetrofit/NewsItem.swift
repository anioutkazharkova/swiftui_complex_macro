//
//  NewsItem.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwiftView
import SwiftUI

@ListItem
public struct NewsItem: Codable {
    
    let id = UUID().uuidString
    @MappedImage
    var urlToImage: String = ""
    @MappedText(style: .title)
        var title: String = ""
        
    @MappedText(style: .detail)
        var content: String = ""
    @MappedText(style: .callout)
    var publishedAt: String = ""
    
    enum  CodingKeys: String, CodingKey {
            case title, urlToImage, publishedAt, content
        }
    
    public init(from decoder: Decoder) throws {
           let values = try decoder.container(keyedBy: CodingKeys.self)
           title = (try? values.decode(String.self, forKey: .title)) ?? ""
          publishedAt = (try? values.decode(String.self, forKey: .publishedAt)) ?? ""
        
        urlToImage = (try? values.decode(String.self, forKey: .urlToImage)) ?? ""
        content = (try? values.decode(String.self, forKey: .content)) ?? ""
       }
}

@ListScreen
public struct NewsList: Codable {
    var status: String?
    var total: Int = 0
    @ListItemData
    var articles: [NewsItem]

    enum CodingKeys : String, CodingKey {
        case total = "totalResults"
        case articles = "articles"
        case status = "status"
    }

}
