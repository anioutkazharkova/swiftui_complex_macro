//
//  DI.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwifRetrofit



class DI {
    static let shared = DI()
    
    lazy var networkClient: NetworkClient = {
        return NetworkClient.Builder(config: NetworkConfiguration())
            .build()
    }()
    
    lazy var newsService: NewsService? = {
        return SwiftRetrofitNewsService
            .createInstance(client: networkClient)
    }()
}
