//
//  CLLocationCoordinate2DTransformer.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 24.08.2021.
//

import Foundation
import CoreLocation

// MARK: - Coordinate

fileprivate struct Coordinate: Codable {
    
    // MARK: - Public variables
    
    let latitude: Double
    let longitude: Double
    
}

// MARK: - CLLocationCoordinate2DTransformer

@objc(CLLocationCoordinate2DTransformer)
class CLLocationCoordinate2DTransformer: ValueTransformer {
    
    // MARK: - Private variables
    
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    
    // MARK: - Public methods
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let coords = value as? [CLLocationCoordinate2D] else { return nil }
        
        let coordinates = coords.compactMap({ Coordinate(latitude: $0.latitude, longitude: $0.longitude) })
        
        guard let data = try? encoder.encode(coordinates)
        else { return nil }
        
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let coords = try? decoder.decode([Coordinate].self, from: data)
        else { return nil }
        
        let coordinates = coords.compactMap({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        
        return coordinates
    }
}
