//
//  User+CoreDataProperties.swift
//  
//
//  Created by Ruslan Safargalin on 27.08.2021.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var login: String = ""
    @NSManaged public var password: String = ""

}
