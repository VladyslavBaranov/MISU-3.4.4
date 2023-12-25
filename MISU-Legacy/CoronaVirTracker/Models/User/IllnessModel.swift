//
//  IllnessModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 07.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

enum IllnessStateEnum: Int, CaseIterable {
    case cured = 0
    case ill = 1
    case chronic = 2
    
    var localized: String {
        get {
            switch self {
            case .ill:
                return NSLocalizedString("Sick", comment: "")
            case .cured:
                return NSLocalizedString("Recuperate", comment: "")
            case .chronic:
                return NSLocalizedString("Chronic", comment: "")
            }
        }
    }
    
    var color: UIColor {
        switch self {
        case .ill:
            return UIColor.appDefault.red
        case .cured:
            return UIColor.appDefault.green
        case .chronic:
            return UIColor.appDefault.blue
        }
    }
    
    //var illnessHistory: [IllnessModel] = []
}

enum IllnessConfirmedEnum: Int, CaseIterable {
    case analyzes = 0
    case notConfirmed = 1
    case doctor = 2
    
    var localized: String {
        get {
            switch self {
            case .notConfirmed:
                return NSLocalizedString("Not confirmed yet", comment: "")
            case .analyzes:
                return NSLocalizedString("Passed tests", comment: "")
            case .doctor:
                return NSLocalizedString("Diagnosed by a doctor", comment: "")
            }
        }
    }
}

struct IllnessModel {
    var id: Int
    var name: String?
    //var confirmedStr: String?
    //var stateStr: String?
    //var confirmedInt: Int?
    //var stateInt: Int?
    var confirmed: IllnessConfirmedEnum?
    var state: IllnessStateEnum?
    var date: Date?
    
    init(id _id: Int, name nm: String, confirmed conf: IllnessConfirmedEnum?, state st: IllnessStateEnum, date dt: Date = Date()) {
        id = _id
        name = nm
//        confirmedStr = conf?.localized
//        stateStr = st.localized
        confirmed = conf
        state = st
        date = dt
    }
    
    init(id id_: Int = -1, name nm: String, confirmed conf: IllnessConfirmedEnum? = nil, state st: IllnessStateEnum? = nil, date dt: Date = Date()) {
        id = id_
        name = nm
        confirmed = conf ?? .notConfirmed
        state = st ?? .ill
        date = dt
    }
    
//    init(name nm: String, confirmed conf: ConstantsModel? = nil, state st: ConstantsModel? = nil, date dt: Date = Date()) {
//        id = -1
//        name = nm
//        confirmedInt = conf?.id
//        stateInt = st?.id
//        date = dt
//    }
}

extension IllnessModel: Codable, ModelEncodeUtils {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        //case confirmedStr = "confirmed"
        //case stateStr = "state"
        case confirmed = "confirmed"
        case state = "state"
        case date = "date"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        //confirmedStr = try? container.decode(String.self, forKey: .confirmedStr)
        //stateStr = try? container.decode(String.self, forKey: .stateStr)
        
        if let confIndex = try? container.decode(Int.self, forKey: .confirmed) {
            confirmed = IllnessConfirmedEnum.allCases[confIndex]
        }
        if let stateIndex = try? container.decode(Int.self, forKey: .state) {
            state = IllnessStateEnum.allCases[stateIndex]
        }
        
        if let strDate = try? container.decode(String.self, forKey: .date) {
            date = strDate.toDate()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        //try? container.encode(stateStr, forKey: .stateStr)
        //try? container.encode(stateStr, forKey: .stateStr)
        try? container.encode(confirmed?.rawValue, forKey: .confirmed)
        try? container.encode(state?.rawValue, forKey: .state)
        try? container.encode(date?.getDateForRequest(), forKey: .date)
    }
    
    func getParamsDict() -> Parameters {
        var params: Parameters = [:]
        
        addOptionalTo(dict: &params, value: name, key: Keys.name.rawValue)
        addOptionalTo(dict: &params, value: confirmed?.rawValue, key: Keys.confirmed.rawValue)
        addOptionalTo(dict: &params, value: state?.rawValue, key: Keys.state.rawValue)
        addOptionalTo(dict: &params, value: date?.getDateForRequest(), key: Keys.date.rawValue)
        
        return params
    }
}
