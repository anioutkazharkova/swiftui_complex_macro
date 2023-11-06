//
//  ContentView.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State var model = NewsViewModel()
    
    var body: some View {
        VStack {
            NewsListItemsScreen(articles: model.newsItems)
           /* List(model.newsItems, id: \.id) { item in
                NewsItemRow(item: item)
            }*/
        }.onAppear {
            model.load()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
