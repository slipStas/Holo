//
//  User+CoreDataProperties.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 01.10.2020.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var login: String?
    @NSManaged public var password: String?

}

extension User : Identifiable {

}
