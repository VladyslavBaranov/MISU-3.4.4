//
//  HealthParameterModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct Health4Params: Decodable {
    //{"temperature":36.0,"pulse":78.0,"blood_oxygen":97.0,"pressure_systolic":117.71015795755763,"pressure_diastolic":82.27429662822303,"sugar":3.5,"insulin":1.0}
    var temperature: Float?
    var pulse: Float?
    var blood_oxygen: Float?
    var pressure_systolic: Float?
    var pressure_diastolic: Float?
    var sugar: Float?
    var insulin: Float?
    
    enum Keys: String, CodingKey {
        case temperature = "temperature"
        case pulse = "pulse"
        case blood_oxygen = "blood_oxygen"
        case pressure_systolic = "pressure_systolic"
        case pressure_diastolic = "pressure_diastolic"
        case sugar = "sugar"
        case insulin = "insulin"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        temperature = try? container.decode(Float.self, forKey: .temperature)
        pulse = try? container.decode(Float.self, forKey: .pulse)
        blood_oxygen = try? container.decode(Float.self, forKey: .blood_oxygen)
        pressure_systolic = try? container.decode(Float.self, forKey: .pressure_systolic)
        pressure_diastolic = try? container.decode(Float.self, forKey: .pressure_diastolic)
        sugar = try? container.decode(Float.self, forKey: .sugar)
        insulin = try? container.decode(Float.self, forKey: .insulin)
    }
}

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
    
    init (id id_: Int = -1, value vl: Float? = nil, additionalValue aVl: Float? = nil, date dt: Date = Date()) {
        self.id = id_
        self.value = vl
        self.additionalValue = aVl
        self.presentDate = dt.getTimeDateWitoutToday()
        self.dateDType = dt
        self.date = dateDType?.getTimeDateForRequest()
    }
    
    init (id id_: Int = -1, value vl: Float? = nil, additionalValue aVl: Float? = nil, date dt: String) {
        self.id = id_
        self.value = vl
        self.additionalValue = aVl
        self.date = dt
        dateDType = self.date?.toDate()
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
        presentDate = try? container.decode(String.self, forKey: .presentDate)
        date = try? container.decode(String.self, forKey: .date)
        
        //print("### $ \(date) \(date?.toDate())")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        //try? container.encode(id, forKey: .id)
        try? container.encode(value, forKey: .value)
        try? container.encode(additionalValue, forKey: .additionalValue)
        //try? container.encode(date, forKey: .date)
        //try? container.encode(presentDate, forKey: .presentDate)
    }
    
    func encode() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(value, forKey: .value)
        try? container.updateValue(additionalValue, forKey: .additionalValue)
        
        return container.dictionary
    }
    
    func encodeForRequest() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(dateDType?.getTimeDateForRequest(), forKey: .date)
        try? container.updateValue(value, forKey: .value)
        try? container.updateValue(additionalValue, forKey: .additionalValue)
        
        return container.dictionary
    }
    
    func encodeForListRequest() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        try? container.updateValue(value, forKey: .value)
        try? container.updateValue(additionalValue, forKey: .additionalValue)
        
        do {
            try container.updateValue(date?.toDate()?.getTimeDateForRequest(current: true), forKey: .date)
        } catch {
            return [:]
        }
        return container.dictionary
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
        //print("### \n\(dataList)")
        return dataList
    }
}
