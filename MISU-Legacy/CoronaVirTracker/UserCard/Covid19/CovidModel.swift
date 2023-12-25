//
//  CovidModel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CovidModel: Decodable, Equatable {
    var id: Int = -1
    var body: BodyModel?
    var age: PModel?
    var gender: PModel?
    var syndrome: Bool?
    var result: Bool?
    var vaccine: VaccineModel?
    var vaccines: [VaccineModel] = []
    
    var birth_date: Date?
    
    var riskGroup: RiskGroup {
        return RiskGroup(inGroup: result)
    }
    
    var syndromStr: String? {
        guard let sndr = syndrome else { return nil }
        if sndr {
            return NSLocalizedString("Diagnosed", comment: "")
        }
        return NSLocalizedString("Undiagnosed", comment: "")
    }
    
    enum Keys: String, CodingKey {
        case id = "id"
        case body = "body"
        case age = "age"
        case gender = "gender"
        case syndrome = "syndrome"
        case result = "result"
        case vaccine = "vaccine"
        case vaccineDate = "date"
        
        case height = "height"
        case weight = "weight"
        case birth_date = "birth_date"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(type(of: id).self, forKey: .id)) ?? -1
        body = try? container.decode(type(of: body).self, forKey: .body)
        age = try? container.decode(type(of: age).self, forKey: .age)
        gender = try? container.decode(type(of: gender).self, forKey: .gender)
        syndrome = try? container.decode(type(of: syndrome).self, forKey: .syndrome)
        result = try? container.decode(type(of: result).self, forKey: .result)
        vaccine = try? container.decode(type(of: vaccine).self, forKey: .vaccine)
        vaccines = (try? container.decode(type(of: vaccines).self, forKey: .vaccine)) ?? []
        
        if let v = vaccine {
            vaccines.firstIndex(of: v) == nil ? vaccines.append(v) : pass
        }
        
        vaccines.sort { first, second in
            guard let fDate = first.date else { return true }
            guard let sDate = second.date else { return true }
            
            if fDate.compare(sDate) == .orderedAscending {
                return false
            }
            return true
        }
    }
    
    init() {}
    
    init(height: Double? = nil, weight: Double? = nil,
         birth_date bd: Date? = nil, gender: Int? = nil, syndrome synd: Bool? = nil,
         vaccine vcc: VaccineModel? = nil) {
        self.body = .init(height: height)
        self.body?.weight = weight
        self.birth_date = bd
        self.gender = .init(value: gender)
        self.syndrome = synd
        self.vaccine = vcc
    }
    
    func encode() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        container.updateNilValue(body?.height, forKey: .height)
        container.updateNilValue(body?.weight, forKey: .weight)
        try? container.updateValue(birth_date?.getDateForRequest(), forKey: .birth_date)
        container.updateNilValue(gender?.value, forKey: .gender)
        container.updateNilValue(syndrome, forKey: .syndrome)
        container.updateNilValue(vaccine?.id, forKey: .vaccine)
        container.updateNilValue(vaccine?.dateString, forKey: .vaccineDate)
        
        return container.dictionary
    }
    
    
    /*
    "height": 175,
    "weight": 68,
    "birth_date": "1999-10-01",
    "gender": 1,
    "syndrome": false,
    "vaccine": 0,
     */

    static func == (lhs: CovidModel, rhs: CovidModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.body == rhs.body &&
               lhs.age == rhs.age &&
               lhs.gender == rhs.gender &&
               lhs.syndrome == rhs.syndrome &&
               lhs.result == rhs.result &&
               lhs.vaccines == rhs.vaccines &&
               lhs.vaccine == rhs.vaccine
    }
}



class VaccineModel: Decodable, Equatable {
    var id: Int?
    var vId: Int?
    var name: String?
    var date: Date? {
        return dateString?.toDate()
    }
    var dateString: String?
    
    enum Keys: String, CodingKey {
        case id = "id"
        case vId = "general"
        case name = "vaccine"
        case date = "date"
    }
    
    init() {}
    
    init(vacConst: ConstantsModel, date dt: Date? = nil) {
        id = vacConst.id
        name = vacConst.value
        dateString = dt?.getDateForRequest()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try? container.decode(type(of: id).self, forKey: .id)
        vId = try? container.decode(type(of: vId).self, forKey: .vId)
        name = try? container.decode(type(of: name).self, forKey: .name)
        dateString = try? container.decode(type(of: dateString).self, forKey: .date)
    }
    
    static func == (lhs: VaccineModel, rhs: VaccineModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.vId == rhs.vId &&
               lhs.name == rhs.name &&
               lhs.dateString == rhs.dateString
    }
    
    func encodeForDelete() -> Parameters {
        let container = KeyedCustomEncoderContainer(keyedBy: Keys.self)
        
        container.updateNilValue(id, forKey: .id)
        
        return container.dictionary
    }
}



class BaseCovidParamsModel: Decodable {
    var normal: Bool?
    
    var statusTitleText: String {
        return RiskGroup(isNormParam: normal).paramStatusTitle
    }
    
    var status: RiskGroup {
        return RiskGroup(isNormParam: normal)
    }
    
    var titleColor: UIColor {
        return RiskGroup(inGroup: normal).color
    }
    
    enum Keys: String, CodingKey {
        case normal = "normal"
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        normal = try? container.decode(type(of: normal).self, forKey: .normal)
    }
}



class BodyModel: BaseCovidParamsModel, Equatable {
    var weight: Double?
    var height: Double?
    var imt: Double?
    
    enum Keys: String, CodingKey {
        case weight = "weight"
        case height = "height"
        case imt = "imt"
    }
    
    override init() {
        super.init()
    }
    init(weight w: Double? = nil, height h: Double? = nil) {
        super.init()
        weight = w
        height = h
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Keys.self)
        
        weight = try? container.decode(type(of: weight).self, forKey: .weight)
        height = try? container.decode(type(of: height).self, forKey: .height)
        imt = try? container.decode(type(of: imt).self, forKey: .imt)
    }

    static func == (lhs: BodyModel, rhs: BodyModel) -> Bool {
        return lhs.weight == rhs.weight &&
               lhs.height == rhs.height &&
               lhs.imt == rhs.imt &&
               lhs.normal == rhs.normal
    }
}



class PModel: BaseCovidParamsModel, Equatable {
    var value: Int?
    var valueStr: String?
    
    var ageValue: String? {
        guard let vl = valueStr?.toDateOnly()?.getYears() else { return nil }
        return String(vl)
    }
    
    var strValue: String? {
        guard let vl = value else { return nil }
        return String(vl)
    }
    
    var sexValue: String? {
        guard let vl = value else { return nil }
        return SexEnum(num: vl).translate().localized
    }
    
    enum Keys: String, CodingKey {
        case value = "value"
    }
    
    override init() {
        super.init()
    }
    init(value v: Int? = nil) {
        super.init()
        value = v
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: Keys.self)
        
        value = try? container.decode(type(of: value).self, forKey: .value)
        valueStr = try? container.decode(type(of: valueStr).self, forKey: .value)
    }
    
    static func == (lhs: PModel, rhs: PModel) -> Bool {
        return lhs.value == rhs.value &&
               lhs.normal == rhs.normal &&
               lhs.valueStr == rhs.valueStr
    }
}
