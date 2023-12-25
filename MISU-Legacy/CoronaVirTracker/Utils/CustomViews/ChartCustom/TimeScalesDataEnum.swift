//
//  TimeScalesDataEnum.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum TimeScalesDataEnum: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case allTime = "All time"
    
    var localized: String {
        get { return NSLocalizedString(self.rawValue, comment: "") }
    }
    
    var index: Int {
        get { return TimeScalesDataEnum.allCases.firstIndex(of: self) ?? 0 }
    }
    
    var next: TimeScalesDataEnum {
        get {
            return TimeScalesDataEnum.allCases[safe: self.index + 1] ?? TimeScalesDataEnum.allCases.first ?? .today
        }
    }
    
    var sRange: HealthParamsEnum.StaticticRange {
        switch self {
        case .today: return .day
        case .week: return .week
        case .month: return .month
        case .allTime: return .year
        }
    }
    
    var calendarComponent: Calendar.Component {
        get {
            switch self {
            case .allTime:
                return .era
            case .month:
                return .month
            case.today:
                return .hour
            case .week:
                return .weekday
            }
        }
    }
    
    var timeValues: Int {
        get {
            switch self {
            case .allTime:
                return 0
            case .month:
                return 1
            case .week:
                return 7
            case.today:
                return 24
            }
        }
    }
    
    func include(_ components: DateComponents) -> Bool {
        switch self {
        case .allTime:
            return true
        case .today:
            return (components.hour ?? 0) < self.timeValues
        case .month:
            return (components.month ?? 0) < self.timeValues
        case .week:
            return (components.weekday ?? 0) < self.timeValues
        }
    }
}

