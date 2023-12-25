//
//  DocWorkPostEnum.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

enum DocWorkPost: String, CaseIterable {
    case empty = "-"
    case chiefMedicalOfficer = "Chief Medical Officer (Director)"
    case deputyChief = "Deputy Chief Medical Officer"
    case familyDoc = "Family doctor"
    case headOfDepartment = "Head of department"
    case deputyHeadOfDepartment = "Deputy Head of Department"
    case doctor = "Doctor"
    case nurse = "Nurse"
    case medicalWorker = "Medical worker"
    
    static var countForPicker: Int {
        get {
            return DocWorkPost.allCases.count+1
        }
    }
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    static func get(id: Int) -> DocWorkPost? {
        switch id {
        case 0:
            return .empty
        case 1:
            return .chiefMedicalOfficer
        case 2:
            return .deputyChief
        case 3:
            return .familyDoc
        case 4:
            return .headOfDepartment
        case 5:
            return .deputyHeadOfDepartment
        case 6:
            return .doctor
        case 7:
            return .nurse
        case 8:
            return .medicalWorker
        default:
            return nil
        }
    }
    
    func getId() -> Int {
        switch self {
        case .empty:
            return 0
        case .chiefMedicalOfficer:
            return 1
        case .deputyChief:
            return 2
        case .familyDoc:
            return 3
        case .headOfDepartment:
            return 4
        case .deputyHeadOfDepartment:
            return 5
        case .doctor:
            return 6
        case .nurse:
            return 7
        case .medicalWorker:
            return 8
        }
    }
    
    static func randomItem() -> DocWorkPost {
        let randIndex = Int.random(in: 0...DocWorkPost.allCases.count-1)
        return DocWorkPost.allCases[randIndex]
    }
}



struct HospitalWorkPostModel {
    let id: Int?
    let name: String?
    let language: String?
}

extension HospitalWorkPostModel: Codable {
    private enum Keys: String, CodingKey {
        case id = "id"
        case name = "name"
        case language = "language"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? -1
        name = try? container.decode(String.self, forKey: .name)
        language = try? container.decode(String.self, forKey: .language)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(language, forKey: .language)
    }
}
