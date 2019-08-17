//
//  Date+Extension.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 12/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import Foundation

extension Date {
    static func dateFromCustomString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
    }
    
    static func customStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date) 
    }
}
