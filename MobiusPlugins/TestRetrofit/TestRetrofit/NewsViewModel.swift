//
//  NewsViewModel.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import Observation

@Observable class NewsViewModel {
    var newsItems = [NewsItem]()
    var service = DI.shared.newsService
    
    @MainActor
    func load() {
        Task { [weak self] in
            guard let self = self else {return}
            do {
                let items = try await service?.loadNews(query: ("q", "space"))
                self.newsItems.removeAll()
                self.newsItems.append(contentsOf: items?.articles ?? [])
            }catch {
                print(error)
            }
        }
    }
}
