//
//  HealthParameterModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct HealthParameterModel: Equatable {
    let id: Int
    var value: Float?
    var additionalValue: Float?
    var presentDate: String?
    var dateDType: Date?
    var date: String? {
        didSet {
            presentDate = date?.toDate()?.getTimeDateWitoutToday()
        }
    }
    
    init (id id_: Int, value vl: Float? = nil, additionalValue aVl: Float? = nil, date dt: Date = Date()) {
        self.id = id_
        self.value = vl
        self.additionalValue = aVl
        self.presentDate = dt.getTimeDateWitoutToday()
        self.dateDType = dt
    }
    
    init (id id_: Int, value vl: Float? = nil, additionalValue aVl: Float? = nil, date dt: String) {
        self.id = id_
        self.value = vl
        self.additionalValue = aVl
        self.date = dt
    }
    
    static func ==(first: HealthParameterModel, second: HealthParameterModel) -> Bool {
        return first.date?.toDate() == second.date?.toDate()
    }
}

extension HealthParameterModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case value = "value"
        case additionalValue = "additional"
        case date = "date"
        case presentDate = "presentDate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        value = try? container.decode(Float.self, forKey: .value)
        additionalValue = try? container.decode(Float.self, forKey: .additionalValue)
        //print("#DT \(try? container.decode(String.self, forKey: .date))")
        date = try? container.decode(String.self, forKey: .date)
        //print("#DT \(date)")
        //dateDType = try? container.decode(Date.self, forKey: .date)
        presentDate = try? container.decode(String.self, forKey: .presentDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(value, forKey: .value)
        try? container.encode(additionalValue, forKey: .additionalValue)
        try? container.encode(date, forKey: .date)
        //try container.encode(dateDType, forKey: .date)
        try? container.encode(presentDate, forKey: .presentDate)
    }
    
    func encodeForRequest() -> Parameters {
        var prms: Parameters = [Keys.value.rawValue:value as Any]
        if let dt = dateDType {
            prms.updateValue(dt.getTimeDateForRequest(), forKey: Keys.date.rawValue)
        }
        if let adv = additionalValue {
            prms.updateValue(adv, forKey: Keys.additionalValue.rawValue)
        }
        return prms
    }
    
    func encodeForListRequest() -> Parameters {
        var prms: Parameters = [Keys.value.rawValue:value as Any]
        if let dt = date?.toDate()?.getTimeDateForRequest(current: false) {
            prms.updateValue(dt, forKey: Keys.date.rawValue)
        } else {
            return [:]
        }
        if let adv = additionalValue {
            prms.updateValue(adv, forKey: Keys.additionalValue.rawValue)
        }
        return prms
    }
}

struct ListHParameterModel {
    var sugar: [HealthParameterModel] = []
    var insulin: [HealthParameterModel] = []
    var temperature: [HealthParameterModel] = []
    var pulse: [HealthParameterModel] = []
    var bloodOxygen: [HealthParameterModel] = []
    var bloodPressure: [HealthParameterModel] = []
    
    init (sg: [HealthParameterModel] = [],
          ins: [HealthParameterModel] = [],
          temp: [HealthParameterModel] = [],
          hb: [HealthParameterModel] = [],
          bo: [HealthParameterModel] = [],
          bp: [HealthParameterModel] = []) {
        sugar = sg
        insulin = ins
        temperature = temp
        pulse = hb
        bloodOxygen = bo
        bloodPressure = bp
    }
}

extension ListHParameterModel {
    private enum Keys: String, CodingKey {
        case sugar = "sugar"
        case insulin = "insulin"
        case temperature = "temperature"
        case pulse = "pulse"
        case bloodOxygen = "blood_oxygen"
        case bloodPressure = "pressure"
    }
    
    func encodeForRequest() -> Parameters {
        var dataList: Parameters = [:]
        let parameters = [sugar, insulin, bloodOxygen, temperature, pulse, bloodPressure]
        let keys = [Keys.sugar, Keys.insulin, Keys.bloodOxygen, Keys.temperature, Keys.pulse, Keys.bloodPressure]
        keys.enumerated().forEach { index, key in
            if parameters[index].isEmpty { return }
            var newValue: [Parameters] = []
            parameters[index].forEach { param in
                newValue.append(param.encodeForListRequest())
            }
            dataList.updateValue(newValue, forKey: key.rawValue)
        }
        return dataList
    }
}
