//
//  DateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 23.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
extension Date {
    func getDate(format: String = "d MMM y") -> String {
        return getTimeDate(format: format)
    }
    
    func getTimeDate(format: String = "HH:mm, d MMM y", kiev: Bool = false) -> String {
        let formatter3 = DateFormatter()
        formatter3.timeZone = kiev ? TimeZone(abbreviation: "EET") : TimeZone(abbreviation: "GMT")
        formatter3.dateFormat = format
        return formatter3.string(from: self)
    }
    
    func getTimeDateForRequest(format: String = "yyyy-MM-dd'T'HH:mm:ss'Z'", current: Bool = true) -> String {
        let formatter3 = DateFormatter()
        if current {
            formatter3.locale = Locale.current
            formatter3.timeZone = TimeZone.current
        } else {
            formatter3.timeZone = TimeZone(abbreviation: "GMT")
        }
        formatter3.dateFormat = format
        return formatter3.string(from: self)
    }
    
    func getDateForRequest(format: String = "yyyy-MM-dd") -> String {
        let formatter3 = DateFormatter()
        formatter3.locale = Locale.current
        formatter3.timeZone = TimeZone.current
        formatter3.dateFormat = format
        return formatter3.string(from: self)
    }
    
    func getDateTime(format: String = "d MMM y, HH:mm") -> String {
        let formatter3 = DateFormatter()
        formatter3.timeZone = TimeZone(abbreviation: "GMT")
        formatter3.dateFormat = format
        formatter3.timeZone = TimeZone.current
        return formatter3.string(from: self)
    }
    
    func getTimeString() -> String? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        if minutes < 10 {
            return "\(hour):0\(minutes)"
        }
        return "\(hour):\(minutes)"
    }
    
    func getTimeDateWitoutToday(kiev: Bool = false) -> String? {
        if Calendar.current.compare(self , to: Date(), toGranularity: .day) == .orderedSame {
            return self.getTimeDate(format: "HH:mm", kiev: kiev)
        } else if Calendar.current.compare(self , to: Date(), toGranularity: .year) == .orderedSame {
            return self.getTimeDate(format: "d/M HH:mm", kiev: kiev)
        }
        return self.getTimeDate(format: "d/M/y HH:mm", kiev: kiev)
    }
    
    func getYears() -> Int? {
        let calendar = NSCalendar.current
        return calendar.dateComponents([.year], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: Date())).year
    }
}
