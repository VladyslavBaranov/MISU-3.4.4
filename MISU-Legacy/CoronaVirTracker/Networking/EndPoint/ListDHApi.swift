//
//  ListDHApi.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

public enum ListDHApi {
    case getAllDoctors(id: Int? )
    case getAllHospitals(id: Int? )
    case getGetPatientsOfCurrentDoctor(token: String)
    case getPatient(id: Int)
    //case getDoctor(id: Int)
}

extension ListDHApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: ServerURLs.api) else { fatalError(NetworkError.baseURLNil.rawValue) }
        return url
    }
    
    var path: String {
        switch self {
        case .getAllDoctors(let idOp):
            if let id = idOp { return "doctor/\(id)" }
            return "doctor"
        case .getAllHospitals(let idOp):
            if let id = idOp { return "hospital/\(id)" }
            return "hospital"
        case .getGetPatientsOfCurrentDoctor:
            return "patients_list"
        case .getPatient(let id):
            return "profile/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getAllDoctors, .getAllHospitals, .getGetPatientsOfCurrentDoctor, .getPatient: return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getAllDoctors, .getGetPatientsOfCurrentDoctor, .getPatient: return .request
        case .getAllHospitals:
            //let r: String = "Рівне"
            //return.requestURL(urlParameters: ["city":r])
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getGetPatientsOfCurrentDoctor(let token):
            return TypeHeaders.create(token: token)
        case .getPatient, .getAllDoctors:
            guard let token = KeychainUtils.getCurrentUserToken() else { return nil }
            return TypeHeaders.create(token: token)
        default: return nil
        }
    }
}
