//
//  DateExtensions.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

extension Date {
    func toString(formatType: DateFormats = .ddmmyyhhmmss) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = formatType.rawValue
        return dateFormatter.string(from: self)
    }
}

enum DateFormats : String {
    case ddmmyyhhmmss = "ddMMyyyy HH:mm:ss"
    case ddmmyy = "ddMMMyyyy"
    case yyyymmdd = "yyyy-MM-dd"
    case mmddyy = "MM-dd-yyyy"
}
