//
//  CoordinatesModel.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 9/25/19.
//  Copyright © 2019 CVTCompany. All rights reserved.
//

import Foundation
import Mapbox

struct Coordinates {
    let latitude: Double
    let longitude: Double
    
    var uId: Int? = nil
    
    init (lat: Double, lon: Double) {
        self.latitude = lat
        self.longitude = lon
    }
    
    init(CLLCoord: CLLocationCoordinate2D) {
        self.latitude = CLLCoord.latitude
        self.longitude = CLLCoord.longitude
    }
    
    func getCLLC2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Coordinates: Codable {
    private enum Keys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        
        case uId = "user"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        
        uId = try? container.decode(Int.self, forKey: .uId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        
        try? container.encode(uId, forKey: .uId)
    }
}
