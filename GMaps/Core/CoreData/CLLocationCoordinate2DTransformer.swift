//
//  CLLocationCoordinate2DTransformer.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 24.08.2021.
//

import Foundation
import CoreLocation

class Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

@objc(CLLocationCoordinate2DTransformer)
class CLLocationCoordinate2DTransformer: ValueTransformer {
    
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let coords = value as? [CLLocationCoordinate2D] else { return nil }
        
        let coordinates = coords.compactMap({ Coordinates(latitude: $0.latitude, longitude: $0.longitude) })
        
        guard let data = try? encoder.encode(coordinates)
        else { return nil }
        
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let coords = try? decoder.decode([Coordinates].self, from: data)
        else { return nil }
        
        let coordinates = coords.compactMap({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        
        return coordinates
    }
}
