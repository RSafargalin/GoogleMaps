//
//  ExNSPredicate.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation

extension NSPredicate {
    
    static func `for`(username: String) -> NSPredicate {
        return NSPredicate(format: "login == %@", username)
    }
    
}
