//
//  Util.swift
//  TestRetrofit
//
//  Created by Anna Zharkova on 27.08.2023.
//

import Foundation

extension Date {

    func formatToString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
         let locale = Calendar.current.locale
            formatter.locale = locale

        return formatter.string(from: self)
}
}
