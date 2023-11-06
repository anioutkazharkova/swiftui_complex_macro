//
//  NewsRetrofit.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwifRetrofit

@SwiftRetrofit
public protocol NewsService {
    
    @Get(path: "everything")
    func loadNews(query: QueryParam<String>)async throws ->NewsList
    
}

