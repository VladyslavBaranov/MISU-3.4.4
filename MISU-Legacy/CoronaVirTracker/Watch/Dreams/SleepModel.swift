//
//  SleepModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 24.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
//import TrusangBluetooth


class RecommendationSleepModel: Decodable, Equatable {
    var title: String?
    var subtitle: String?
    var text: String?
    var preImageURL: String?
    var fullImageURL: String?
    
    enum Keys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case text = "text"
        case preImageURL = "pre_image"
        case fullImageURL = "full_image"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        title = try? container.decode(forKey: .title)
        subtitle = try? container.decode(forKey: .subtitle)
        text = try? container.decode(forKey: .text)
        preImageURL = try? container.decode(forKey: .preImageURL)
        fullImageURL = try? container.decode(forKey: .fullImageURL)
    }
    
    static func == (lhs: RecommendationSleepModel, rhs: RecommendationSleepModel) -> Bool {
        return lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.text == rhs.text &&
               lhs.preImageURL == rhs.preImageURL &&
               lhs.fullImageURL == rhs.fullImageURL
    }
}



// MARK: - Phase Type
enum SleepPhaseType: String, EnumKit, CaseIterable {
    case begin = "begin"
    case light = "light"
    case deep = "deep"
    case REM = "rem"
    case awake = "awake"
    
    static let allListForChart: [SleepPhaseType] = [.deep, .light, .REM, .awake]
    
    static let yChartRange = -0.3...3.1
    
    init(forChart: Int) {
        switch forChart {
        case 0:
            self = .deep
        case 1:
            self = .light
        case 2:
            self = .REM
        default:
            self = .awake
        }
    }
    
    var yForChart: Int {
        switch self {
        case .REM:
            return 2
        case .light:
            return 1
        case .deep:
            return 0
        default:
            return 3
        }
    }
    
    var localized: String {
        return NSLocalizedString(title, comment: "")
    }
    
    var title: String {
        switch self {
        case .awake:
            return "Awake"
        case .REM:
            return "REM"
        case .begin:
            return "Begin"
        case .deep:
            return "Deep"
        case .light:
            return "Light"
        }
    }
    
    var color: UIColor {
        switch self {
        case .REM:
            return .init(hexString: "50B9DB")
        case .light:
            return .init(hexString: "7479F4")
        case .deep:
            return .init(hexString: "503DC7")
        default:
            return .init(hexString: "2B98F3")
        }
    }
    
    var icon: UIImage? {
        return UIImage(named: imageName)
    }
    
    var imageName: String {
        switch self {
        case .REM:
            return "REMIcon"
        case .light:
            return "LightIcon"
        case .deep:
            return "DeepIcon"
        default:
            return "WakeIcon"
        }
    }
    
    var bgStars: UIImage? {
        switch self {
        case .deep:
            return .init(named: "phaseStars1")
        case .light:
            return .init(named: "phaseStars2")
        case .REM:
            return .init(named: "phaseStars3")
        default:
            return nil
        }
    }
    
    var localizedDetailedText: String {
        return NSLocalizedString(detailedText, comment: "")
    }
    
    var detailedText: String {
        switch self {
        case .REM:
            return "REM (Rapid eye movement) is about 20-25% of the total duration of a night's sleep. At this time we have the brightest dreams. If you wake up in this phase - the dream will be remembered for a long time."
        case .deep:
            return "A Deep sleep. Thanks to the deep sleep our body feels rested in the morning. If you wake up during a deep sleep, you will probably feel tired at first."
        case .light:
            return "A Light sleep is a slow sleep, but not in its deepest manifestations, during which you can wake up easy. The average duration of one \"phase\" of light sleep is about 20 minutes."
        default:
            return "Awakening is a moment of your conscious activity. For example, the period of falling asleep before bed, waking up in the middle of the night or waking up after sleep, when the body returns to its usual active state."
        }
    }
    
    func addShadow(onView: UIView?) {
        onView?.addShadow(radius: 5, offset: .zero, opacity: 1, color: color)
    }
}



// MARK: - Phase Model
class SleepPhaseModel: Decodable {
    var id: Int = -1
    var dateTime: String?
    var duration: Int?
    
    var date: Date? {
        return dateTime?.toDate(local: false, isGMT: true)
    }
    
    var decoratedTime: String? {
        return date?.getTimeString(zeroCalendar: true)
    }
    
    var decoratedEndTime: String? {
        guard let dr = duration else { return decoratedTime }
        return date?.next(withComponent: .minute, count: dr)?.getTimeString(zeroCalendar: true)
    }
    
    func decoratedTimeBy(percent: Float) -> String? {
        guard var dr = duration else { return decoratedTime }
        dr = Int(Float(dr) * percent)
        return date?.next(withComponent: .minute, count: dr)?.getTimeString(zeroCalendar: true)
    }
    
    var pType: SleepPhaseType? /*{
        guard let tp = typeInt else { return nil }
        return SleepPhaseType(rawValue: tp)
    }*/
    
    enum Keys: String, CodingKey {
        case id = "id"
        case dateTime = "date"
        case duration = "duration"
        case typeStr = "type"
    }
    
    init() { }
    
    func encode() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(dateTime, forKey: .dateTime)
        try? container.updateValue(duration, forKey: .duration)
        try? container.updateValue(pType?.rawValue, forKey: .typeStr)
        
        print("SLEEP: \(container.dictionary)")
        
        return container.dictionary
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(type(of: id).self, forKey: .id)) ?? -1
        dateTime = try? container.decode(type(of: dateTime).self, forKey: .dateTime)
        duration = try? container.decode(type(of: duration).self, forKey: .duration)
        if let typestr = try? container.decode(String.self, forKey: .typeStr) {
            pType = SleepPhaseType(rawValue: typestr)
        }
        //print("SSS ---------------------------------------------------------")
        //print("SSS dt dateTime \(dateTime ?? "nil")")
        //print("SSS dt date \(date)")
        //print("SSS dt date \(decoratedTime ?? "nil")")
    }
}

extension SleepPhaseModel: Equatable {
    public static func == (lhs: SleepPhaseModel, rhs: SleepPhaseModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.dateTime == rhs.dateTime &&
               lhs.duration == rhs.duration &&
               lhs.pType == rhs.pType
    }
}



// MARK: - Sleep Model
public class SleepModel: Decodable {
    var id: Int = -1
    var dateTime: String?
    var beginDuration: Int?
    var REMDuration: Int?
    var lightDuration: Int?
    var deepDuration: Int?
    var awakeDuration: Int?
    var details: [SleepPhaseModel] = []
    
    var totalDuration: Int {
        return beginCalcDuration + REMCalcDuration + lightCalcDuration + deepCalcDuration + awakeCalcDuration
    }
    
    var beginCalcDuration: Int {
        if let bd = beginDuration, bd > 0 { return bd }
        return getDurationBy(pType: .begin)
    }
    var REMCalcDuration: Int {
        if let rd = REMDuration, rd > 0 { return rd }
        return getDurationBy(pType: .REM)
    }
    var lightCalcDuration: Int {
        if let ld = lightDuration, ld > 0 { return ld }
        return getDurationBy(pType: .light)
    }
    var deepCalcDuration: Int {
        if let dd = deepDuration, dd > 0 { return dd }
        return getDurationBy(pType: .deep)
    }
    var awakeCalcDuration: Int {
        if let ad = awakeDuration, ad > 0 { return ad }
        return getDurationBy(pType: .awake)
    }
    
    var date: Date? {
        return dateTime?.toDate()
    }
    
    enum Keys: String, CodingKey {
        case id = "id"
        case dateTime = "date"
        case beginDuration = "begin"
        case REMDuration = "rem"
        case lightDuration = "light"
        case deepDuration = "deep"
        case awakeDuration = "awake"
        case details = "details"
    }
    
    var uId: Int? = nil
    
    init() { }
    init(date dt: Date, uId _uID: Int? = nil) {
        dateTime = dt.getDateForRequest()
        uId = _uID
    }
    
    func encodeForURL() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(dateTime, forKey: .dateTime)
        try? container.updateValue(uId, forKey: .id)
        return container.dictionary
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(type(of: id).self, forKey: .id)) ?? -1
        dateTime = try? container.decode(type(of: dateTime).self, forKey: .dateTime)
        beginDuration = try? container.decode(type(of: beginDuration).self, forKey: .beginDuration)
        REMDuration = try? container.decode(type(of: REMDuration).self, forKey: .REMDuration)
        lightDuration = try? container.decode(type(of: lightDuration).self, forKey: .lightDuration)
        deepDuration = try? container.decode(type(of: deepDuration).self, forKey: .deepDuration)
        awakeDuration = try? container.decode(type(of: awakeDuration).self, forKey: .awakeDuration)
        details = (try? container.decode(type(of: details).self, forKey: .details)) ?? []
        
        //print("SSS dateTime \(dateTime ?? "nil")")
        //print("SSS date \(date?.getDate() ?? "nil")")
    }
    
    func encode() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(dateTime, forKey: .dateTime)
        try? container.updateValue(beginDuration, forKey: .beginDuration)
        try? container.updateValue(beginDuration, forKey: .beginDuration)
        try? container.updateValue(REMDuration, forKey: .REMDuration)
        try? container.updateValue(lightDuration, forKey: .lightDuration)
        try? container.updateValue(deepDuration, forKey: .deepDuration)
        try? container.updateValue(awakeDuration, forKey: .awakeDuration)
        try? container.updateValue(details.map { m in return m.encode() }, forKey: .details)
        
        print("SLEEP 1: \(container.dictionary)")
        
        return container.dictionary
    }
    
    func getDurationBy(pType: SleepPhaseType) -> Int {
        return details.reduce(into: Int()) { duration, model in
            model.pType == pType ? duration += model.duration ?? 0 : pass
        }
    }
}

extension SleepModel: Equatable {
    public static func == (lhs: SleepModel, rhs: SleepModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.dateTime == rhs.dateTime &&
               lhs.beginDuration == rhs.beginDuration &&
               lhs.REMDuration == rhs.REMDuration &&
               lhs.lightDuration == rhs.lightDuration &&
               lhs.deepDuration == rhs.deepDuration &&
               lhs.awakeDuration == rhs.awakeDuration &&
               lhs.details == rhs.details
    }
}
