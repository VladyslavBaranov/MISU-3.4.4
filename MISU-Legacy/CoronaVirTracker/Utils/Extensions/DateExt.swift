//
//  DateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 23.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

extension Calendar.Component {
    /// WARNING: works only from day to second
    var lowerComponent: Calendar.Component? {
        switch self {
        case .day:
            return .hour
        case .hour:
            return .minute
        case .minute:
            return .second
        case .second:
            return .nanosecond
        default:
            return nil
        }
    }
}

extension Date {
    /// Gets next Date by component plus count. Count should be positive.
    /// - Parameters:
    ///    - withComponent: .year, .month, .day.
    ///    - count: Count of steps. Should be positive.
    func next(withComponent: Calendar.Component = .day, count: Int = 1) -> Date? {
        return Calendar.current.date(byAdding: withComponent, value: count, to: self)
    }
     
    /// Gets previous Date by component minus count. Count should be positive
    /// - Parameters:
    ///    - withComponent: .year, .month, .day.
    ///    - count: Count of steps. Should be positive.
    func previous(withComponent: Calendar.Component = .day, count: Int = 1) -> Date? {
        return Calendar.current.date(byAdding: withComponent, value: -count, to: self)
    }
    
    /// Returns start of a day
    /// - hour 00 min 01 sec 00
    var startOfDay: Date? {
        Calendar.current.date(bySettingHour: 0, minute: 1, second: 0, of: self, direction: .backward)
    }
    
    /// Returns End of a day
    /// - hour 23 min 59 sec 00
    var endOfDay: Date? {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: self, direction: .forward)
    }
    
    func percentageProximityToDate(_ date: Date) -> Float {
        return Float(self.minutesDiff(with: date))/Float(1440)
    }
    
    static func testCases() {
        let dt = Date()
        let pdt = Date().previous() ?? Date()
        print("TEST: \(dt) = [ \(dt.percentageProximityToDate(pdt)) ] = \(pdt)")
    }
    
    func getDate(format: String = "d MMM y") -> String {
        return getTimeDate(format: format)
    }
    
    func getTimeDate(format: String = "HH:mm, d MMM y", kiev: Bool = false) -> String {
        let formatter3 = DateFormatter()
        formatter3.timeZone = TimeZone.current //kiev ? TimeZone(abbreviation: "EET") : TimeZone(abbreviation: "GMT")
        formatter3.dateFormat = format
        return formatter3.string(from: self)
    }
    
    func getTimeDateForRequest(format: String = "yyyy-MM-dd'T'HH:mm:ssxxx", current: Bool = true) -> String {
        let formatter3 = DateFormatter()
        if current {
            formatter3.locale = Locale.current
            formatter3.timeZone = TimeZone.current
        } else {
            formatter3.timeZone = TimeZone(abbreviation: "GMT")
        }
        //print("### --- \(formatter3.timeZone.abbreviation())")
        //print("### +++ \(formatter3.timeZone.secondsFromGMT())")
        formatter3.dateFormat = format
        //print("### +++ \(formatter3.string(from: self))")
        return formatter3.string(from: self)
    }
    
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(targetTimeZone.secondsFromGMT() - initTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
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
    
    func getTimeString(zeroCalendar: Bool = false) -> String? {
        var calendar = Calendar.current
        if zeroCalendar {
            calendar.timeZone = .init(secondsFromGMT: 0) ?? .current
            calendar.locale = .current
        }
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        if minutes < 10 {
            return "\(hour):0\(minutes)"
        }
        return "\(hour):\(minutes)"
    }
    
    func getTimeDateWitoutToday(short: Bool = false, zeroCalendar: Bool = false, kiev: Bool = false) -> String? {
        var calendar = Calendar.current
        if zeroCalendar {
            calendar.timeZone = .init(secondsFromGMT: 0) ?? .current
            calendar.locale = .current
        }
        if calendar.compare(self , to: Date(), toGranularity: .day) == .orderedSame {
            return self.getTimeDate(format: "HH:mm", kiev: kiev)
        } else if calendar.compare(self , to: Date(), toGranularity: .year) == .orderedSame {
            return self.getTimeDate(format: short ? "d MMM" : "d/M HH:mm", kiev: kiev)
        }
        return self.getTimeDate(format: short ? "d MMMM yyyy" : "d/M/y HH:mm", kiev: kiev)
    }
    
    func getYears() -> Int? {
        let calendar = NSCalendar.current
        return calendar.dateComponents([.year], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: Date())).year
    }
    
    func minutesDiff(with secondDate: Date) -> Int {
        let first = self.timeIntervalSinceReferenceDate/60
        let second = secondDate.timeIntervalSinceReferenceDate/60
        
        return Int(abs(first - second))
    }
    
    func isSameDay(with secondDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: secondDate)
    }
}
