//
//  RoutePath+CoreDataProperties.swift
//  
//
//  Created by Ruslan Safargalin on 24.08.2021.
//
//

import Foundation
import CoreData


extension RoutePath {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutePath> {
        return NSFetchRequest<RoutePath>(entityName: "RoutePath")
    }

    @NSManaged public var coordinates: [CLLocationCoordinate2D] = []

}
