//
//  NetworkConfiguration.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation
import SwifRetrofit

class NetworkConfiguration : INetworkConfiguration{

    private let apiUrl = "https://newsapi.org/v2/"
    private let apiKey = "5b86b7593caa4f009fea285cc74129e2"

    func getHeaders() -> [String: String] {
        return ["X-Api-Key":apiKey]
    }

    func getBaseUrl() -> String {
        return apiUrl
    }

}
