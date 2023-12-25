//
//  HospitalModel.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

struct HospitalModel {
    let id: Int
    var fullName: String?
    var doctors: [UserModel] = []
    var location: LocationModel?
    var statistic: HealthStatisticModel?
    var needs: [NeedsModel] = []
    var haves: [NeedsModel] = []
    
    init(id: Int) {
        self.id = id
    }
}

extension HospitalModel {
    func getParamForGetHospital() -> Parameters {
        return [Keys.id.rawValue:id]
    }
    
    func compare(with hospOp: HospitalModel?) -> Bool {
        guard let hospital = hospOp else { return false }
        return self.id == hospital.id && self.fullName == hospital.fullName
    }
    
    var customImage: UIImage? {
        get {
            return UIImage(named: "hospitalIcon")
        }
    }
}

extension HospitalModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case fullName = "name"
        case doctors = "doctors"
        case location = "location"
        case statistic = "Ill"
        case needs = "needed"
        case haves = "haves"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        fullName = try? container.decode(String.self, forKey: .fullName)
        statistic = try? container.decode(HealthStatisticModel.self, forKey: .statistic)
        
        location = try? container.decode(LocationModel.self, forKey: .location)
        if location == nil { location = try? LocationModel(from: decoder) }
        
        if let docs = try? container.decode([UserModel].self, forKey: .doctors) {
            doctors = docs
        }
        
        if let docs = try? container.decode([DoctorModel].self, forKey: .doctors) {
            var newDoctors: [UserModel] = []
            docs.forEach { doc in
                var dk = UserModel(id: doc.id)
                dk.doctor = doc
                newDoctors.append(dk)
            }
            doctors = newDoctors
        }
        
        if let nds = try? container.decode([NeedsModel].self, forKey: .needs) {
            needs = nds
        }
        if let hvs = try? container.decode([NeedsModel].self, forKey: .haves) {
            haves = hvs
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(id, forKey: .id)
        try? container.encode(fullName, forKey: .fullName)
        try? container.encode(doctors, forKey: .doctors)
        try? container.encode(location, forKey: .location)
        try? container.encode(statistic, forKey: .statistic)
        try? container.encode(needs, forKey: .needs)
        try? container.encode(haves, forKey: .haves)
    }
}
