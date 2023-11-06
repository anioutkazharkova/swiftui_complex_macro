//
//  NewsItemRow.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import SwiftUI
import Kingfisher

struct NewsItemRow: View {
    @State var item: NewsItem
        
        var body: some View {
            HStack(alignment: .top) {
                KFImage(URL(string: item.urlToImage ?? "")).frame(width: 100, height: 100, alignment: .center).aspectRatio(contentMode: .fill).clipped()

              //
                VStack(alignment: .leading, spacing: 7) {
                    Text(item.title).lineLimit(4).textTitle()
                    Text(item.content).lineLimit(4).subtextTitle()
                    Text(item.publishedAt).smallTitle()
                }
            }.background(Color.white)
        }
}


