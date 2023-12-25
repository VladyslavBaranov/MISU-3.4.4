//
//  LocationModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/15/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

struct LocationModel {
    var name: String?
    var city: String?
    var country: String?
    var coordinate: Coordinates?
    var adminArea: String?
    
    init(_ name: String, city: String, country: String, adminArea: String? = nil, coord: Coordinates? = nil) {
        self.city = city
        self.country = country
        self.coordinate = coord
        self.adminArea = adminArea
        self.name = name
    }
    
    //func getDiferentParams(with old: LocationModel) -> Parameters {
        //var params: Parameters = [:]
        
        //params.merge(with: doctor.getDiferentParams())
        
        //return params
    //}
    
    func compare(with locationOp: LocationModel?) -> Bool {
        guard let location = locationOp else { return false }
        return self.name == location.name &&
            self.city == location.city &&
            self.country == location.country
    }
    
    func getFullLocationStr(withName: Bool = true) -> String {
        var str = withName ? name ?? "" : ""
        if city != name {
            str += withName ? ", " + (city ?? "") : (city ?? "")
        }
        
        if let adm = adminArea, city != adm, name != adm {
            str += ", \(adm)"
        }
        
        return str + ", \(country ?? "")"
    }
    
    func checkIfNil() -> Bool {
        return name == nil && city == nil && country == nil && coordinate == nil && adminArea == nil
    }
}

extension LocationModel: Codable {
    private enum Keys: String, CodingKey {
        case name = "name"
        case city = "city"
        case country = "country"
        case coordinate = "coordinate"
        case adminArea = "adminArea"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        name = try? container.decode(String.self, forKey: .name)
        city = try? container.decode(String.self, forKey: .city)
        country = try? container.decode(String.self, forKey: .country)
        adminArea = try? container.decode(String.self, forKey: .adminArea)
        coordinate = try? container.decode(Coordinates.self, forKey: .coordinate)
        if coordinate == nil {
            guard let lat = try? container.decode(Double.self, forKey: .latitude) else { return }
            guard let lon = try? container.decode(Double.self, forKey: .longitude) else { return }
            coordinate = .init(lat: lat, lon: lon)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try? container.encode(name, forKey: .name)
        try? container.encode(city, forKey: .city)
        try? container.encode(country, forKey: .country)
        try? container.encode(coordinate, forKey: .coordinate)
        try? container.encode(adminArea, forKey: .adminArea)
    }
    
    func getParamsToCreate() -> Parameters {
        guard let nm = name else { return [:] }
        guard let ct = city else { return [:] }
        guard let cntr = country else { return [:] }
        
        return [Keys.name.rawValue:nm,
                Keys.city.rawValue:ct,
                Keys.country.rawValue:cntr,
                Keys.latitude.rawValue:coordinate?.latitude as Any, Keys.longitude.rawValue:coordinate?.longitude as Any,
                Keys.adminArea.rawValue:adminArea as Any]
    }
}

